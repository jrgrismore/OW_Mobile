//
//  MyEventsViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 2/3/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class MyEventsViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate
{
  @IBOutlet weak var myEventsCollection: UICollectionView!
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var spinnerLbl: UILabel!
  @IBOutlet weak var spinnerView: UIView!
  @IBOutlet weak var timeSinceFld: UIBarButtonItem!
  
  let reuseIdentifier = "MyEventCell"
  var cellEventDetailArray = [EventWithDetails]()  //for rework
  var cellEventDetailStringArray = [EventDetailStrings]()
  var eventStore = EKEventStore()
  let vc = EKEventEditViewController()
  
  var eventCompleted: Bool = false
  
  @IBAction func switchToLogin(_ sender: Any)
  {
    tabBarController?.selectedIndex = 1
  }
  
  // MARK: - View functions
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(testRefresh), for: .valueChanged)
    myEventsCollection.refreshControl = refreshControl
    eventUpdateIntervalSeconds = TimeInterval(convertAutoUpdateValueToSeconds())
    
    self.spinnerView.layer.cornerRadius = 20
    OWWebAPI.shared.delegate = self
    myEventsCollection.backgroundColor =  #colorLiteral(red: 0.1621451974, green: 0.2774310112, blue: 0.2886824906, alpha: 1)
    loadCredentailsFromKeyChain()
    
    //assume update is expected
    updateCellArray()
    
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                    NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
    NotificationCenter.default.addObserver(self, selector: #selector(handleEventTimer), name: NSNotification.Name(rawValue: NotificationKeys.dataRefreshIsDone), object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                    NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
    loadCredentailsFromKeyChain()
    self.cellEventDetailStringArray = self.assignEventDetailStrings(eventPlusDetails: self.cellEventDetailArray)
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    if userHasChanged
    {
      let userChangeAlert = UIAlertController(title: "User Has Changed to \n" + Credentials.username, message: "Update Event List?", preferredStyle: .alert)
      //add action to update user
      userChangeAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: {_ in
        //handle the user change
        self.refreshEventCells(nil)
        userHasChanged = false
      })
      )
      userChangeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
        self.cellEventDetailArray = []
        self.myEventsCollection.reloadData()
        OWWebAPI.shared.saveEventsWithDetails([])
        UserDefaults.standard.removeObject(forKey: UDKeys.lastEventListUpdate)
      }) )
      self.present(userChangeAlert, animated: true, completion: nil)
    }
    self.myEventsCollection.reloadData()
  }
  override func viewWillLayoutSubviews()
  {
    super.viewWillLayoutSubviews()
    myEventsCollection.collectionViewLayout.invalidateLayout()
    //set cell size
    let cellHeight = 180
    //set layout attributes
    if let flowLayout = self.myEventsCollection.collectionViewLayout as? UICollectionViewFlowLayout
    {
      flowLayout.minimumLineSpacing = 15
      flowLayout.minimumInteritemSpacing = 3
      flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      let cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width - totalHInsets
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  @objc func testRefresh()
  {
    updateCellArray()
    //get cookie info
    OWWebAPI.shared.getCookieData()
    myEventsCollection.refreshControl?.endRefreshing()
  }
  
  fileprivate func showLastUpdateAlert()
  {
    var alertTitle = ""
    var alertMsg = ""
    var alertExistingBtn = ""
    
    var lastUpdateAlert = UIAlertController()
    if let lastUpdate = UserDefaults.standard.object(forKey: UDKeys.lastEventListUpdate) as? Date
    {
      // lastUpdate is valid, therefore previous event list is stored in UserDefaults
      // show alert asking update or use existing
      let updateTimeFormatter = DateFormatter()
      updateTimeFormatter.dateFormat = "MM-dd-yy'   'HH:mm:ss"
      let lastUpdateStr = updateTimeFormatter.string(from: lastUpdate)
      
      alertTitle = String(format:"Event List for User\n" + Credentials.username + "\nLast Updated\n%@",lastUpdateStr)
      alertMsg = "Update Event List or\nUse Existing List?"
      alertExistingBtn = "Use Existing"
    }
    else
    {
      //lastUpdate is nil, therefore no previous event list data is available
      
      alertTitle = "Event List for User \n" + Credentials.username + "\nNot Updated"
      alertMsg = "Update Now?"
    }
    
    lastUpdateAlert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
    lastUpdateAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: {_ in
      //handle the update
      self.updateCellArray()
    }))
    if alertExistingBtn == "Use Existing"
    {
      lastUpdateAlert.addAction(UIAlertAction(title: alertExistingBtn, style: .default, handler: {_ in
        //restore existing list
        self.cellEventDetailArray = OWWebAPI.shared.loadEventsWithDetails()
        self.cellEventDetailStringArray = self.assignEventDetailStrings(eventPlusDetails: self.cellEventDetailArray)
        DispatchQueue.main.async{self.myEventsCollection.reloadData()}
      }))
    }
    lastUpdateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
    }) )
    
    self.present(lastUpdateAlert, animated: true, completion: nil)
  }
  
  
  @objc func handleEventTimer()
  {
    if eventsWithDetails.count < 1
    {
      handleEmptyEventList()
      return
    }
    if eventRefreshFailed
    {
      //terminate automatic update activities and show alert
      var autoUpdateAlert = UIAlertController(title: "Automatic Events Update Failed!  No Internet Connection.", message: "Cancel Automatic Updating, or Retry?\n(You can re-enable automatic updates in Settings)", preferredStyle: .alert)
      //retry
      var retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
        refreshEventsWithDetails(completionHandler: {() -> () in
          //start data refresh timer
          startEventUpdateTimer()
        })
      }
      autoUpdateAlert.addAction(retryAction)
      //cancdl
      var cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        appSettings.autoUpdateIsOn = false
        saveSettings(appSettings)
      }
      autoUpdateAlert.addAction(cancelAction)
      //show alert
      self.present(autoUpdateAlert, animated: true, completion: nil)
    } else {
      updateMyEventsCells()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == "DetailSegue"
    {
      if let dest = segue.destination as? DetailViewController,
        let index = myEventsCollection.indexPathsForSelectedItems?.first
      {
        dest.selectedEvent = cellEventDetailArray[index.row]
        dest.eventsWithDetails = cellEventDetailArray
        dest.selectionObject = cellEventDetailArray[index.row].Object
        dest.eventID = cellEventDetailArray[index.row].Id!
        
        eventsWithDetails = OWWebAPI.shared.loadEventsWithDetails()
        let timeRemaining = leadTime(timeString: cellEventDetailArray[index.row].EventTimeUtc!)
        if timeRemaining == "completed"
        {eventCompleted = true} else {eventCompleted = false}
        if eventCompleted
        {
          dest.complete = eventCompleted
        } else {
          dest.complete = false
        }
      }
    }
  }
  
  // MARK: - Event data functions
  fileprivate func updateMyEventsCells()
  {
    //data assigned
    self.cellEventDetailArray = eventsWithDetails
    if eventsWithDetails.count < 1
    {
      handleEmptyEventList()  //end of no data dispatch
      return
    }  // eventsWithDetailsData!.count < 1
    self.cellEventDetailArray = eventsWithDetails
    self.cellEventDetailStringArray = self.assignEventDetailStrings(eventPlusDetails: self.cellEventDetailArray)
    DispatchQueue.main.async{self.myEventsCollection.reloadData()}
    //start time since last update timer
    //this invalidates the previously running timer, so it's like a reset
    startTimeSinceUpdateTimer()
  }
  
  func getEventsWithDetails()
  {
    DispatchQueue.main.async {self.startSpinner()}
    OWWebAPI.shared.retrieveEventsWithDetails(completion: { (eventsWithDetailsData, error, statusCode) in
      DispatchQueue.main.async
        { //inner dispatch
          print("getEventsWithDetails > statusCode=",statusCode)
          if error != nil
          {
            DispatchQueue.main.async {self.stopSpinner()}
              print("getEventsWithDetails > error=",error)
            
            //determine last user update
            var lastUserUpdateStr = ""
            if let lastUpdate = UserDefaults.standard.object(forKey: UDKeys.lastEventListUpdate) as? Date
            {
              // lastUpdate is valid, therefore previous event list is stored in UserDefaults
              // show alert asking update or use existing
              let updateTimeFormatter = DateFormatter()
              updateTimeFormatter.dateFormat = "MM-dd-yy'   'HH:mm:ss"
              let lastUpdateStr = updateTimeFormatter.string(from: lastUpdate)
              
              lastUserUpdateStr = String(format:"Event List for User\n" + Credentials.username + "\nLast Updated\n%@",lastUpdateStr)
            }
            else
            {
              //lastUpdate is nil, therefore no previous event list data is available
            }
            //show no connection alert
            var inetConnectionAlert = UIAlertController(title: "No Internet Connection!\n" + lastUserUpdateStr, message: "Retry, Use Exising List, or Cancel Update?", preferredStyle: .alert)
            var retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
              self.updateCellArray()
            }
            inetConnectionAlert.addAction(retryAction)
            
            var useExistingAction = UIAlertAction(title: "Use Existing", style: .default) { _ in
              //restore existing list
              self.cellEventDetailArray = OWWebAPI.shared.loadEventsWithDetails()
              self.cellEventDetailStringArray = self.assignEventDetailStrings(eventPlusDetails: self.cellEventDetailArray)
              DispatchQueue.main.async{self.myEventsCollection.reloadData()}
            } //end of useExistingAction closure
            inetConnectionAlert.addAction(useExistingAction)
            
            var cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            }
            inetConnectionAlert.addAction(cancelAction)
            self.present(inetConnectionAlert, animated: true, completion: nil)
            return
          } else {
            // no errors
            //check respose for authorization failure
            if statusCode == 401
            {
              print("authorization failure, check userid and password")
              print("eventsWithDetails count =",eventsWithDetails.count)
              self.stopSpinner()
              //show no connection alert
              var authFailureAlert = UIAlertController(title: "Authorization Failed", message: "Check Userid and Password.", preferredStyle: .alert)
              authFailureAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in return}))
              self.present(authFailureAlert, animated: true, completion: nil)
              return  //???
            }
            self.spinnerLbl.text = "Event List \n Download Complete..."
            //fill cells
            if eventsWithDetails != nil
            {
              eventsWithDetails = eventsWithDetailsData!
              print("eventsWithDetails count =",eventsWithDetails.count)
              if eventsWithDetails.count == 0
              {
                self.stopSpinner()
                //show no events in list alert
                var zeroEventsAlert = UIAlertController(title: "Stations for asteroidal events announced in OccultWatcher Desktop as My Events (excluding Follow Ups) will be listed here.  You currently have no submitted stations.", message: "", preferredStyle: .alert)
                zeroEventsAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in return}))
                self.present(zeroEventsAlert, animated: true, completion: nil)
                return  //???
              }
              self.updateMyEventsCells()
              DispatchQueue.main.async{self.spinnerLbl.text = "Updating Events..."}
              usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
              DispatchQueue.main.async {self.stopSpinner()}
              //start data refresh timer
              startEventUpdateTimer()
            } else {
              // eventsWithDetailsData is nil
              print("eventsWithDetailsData is nil")
            }
          }  //end of no errors block
          //store update date in userDefaults
          UserDefaults.standard.set(Date(), forKey: UDKeys.lastEventListUpdate)
          OWWebAPI.shared.saveEventsWithDetails(eventsWithDetailsData!)
      } //end of dispatch block
    })
  }
  
  @objc func updateCellArray()
  {
    getEventsWithDetails()
  }
  
  @IBAction func refreshEventCells(_ sender: Any?)
  {
    updateCellArray()
    //get cookie info
    OWWebAPI.shared.getCookieData()
  }
  
  func handleEmptyEventList()
  {
    DispatchQueue.main.async
      {// no data dispatch
        self.cellEventDetailArray = []
        self.cellEventDetailStringArray = []
        self.myEventsCollection.reloadData()
        //save empty array to userdefaults
        OWWebAPI.shared.saveEventsWithDetails([])
        self.activitySpinner.stopAnimating()
        self.spinnerView.isHidden = true
    }
  }
  
  func startTimeSinceUpdateTimer()
  {
    timeSinceFld.title = "0d 00:00"
    let darkGrayValue = 100.0
    let reddishValue = 160.0
    let colorValueInterval = reddishValue - darkGrayValue
    let colorValueIncrement = colorValueInterval / 10
    var redValue = darkGrayValue
    timeSinceUpdateTimer?.invalidate()
    timeSinceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { timeSinceUpdateTimer in
      if let lastUpdate = UserDefaults.standard.object(forKey: UDKeys.lastEventListUpdate) as? Date
      {
        let colorIncrementSeconds = convertAutoUpdateValueToSeconds() * 10
        var secondsSinceUpdate: TimeInterval = Date().timeIntervalSince(lastUpdate)
        var colorIncrementRatio = secondsSinceUpdate / Double(colorIncrementSeconds)
        if colorIncrementRatio > 1.0 { colorIncrementRatio = 1.0}
        redValue = darkGrayValue + colorValueInterval * colorIncrementRatio
        self.timeSinceFld.title = self.formatTimeInterval(seconds: secondsSinceUpdate)
        self.timeSinceFld.tintColor = UIColor(red: CGFloat(1.0 * redValue/255), green: CGFloat(1.0 * darkGrayValue/255), blue: CGFloat(1.0 * darkGrayValue/255), alpha: 1.0)
      } else {
        // no last update
      }
    })
  }
  
  func stopTimeSinceUpdateTimer()
  {
    timeSinceUpdateTimer?.invalidate()
  }
  
  func formatTimeInterval(seconds: TimeInterval) -> String
  {
    let intervalFomatter = DateComponentsFormatter()
    intervalFomatter.unitsStyle = .positional
    intervalFomatter.allowedUnits = [.day,.hour,.minute]
    intervalFomatter.zeroFormattingBehavior = .pad
    return intervalFomatter.string(from: seconds)!
  }
  
  func startSpinner()
  {
    self.spinnerView.isHidden = false
    self.activitySpinner.startAnimating()
  }
  
  func stopSpinner()
  {
    self.activitySpinner.stopAnimating()
    self.spinnerView.isHidden = true
  }
  
  func printEventWithDetails(_ eventAndDetails: EventWithDetails)
  {
    print()
    print("Id =", eventAndDetails.Id ?? "")
    print("Object =", eventAndDetails.Object ?? "")
    print("StarMag =", eventAndDetails.StarMag ?? "")
    print("MagDrop =", eventAndDetails.MagDrop ?? "")
    print("MaxDurSec =", eventAndDetails.MaxDurSec ?? "")
    print("EventTimeUtc =", eventAndDetails.EventTimeUtc ?? "")
    print("ErrorInTimeSec =", eventAndDetails.ErrorInTimeSec ?? "")
    print("WeatherInfoAvailable =", eventAndDetails.WeatherInfoAvailable ?? "")
    print("CloudCover =", eventAndDetails.CloudCover ?? "")
    print("Wind =", eventAndDetails.Wind ?? "")
    print("TempDegC =", eventAndDetails.TempDegC ?? "")
    print("HighCloud =", eventAndDetails.HighCloud ?? "")
    print("BestStationPos =", eventAndDetails.BestStationPos ?? "")
    print("StarColour =", eventAndDetails.StarColour ?? "")
    for station in eventAndDetails.Stations!
    {
      print(" StationID =",station.StationId ?? "")
      print("   StationName =",station.StationName ?? "")
      print("   EventTimeUtc =",station.EventTimeUtc ?? "")
      print("   WeatherInfoAvailable =",station.WeatherInfoAvailable ?? "")
      print("   CloudCover =",station.CloudCover ?? "")
      print("   Wind =",station.Wind ?? "")
      print("   TempDegC =",station.TempDegC ?? "")
      print("   HighCloud =",station.HighCloud ?? "")
      print("   StationPos =",station.StationPos ?? "")
      print("   ChordOffsetKm =",station.ChordOffsetKm ?? "")
      print("   OccultDistanceKm =",station.OccultDistanceKm ?? "")
      print("   IsOwnStation =",station.IsOwnStation!)
      print("   IsPrimaryStation =",station.IsPrimaryStation!)
      print("   ErrorInTimeSec =",station.ErrorInTimeSec!)
      print("   StarAlt =",station.StarAlt ?? "")
      print("   StarAz =",station.StarAz ?? "")
      print("   SunAlt =",station.SunAlt ?? "")
      print("   MoonAlt =",station.MoonAlt ?? "")
      print("   MoonAz =",station.MoonAz ?? "")
      print("   MoonDist =",station.MoonDist ?? "")
      print("   MoonPhase =",station.MoonPhase ?? "")
      print("   CombMag =",station.CombMag ?? "" )
      print("   StarColour =",station.StarColour ?? "")
      print("   Report =",station.Report ?? "")
      print("   ReportedDuration =",station.ReportedDuration ?? "")
      print("   ReportComment =",station.ReportComment ?? "")
      print("   CountryCode =",station.CountryCode ?? "")
    }
    print("Feed =",eventAndDetails.Feed ?? "")
    print("Rank =",eventAndDetails.Rank ?? "")
    print("BV =",eventAndDetails.BV ?? "")
    print("CombMag =",eventAndDetails.CombMag ?? "")
    print("AstMag =",eventAndDetails.AstMag ?? "")
    print("MoonDist =",eventAndDetails.MoonDist ?? "")
    print("MoonPhase =",eventAndDetails.MoonPhase ?? "")
    print("AstDiaKm =",eventAndDetails.AstDiaKm ?? "")
    print("AstDistUA =",eventAndDetails.AstDistUA ?? "")
    print("RAHours =",eventAndDetails.RAHours ?? "")
    print("DEDeg =",eventAndDetails.DEDeg ?? "")
    print("StarAlt =",eventAndDetails.StarAlt ?? "")
    print("StarAz =",eventAndDetails.StarAz ?? "")
    print("SunAlt =",eventAndDetails.SunAlt ?? "")
    print("MoonAlt =",eventAndDetails.MoonAlt ?? "")
    print("MoonAz =",eventAndDetails.MoonAz ?? "")
    print("StellarDiaMas =",eventAndDetails.StellarDiaMas ?? "")
    print("StarName =",eventAndDetails.StarName ?? "")
    print("OtherStarNames =",eventAndDetails.OtherStarNames ?? "")
    print("AstClass =",eventAndDetails.AstClass ?? "")
    print("AstRotationHrs =",eventAndDetails.AstRotationHrs ?? "")
    print("AstRotationAmplitude =",eventAndDetails.AstRotationAmplitude ?? "")
    print("PredictionUpdated =",eventAndDetails.PredictionUpdated ?? "")
    print("OneSigmaErrorWidthKm =",eventAndDetails.OneSigmaErrorWidthKm ?? "")
    print()
  }
  
  
}


extension MyEventsViewController
{
  // MARK: - Collection delegate functions
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return cellEventDetailArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyEventsCollectionViewCell
    cell.backgroundColor = #colorLiteral(red: 0.3058823529, green: 0.4941176471, blue: 0.5333333333, alpha: 0.67)
    fillCellFields(cell: &cell, indexPath: indexPath)
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    cell.addGestureRecognizer(longPress)
    return cell
  }
  
  func fillCellFields(cell: inout MyEventsCollectionViewCell, indexPath: IndexPath)
  {
    let calloutFont =   UIFont.preferredFont(forTextStyle: .callout)
    let captionFont =   UIFont.preferredFont(forTextStyle: .caption1)
    let primaryStation = OccultationEvent.primaryStation(cellEventDetailArray[indexPath.row])
    
    cell.objectText.text = cellEventDetailStringArray[indexPath.row].Object
    //create "m" superscript for star magnitude and magnitude drop
    let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,NSAttributedString.Key.baselineOffset: 5])
    
    cell.numberOfStationsText.text = String(format: "x%d",cellEventDetailArray[indexPath.row].Stations!.count)
    //   use combined mag rather than star mag
    let combMag = primaryStation!.CombMag
    let combMagStr = String(format: "%0.1f",combMag!)
    let combMagAttrStr = NSMutableAttributedString(string:combMagStr)
    combMagAttrStr.append(magAttrStr)
    cell.starMagText.attributedText = combMagAttrStr
    
    let magDropAttrStr = NSMutableAttributedString(string:cellEventDetailStringArray[indexPath.row].MagDrop, attributes:[NSAttributedString.Key.font : calloutFont])
    magDropAttrStr.append(magAttrStr)
    cell.magDropText.attributedText = magDropAttrStr
    cell.maxDurText.text = cellEventDetailStringArray[indexPath.row].MaxDurSec
    cell.leadTime.text = leadTime(timeString: cellEventDetailArray[indexPath.row].EventTimeUtc!)
    if cell.leadTime.text == "completed"
    {
      cell.leadTime.text = ""
      //dim/gray out asteriod hame, date and time
      cell.objectText.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.cloudText.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.eventTime.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.eventTime.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.leadTime.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.magDropText.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.maxDurText.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.starMagText.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.tempText.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.timeError.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
      cell.numberOfStationsText.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
    } else {
      cell.objectText.textColor = .white
      cell.cloudText.textColor = .white
      cell.eventTime.textColor = .white
      cell.eventTime.textColor = .white
      cell.leadTime.textColor = .white
      cell.magDropText.textColor = .white
      cell.maxDurText.textColor = .white
      cell.starMagText.textColor = .white
      cell.tempText.textColor = .white
      cell.timeError.textColor = .white
      cell.numberOfStationsText.textColor = .white
    }
    if appSettings.summaryTimeIsLocal
    {
      cell.eventTime.text = formatLocalEventTime(timeString: (primaryStation?.EventTimeUtc!)!)
    } else {
      cell.eventTime.text = formatUTCEventTime(timeString: (primaryStation?.EventTimeUtc!)!)
    }
    //set time error field
    if cellEventDetailArray[indexPath.row].ErrorInTimeSec != nil
    {
      let timeError = cellEventDetailArray[indexPath.row].ErrorInTimeSec
      if timeError! > 90.0
      {
        let errorInMin = timeError! / 60.0
        cell.timeError.text = String(format: "+/- %.01f min",errorInMin)
      } else {
        if timeError == -1
        {
          cell.timeError.text = "N/A"
        } else {
          cell.timeError.text = String(format: "+/- %.f sec",timeError!)
        }
      }
    }
    //cell images
    cell.maxDurImg.image = #imageLiteral(resourceName: "max_sign")
    cell.magDropImg.image = #imageLiteral(resourceName: "drop_sign")
    
    if cellEventDetailArray[indexPath.row].BestStationPos != nil
    {
      let sigmaIconValue = cellEventDetailArray[indexPath.row].BestStationPos!
      cell.sigmaImg.image = stationSigmaIcon(sigmaIconValue)   //set station sigma icon
    }
    
    if cellEventDetailArray[indexPath.row].StarColour != nil
    {
      cell.starMagImg.image = starColorIcon(cellEventDetailArray[indexPath.row].StarColour)
    }
    
    
    if primaryStation?.WeatherInfoAvailable != nil
    {
      //display weather info if forecast available, no display if no forecast
      if (primaryStation?.WeatherInfoAvailable)!
      {
        if primaryStation?.CloudCover != nil
        {
          let cloudCoverValue = (primaryStation?.CloudCover!)! * 10
          cell.cloudImg.image = cloudIcon(cloudCoverValue)   // set cloud % icon
          cell.cloudText.text = String(format: "%d%%",cloudCoverValue)
        }
        
        if primaryStation?.Wind != nil
        {
          let windStrengthIconValue = primaryStation?.Wind
          cell.windStrengthImg.image = windStrengthIcon(windStrengthIconValue)   //set wind strength icon
          cell.windyImg.image = windSignIcon(windStrengthIconValue)   //set wind strength icon
        }
        
        if primaryStation?.TempDegC != nil
        {
          let thermIconValue = primaryStation?.TempDegC
          cell.tempImg.image = thermIcon(thermIconValue)
          //set weather text to appropriate text
          if appSettings.tempIsCelsius
          {
            cell.tempText.text = String(format: "%d°C",(primaryStation?.TempDegC)!)
          } else {
            var tempF = celsiusToFahrenheit(degreesC: Double((primaryStation?.TempDegC)!))
            cell.tempText.text = String(format: "%d°F",Int(tempF.rounded()))
          }
        }
      } else {
        //set weather images and text empty because no forecast info is available
        cell.cloudImg.image =  nil
        cell.windStrengthImg.image =  nil
        cell.windyImg.image =  nil
        cell.tempImg.image =  nil
        cell.cloudText.text = ""
        cell.tempText.text = ""
      }
    }
  }
  
  @objc func handleLongPress(gesture: UILongPressGestureRecognizer)
  {
    if gesture.state == UIGestureRecognizer.State.began
    {
      let p = gesture.location(in: self.myEventsCollection)
      if let indexPath = self.myEventsCollection.indexPathForItem(at: p)
      {
        // get the cell at indexPath (the one you long pressed)
        eventStore.requestAccess(to: .event, completion: {(granted,error) -> Void in
          if granted && error == nil
          {
            let allEvents = OWWebAPI.shared.loadEventsWithDetails()
            let detailsIndex = allEvents.index(where: { $0.Id == self.cellEventDetailArray[indexPath.item].Id  })
            currentEvent.eventData = self.cellEventDetailArray[detailsIndex!]
            let primaryStation = OccultationEvent.primaryStation(allEvents[detailsIndex!])
            do
            {
              DispatchQueue.main.async
                {
                  let event = EKEvent(eventStore: self.eventStore)
                  event.title = self.cellEventDetailStringArray[indexPath.row].Object
                  event.location = primaryStation!.StationName
                  let eventStartUTC = utcStrToUTCDate(eventTimeStr: primaryStation!.EventTimeUtc!)
                  event.startDate = eventStartUTC
                  let eventEndUTC = event.startDate.addingTimeInterval( (self.cellEventDetailArray[indexPath.row].MaxDurSec!))
                  event.endDate = eventEndUTC
                  var noteStr = self.cellEventDetailStringArray [indexPath.row].Object + " occults " +  allEvents[detailsIndex!].StarName!
                  noteStr.append("\nRank: " + String(format: " %d ",allEvents[detailsIndex!].Rank!))
                  noteStr.append(", Chord: " + String(format: " %0.1f km ",primaryStation!.ChordOffsetKm!))
                  noteStr.append("\nmax duration: " + String(format: " %0.1f sec",allEvents[detailsIndex!].MaxDurSec!))
                  noteStr.append("\ncombined mag: " + String(format: " %0.1f ", primaryStation!.CombMag!))
                  noteStr.append(", mag drop: " + String(format: " %0.1f ",allEvents[detailsIndex!].MagDrop!))
                  let raTuple = floatRAtoHMS(floatRA: allEvents[detailsIndex!].RAHours!)
                  let raStr = String(format: "%02dh %02dm %04.1fs",raTuple.hours,raTuple.minutes,raTuple.seconds)
                  noteStr.append("\nRA: " + raStr)
                  let decTuple = floatDecToDMS(floatDegrees: allEvents[detailsIndex!].DEDeg!)
                  let decStr = String(format: "%02d° %02d' %04.1fs\"",decTuple.degrees,decTuple.minutes,decTuple.seconds)
                  noteStr.append(", Dec: " + decStr)
                  noteStr.append("\nAlt: " + String(format: " %0.1f° ",primaryStation!.StarAlt!))
                  noteStr.append(", Az: " + String(format: " %0.1f° ",primaryStation!.StarAz!))
                  event.notes = noteStr
                  
                  self.vc.editViewDelegate = self as EKEventEditViewDelegate
                  self.vc.event = nil
                  self.vc.event = event
                  self.vc.eventStore = self.eventStore   //????????
                  self.present(self.vc, animated: true, completion: nil )
              }
            } catch let error as NSError {
              print("failed to save event with error \(error)")
            }
            print("saved event")
          } else {
            print("failed to save event with error \(String(describing: error)) or access not granted")
          }
        })
      } else {
        print("couldn't find index path")
      }
    }
    if gesture.state == UIGestureRecognizer.State.ended
    {
      //      print("long press gesture ended")
    }
  }
  
  func assignEventDetailStrings(eventPlusDetails: [EventWithDetails?]) -> [EventDetailStrings]
  {
    var eventDetailStringArray = [EventDetailStrings]()
    for (_, event) in eventPlusDetails.enumerated()
    {
      var eventStrings = EventDetailStrings()
      let primaryStation = OccultationEvent.primaryStation(event!)
      if event!.Id != nil { eventStrings.Id = event!.Id ?? "" }
      if event!.Object != nil { eventStrings.Object = event!.Object ?? "" }
      eventStrings.Object = eventStrings.Object.replacingOccurrences(of: "(-2147483648) ", with: "")
      if event!.StarMag != nil
      {
        eventStrings.StarMag = String(format: "%.01f",event!.StarMag!)
      }
      if event!.MagDrop != nil
      {
        if event!.MagDrop! >= 0.2
        {
          eventStrings.MagDrop = String(format: "%.01f",event!.MagDrop!)
        }
        else
        {
          eventStrings.MagDrop = String(format: "%.02f",event!.MagDrop!)
        }
      }
      if event!.MaxDurSec != nil
      {
        eventStrings.MaxDurSec = String(format: "%.01f",event!.MaxDurSec!)
      }
      if event!.EventTimeUtc != nil { eventStrings.EventTimeUtc = event!.EventTimeUtc! }
      if event!.ErrorInTimeSec != nil
      {
        eventStrings.ErrorInTimeSec = String(format: "%.01f",event!.ErrorInTimeSec!)
      }
      if event!.WeatherInfoAvailable != nil
      {
        eventStrings.WeatherInfoAvailable = String(format: "%@",event!.WeatherInfoAvailable!.description)
      }
      if event!.CloudCover != nil
      {
        eventStrings.CloudCover = String(format: "%d",event!.CloudCover!)
      }
      if event!.Wind != nil
      {
        eventStrings.Wind = String(format: "%d",event!.Wind!)
      }
      if event!.TempDegC != nil
      {
        eventStrings.TempDegC = String(format: "%d",event!.TempDegC!)
      }
      if event!.HighCloud != nil
      {
        eventStrings.HighCloud = String(format: "%@",event!.HighCloud!.description)
      }
      if event!.BestStationPos != nil
      {
        eventStrings.BestStationPos = String(format: "%d",event!.BestStationPos!)
      }
      if primaryStation!.StarColour != nil
      {
        eventStrings.StarColour = String(format: "%d",primaryStation!.StarColour!)
      }
      eventDetailStringArray.append(eventStrings)
    }
    return eventDetailStringArray
  }
  
  func printEventInfo(eventItem item: Event)
  {
    print()
    print("Id =", item.Id ?? "")
    print("Object =", item.Object ?? "")
    print("StarMag =", item.StarMag ?? "")
    print("MagDrop =", item.MagDrop ?? "")
    print("MaxDurSec =", item.MaxDurSec ?? "")
    print("EventTimeUtc =", item.EventTimeUtc ?? "")
    print("ErrorInTimeSec =", item.ErrorInTimeSec ?? "")
    print("WeatherInfoAvailable =", item.WeatherInfoAvailable ?? "")
    print("CloudCover =", item.CloudCover ?? "")
    print("Wind =", item.Wind ?? "")
    print("TempDegC =", item.TempDegC ?? "")
    print("HighCloud =", item.HighCloud ?? "")
    print("BestStationPos =", item.BestStationPos ?? "")
    print("StarColour =",item.StarColour ?? "")
  }
  
}

// MARK: - OW Web API functions

extension MyEventsViewController: OWWebAPIDelegate
{
  func webLogTextDidChange(text: String)
  {
    DispatchQueue.main.async
      {
        self.spinnerLbl.text = text
    }
  }
}


extension MyEventsViewController: EKEventEditViewDelegate
{
  func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)
  {
    controller.dismiss(animated: true, completion: nil)
  }
}
