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
  
  let reuseIdentifier = "MyEventCell"
  var cellDataArray = [Event?]()
  var cellEventDetailArray = [EventWithDetails]()  //for rework
  var cellStringArray = [EventStrings]()
  var cellEventDetailStringArray = [EventDetailStrings]()
  var eventsWithDetails = MyEventListDetails(eventList: [], eventsDetails: [])
  var eventsWithDetailsData = EventWithDetails()
  var eventStore = EKEventStore()
  let vc = EKEventEditViewController()
  
  var eventCompleted: Bool = false

  
//  var tempIndexPath = IndexPath()

//  let OWWebAPI.shared = OWWebAPI.shared
  
  @IBAction func switchToLogin(_ sender: Any)
  {
    tabBarController?.selectedIndex = 1
  }
  
  // MARK: - View functions
  override func viewWillLayoutSubviews()
  {
   super.viewWillLayoutSubviews()
    myEventsCollection.collectionViewLayout.invalidateLayout()
    //set cell size
    let cellsInRow = 1
    let cellHeight = 180
    //set layout attributes
    if let flowLayout = self.myEventsCollection.collectionViewLayout as? UICollectionViewFlowLayout
    {
      flowLayout.minimumLineSpacing = 15
      flowLayout.minimumInteritemSpacing = 3
      flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      //?does this work for all screen sizes and orientations?
      let cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width - totalHInsets
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.spinnerView.layer.cornerRadius = 20
    OWWebAPI.shared.delegate = self
    myEventsCollection.backgroundColor =  _ColorLiteralType(red: 0.03605184332, green: 0.2271486223, blue: 0.2422576547, alpha: 1)
    // show alert displaying last update and asking update or use existing event list
    var alertTitle = ""
    var alertMsg = ""
    var alertExistingBtn = ""
    loadCredentailsFromKeyChain()
    var lastUpdateAlert = UIAlertController()
    if let lastUpdate = UserDefaults.standard.object(forKey: UDKeys.lastEventListUpdate) as? Date
    {
      // lastUpdate is valid, therefore previous event list is stored in UserDefaults
      // show alert asking update or use existing
//      print("lastUpdate has valid value")
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
      DispatchQueue.main.async{print("else > ")}
      
      alertTitle = "Event List for User \n" + Credentials.username + "\nNot Updated"
      alertMsg = "Update Now?"
    }
    
    lastUpdateAlert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
    lastUpdateAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: {_ in
      //handle the update      print("peform the update")
//      self.cellDataArray = OWWebAPI.shared.loadEvents()
       self.updateCellArray()
    }))
    if alertExistingBtn == "Use Existing"
    {
      lastUpdateAlert.addAction(UIAlertAction(title: alertExistingBtn, style: .default, handler: {_ in
       //restore existing list
//        print("Use Existing tapped")
        
        self.assignEventsWithDetails()
        
        self.cellDataArray = OWWebAPI.shared.loadEvents()
//        UserDefaults.standard.removeObject(forKey: UDKeys.lastEventListUpdate)
        self.cellStringArray = self.assignMyEventStrings(myEvents: self.cellDataArray)
        DispatchQueue.main.async{self.myEventsCollection.reloadData()}
      }))
    }
    lastUpdateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
      print("Cancel button tapped")
//      UserDefaults.standard.removeObject(forKey: UDKeys.lastEventListUpdate)
    }) )

    self.present(lastUpdateAlert, animated: true, completion: nil)
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                    NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
   }
  
  override func viewWillAppear(_ animated: Bool)
  {
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                    NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]

    //set cell size
//    let cellsInRow = 1
//    let cellHeight = 180
    //set layout attributes
//    if let flowLayout = self.myEventsCollection.collectionViewLayout as? UICollectionViewFlowLayout
//    {
//      print("UIScreen.main.bounds.width=",UIScreen.main.bounds.width)
//      print("myEventsCollection.bounds.width=",myEventsCollection.bounds.width)
//      flowLayout.minimumLineSpacing = 5
//      flowLayout.minimumInteritemSpacing = 3
//      flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 7, right: 5)
//      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
//      print("totalHInsets=",totalHInsets)
//      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
//      print("totalInteritemSpace=",totalInteritemSpace)
//      let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
////            let cellWidth = (myEventsCollection.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
//      //      print("cellWidth=",cellWidth)
//      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
//    }
    
    loadCredentailsFromKeyChain()
//    print("Credentials=",Credentials.username,"   ",Credentials.password)
    self.cellStringArray = self.assignMyEventStrings(myEvents: self.cellDataArray)

  }
  
  override func viewDidAppear(_ animated: Bool)
  {
    if userHasChanged
    {
      let userChangeAlert = UIAlertController(title: "User Has Changed to \n" + Credentials.username, message: "Update Event List?", preferredStyle: .alert)
      //add action to update user
      userChangeAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: {_ in
//        print("Yes was tapped")
        //handle the user change
        self.refreshEventCells(nil)
        userHasChanged = false
      })
      )
      userChangeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
        self.cellDataArray = []
        self.myEventsCollection.reloadData()
        OWWebAPI.shared.saveEvents([])
        OWWebAPI.shared.saveDetails([])
        UserDefaults.standard.removeObject(forKey: UDKeys.lastEventListUpdate)
      }) )
      self.present(userChangeAlert, animated: true, completion: nil)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
//    print("prepare(for seque")
    if segue.identifier == "DetailSegue"
    {
//      print("segue.identifier=",segue.identifier)
      

      
      if let dest = segue.destination as? DetailViewController,
        let index = myEventsCollection.indexPathsForSelectedItems?.first
      {
//        let eventDetails = OWWebAPI.shared.loadDetails()
//        let detailsIndex = eventDetails.index(where: { $0.Id == cellDataArray[index.item]!.Id  })
//        print("detailsIndex=", detailsIndex)
        
        dest.selection = cellDataArray[index.row]!.Object
        dest.detailData = cellDataArray[index.row]!
        dest.eventID = cellDataArray[index.row]!.Id!
        let timeRemaining = leadTime(timeString: cellDataArray[index.row]!.EventTimeUtc!)
        if timeRemaining == "completed"
        {eventCompleted = true} else {eventCompleted = false}
        if eventCompleted
        {
//          print("set dest.complete to true")
          dest.complete = eventCompleted
        }
        else {
//          print("set dest.complete to false")
         dest.complete = false
        }

//        print("DetailSegue > dest.complete=",dest.complete)
      }
    }
  }
  
  // MARK: - Event data functions
  //retrieve json, parse json, use closure to fill cells
  
  func getEventsWithDetails()
  {
    DispatchQueue.main.async
      {
        self.spinnerView.isHidden = false
        self.activitySpinner.startAnimating()
    }
    OWWebAPI.shared.retrieveEventsWithDetails(completion: { (eventsWithDetailsData, error) in
      DispatchQueue.main.async
        {
          print("event count =",eventsWithDetailsData?.count)
          self.spinnerLbl.text = "Event List \n Download Complete..."
          for event in eventsWithDetailsData!
          {
            self.printEventWithDetails(event)
          }
          //fill cells
          if eventsWithDetailsData!.count < 1
          {
            DispatchQueue.main.async
              {
                self.cellDataArray = []
                self.cellStringArray = []
                self.myEventsCollection.reloadData()
                //                OWWebAPI.shared.saveEvents([])
                //                OWWebAPI.shared.saveDetails([])
                //save empty array to userdefaults
                self.activitySpinner.stopAnimating()
                self.spinnerView.isHidden = true
            }
            return
          }
          self.cellEventDetailArray = eventsWithDetailsData!
          self.cellEventDetailStringArray = self.assignEventDetailStrings(eventPlusDetails: self.cellEventDetailArray)
          
                DispatchQueue.main.async{self.spinnerLbl.text = "Updating Events..."}
                DispatchQueue.main.async{self.myEventsCollection.reloadData()}
                usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
                DispatchQueue.main.async
                  {
                  self.activitySpinner.stopAnimating()
                  self.spinnerView.isHidden = true
                  }
          DispatchQueue.main.async{self.myEventsCollection.reloadData()}

      }
    })
    //          OWWebAPI.shared.saveEvents(myEvents!)
    //store update date in userDefaults
    //          UserDefaults.standard.set(Date(), forKey: UDKeys.lastEventListUpdate)
  }

  func printEventWithDetails(_ eventAndDetails: EventWithDetails)
  {
      print()
      print("Id =", eventAndDetails.Id!)
      print("Object =", eventAndDetails.Object!)
      print("StarMag =", eventAndDetails.StarMag!)
      print("MagDrop =", eventAndDetails.MagDrop!)
      print("MaxDurSec =", eventAndDetails.MaxDurSec!)
      print("EventTimeUtc =", eventAndDetails.EventTimeUtc!)
      print("ErrorInTimeSec =", eventAndDetails.ErrorInTimeSec!)
      print("WeatherInfoAvailable =", eventAndDetails.WeatherInfoAvailable!)
      print("CloudCover =", eventAndDetails.CloudCover!)
      print("Wind =", eventAndDetails.Wind!)
      print("TempDegC =", eventAndDetails.TempDegC!)
      print("HighCloud =", eventAndDetails.HighCloud!)
      print("BestStationPos =", eventAndDetails.BestStationPos!)
      print("StarColour =", eventAndDetails.StarColour!)
      for station in eventAndDetails.Stations!
      {
        print(" StationID =",station.StationId!)
        print("   StationName =",station.StationName!)
        print("   EventTimeUtc =",station.EventTimeUtc!)
        print("   WeatherInfoAvailable =",station.WeatherInfoAvailable!)
        print("   CloudCover =",station.CloudCover!)
        print("   Wind =",station.Wind!)
        print("   TempDegC =",station.TempDegC!)
        print("   HighCloud =",station.HighCloud!)
        print("   StationPos =",station.StationPos!)
        print("   ChordOffsetKm =",station.ChordOffsetKm!)
        print("   OccultDistanceKm =",station.OccultDistanceKm!)
        print("   IsOwnStation =",station.IsOwnStation!)
        print("   IsPrimaryStation =",station.IsPrimaryStation!)
        print("   ErrorInTimeSec =",station.ErrorInTimeSec!)
        print("   StarAlt =",station.StarAlt!)
        print("   StarAz =",station.StarAz!)
        print("   SunAlt =",station.SunAlt!)
        print("   MoonAlt =",station.MoonAlt!)
        print("   MoonAz =",station.MoonAz!)
        print("   MoonDist =",station.MoonDist!)
        print("   MoonPhase =",station.MoonPhase!)
        print("   CombMag =",station.CombMag!)
        print("   StarColour =",station.StarColour!)
      }
      print("Feed =",eventAndDetails.Feed!)
      print("Rank =",eventAndDetails.Rank!)
      print("BV =",eventAndDetails.BV)
      print("CombMag =",eventAndDetails.CombMag!)
      print("AstMag =",eventAndDetails.AstMag!)
      print("MoonDist =",eventAndDetails.MoonDist!)
      print("MoonPhase =",eventAndDetails.MoonPhase!)
      print("AstDiaKm =",eventAndDetails.AstDiaKm!)
      print("AstDistUA =",eventAndDetails.AstDistUA!)
      print("RAHours =",eventAndDetails.RAHours!)
      print("DEDeg =",eventAndDetails.DEDeg!)
      print("StarAlt =",eventAndDetails.StarAlt!)
      print("StarAz =",eventAndDetails.StarAz!)
      print("SunAlt =",eventAndDetails.SunAlt!)
      print("MoonAlt =",eventAndDetails.MoonAlt!)
      print("MoonAz =",eventAndDetails.MoonAz!)
      print("StellarDiaMas =",eventAndDetails.StellarDiaMas)
      print("StarName =",eventAndDetails.StarName!)
      print("OtherStarNames =",eventAndDetails.OtherStarNames!)
      print("AstClass =",eventAndDetails.AstClass!)
      print("AstRotationHrs =",eventAndDetails.AstRotationHrs)
      print("AstRotationAmplitude =",eventAndDetails.AstRotationAmplitude)
      print("PredictionUpdated =",eventAndDetails.PredictionUpdated!)
      print("OneSigmaErrorWidthKm =",eventAndDetails.OneSigmaErrorWidthKm!)
     print()

  }
  
  func updateCellArray()
  {
    //temporary test
    getEventsWithDetails()
    return
    //
    
    
    DispatchQueue.main.async
      {
        self.spinnerView.isHidden = false
        self.activitySpinner.startAnimating()
      }
    DispatchQueue.main.async{self.spinnerLbl.text = "Event List \n Retrieving..."}
    usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
    OWWebAPI.shared.retrieveEventList(completion: { (myEvents, error) in
      //fill cells
      if myEvents!.count < 1
      {
        DispatchQueue.main.async
          {
            self.cellDataArray = []
            self.cellStringArray = []
            self.myEventsCollection.reloadData()
            OWWebAPI.shared.saveEvents([])
            OWWebAPI.shared.saveDetails([])
            self.activitySpinner.stopAnimating()
            self.spinnerView.isHidden = true
        }
        return
      }
      
      DispatchQueue.main.async{self.spinnerLbl.text = "Event List \n Download and Parsing Complete"}
      usleep(useconds_t(1.0 * 1000000)) //will sleep for 0.5 seconds)
      var itemIndex = 0
      var myEventListDetails: [EventDetails] = []
            for item in myEvents!
            {
              DispatchQueue.main.async
                {
                  self.spinnerView.isHidden = false
                  self.activitySpinner.startAnimating()
              }
              OWWebAPI.shared.retrieveEventDetails(eventID: item.Id!) { (myDetails, error) in
                itemIndex = itemIndex + 1
                var spinnerText = String(format:"Event Details \n %d of %d Downloaded",itemIndex,myEvents!.count)
                DispatchQueue.main.async{self.spinnerLbl.text = spinnerText}
                usleep(useconds_t(0.2 * 1000000)) //will sleep for 0.5 seconds
                myEventListDetails.append(myDetails!)
                DispatchQueue.main.async
                {
                  if itemIndex == myEvents!.count
                  {
                    OWWebAPI.shared.saveDetails(myEventListDetails)
                    
                    self.assignEventsWithDetails()

                    DispatchQueue.main.async
                      {
//                        print("########################")
//                        print("fillCellFields > eventsWithDetails > events = \n",self.eventsWithDetails.eventList)
//                        print("------------------------")
//                        print("fillCellFields > eventsWithDetails > details = \n",self.eventsWithDetails.eventsDetails)
                        for (index, event) in self.eventsWithDetails.eventList.enumerated()
                        {
                          print("~~~~~~~~~~~~")
                          print("event = ", event)
                          print("details = ",self.eventsWithDetails.eventsDetails[index])
                        }
                      }
                    self.activitySpinner.stopAnimating()
                    self.spinnerView.isHidden = true
//                    print("\n\n\n\n\n")
//                    print("reload after details retrieval completion")
                    DispatchQueue.main.async{self.myEventsCollection.reloadData()}
                  }
                }
              }
      }
      OWWebAPI.shared.saveEvents(myEvents!)
      
      //store update date in userDefaults
      UserDefaults.standard.set(Date(), forKey: UDKeys.lastEventListUpdate)
      
      
      self.cellDataArray = myEvents!
      self.cellStringArray = self.assignMyEventStrings(myEvents: self.cellDataArray)
//      print("cellStringArray = ",self.cellStringArray)
      
      
      
//      print("cell data array updated")
      DispatchQueue.main.async{self.spinnerLbl.text = "Updating Events..."}
//      print("\n\n\n\n\n")
//      print("reload after events retrieval completion")
      DispatchQueue.main.async{self.myEventsCollection.reloadData()}
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
//      DispatchQueue.main.async
//        {
//        self.activitySpinner.stopAnimating()
//        self.spinnerView.isHidden = true
//        }
//      print("invalidate owSession")
//      OWWebAPI.owSession.invalidateAndCancel()
    })
  }
  
  @IBAction func refreshEventCells(_ sender: Any?)
  {
    updateCellArray()
    
    //get cookie info
    OWWebAPI.shared.getCookieData()
  }
  
  // MARK: - Utility functions
  

}




extension MyEventsViewController
{
  // MARK: - Collection delegate functions
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
//    print("numberOfItemsInSection=",cellDataArray.count)
//    return cellDataArray.count
    return cellEventDetailArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
//    print("cellForItemAt")
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyEventsCollectionViewCell
    //set permanent cell background color to 235_255_235_67
    cell.backgroundColor = #colorLiteral(red: 0.3058823529, green: 0.4941176471, blue: 0.5333333333, alpha: 0.67)
    fillCellFields(cell: &cell, indexPath: indexPath)
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    cell.addGestureRecognizer(longPress)
//    tempIndexPath = indexPath
    return cell
  }
  
  @objc func handleLongPress(gesture: UILongPressGestureRecognizer)
  {
    if gesture.state == UIGestureRecognizer.State.began
    {
      print("long press gesture began")
      let p = gesture.location(in: self.myEventsCollection)
      
      if let indexPath = self.myEventsCollection.indexPathForItem(at: p)
      {
        // get the cell at indexPath (the one you long pressed)
        //        let cell = self.myEventsCollection.cellForItem(at: indexPath)
        //        print("point indexPath = ",indexPath)
        print("point indexPath.item = ",indexPath.item)
        print("cellDataArray[indexPath.item]=",cellDataArray[indexPath.item])
        print("create calender event entry")
        
        //        var eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: {(granted,error) -> Void in
          if granted && error == nil
          {
            print("granted = \(granted)")
            print("error = \(error)")
            print("point indexPath.item = ",indexPath.item)
            let allDetails = OWWebAPI.shared.loadDetails()
            //            print("selected Details=",allDetails[indexPath.item])
            //            for eventDetails in allDetails
            //            {
            //              print("eventDetails=",eventDetails)
            //              print()
            //            }
            
            //            let detailsIndex = self.cellDataArray.index(where: { $0!.Id == allDetails[indexPath.item].Id  })
            let detailsIndex = allDetails.index(where: { $0.Id == self.cellDataArray[indexPath.item]?.Id  })
            print("detailsIndex=",detailsIndex)
            print("allDetails[detailsIndex]=",allDetails[detailsIndex!])
            var selectedEvent = OccultationEvent()
            let primaryStation = selectedEvent.primaryStation(allDetails[detailsIndex!])
            do
            {
              DispatchQueue.main.async
                {
                  var event = EKEvent(eventStore: self.eventStore)
                  event.title = self.cellStringArray[indexPath.row].Object
                  event.location = primaryStation!.StationName
                  let eventStartUTC = utcStrToDate(eventTimeStr: primaryStation!.EventTimeUtc!)
                  event.startDate = eventStartUTC
                  let eventEndUTC = event.startDate.addingTimeInterval( (self.cellDataArray[indexPath.row]?.MaxDurSec!)!)
                  event.endDate = eventEndUTC
                  var noteStr = self.cellStringArray[indexPath.row].Object + " occults " +  allDetails[detailsIndex!].StarName!
//                  noteStr.append("\nstart: " + primaryStation!.EventTimeUtc! )
                  noteStr.append("\nRank: " + String(format: " %d ",allDetails[detailsIndex!].Rank!))
                  noteStr.append(", Chord: " + String(format: " %0.1f km ",primaryStation!.ChordOffsetKm!))
                  noteStr.append("\nmax duration: " + String(format: " %0.1f sec",allDetails[detailsIndex!].MaxDurSec!))
                  noteStr.append("\ncombined mag: " + String(format: " %0.1f ",allDetails[detailsIndex!].CombMag!))
                  noteStr.append(", mag drop: " + String(format: " %0.1f ",allDetails[detailsIndex!].MagDrop!))
                  let raTuple = floatRAtoHMS(floatRA: allDetails[detailsIndex!].RAHours!)
                  let raStr = String(format: "%02dh %02dm %04.1fs",raTuple.hours,raTuple.minutes,raTuple.seconds)
                  noteStr.append("\nRA: " + raStr)
//                  noteStr.append("\nRA: " + String(format: " %0.1f ",allDetails[detailsIndex!].RAHours!))
                  noteStr.append(", Dec: " + String(format: " %0.1f° ",allDetails[detailsIndex!].DEDeg!))
                  noteStr.append("\nAlt: " + String(format: " %0.1f° ",allDetails[detailsIndex!].StarAlt!))
                  noteStr.append(", Az: " + String(format: " %0.1f° ",allDetails[detailsIndex!].StarAz!))
                  event.notes = noteStr
                  
                  self.vc.editViewDelegate = self as? EKEventEditViewDelegate
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
            print("failed to save event with error \(error) or access not granted")
          }
        })
        
      } else {
        print("couldn't find index path")
      }
      
    }
    if gesture.state == UIGestureRecognizer.State.ended
    {
      print("long press gesture ended")
    }
  }
    
    func fillCellFields(cell: inout MyEventsCollectionViewCell, indexPath: IndexPath)
    {
      let calloutFont =   UIFont.preferredFont(forTextStyle: .callout)
      let captionFont =   UIFont.preferredFont(forTextStyle: .caption1)
       cell.objectText.text = cellEventDetailArray[indexPath.row].Object
      //create "m" superscript for star magnitude and magnitude drop
      let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,
                                                                         NSAttributedString.Key.baselineOffset: 5])
//      let events = OWWebAPI.shared.loadEvents()
//      let events = eventsWithDetails
//      if events.count == eventsWithDetails.eventsDetails.count
//      {
//        //use combined mag rather than star mag
//        let combMag = eventsWithDetails.eventsDetails[indexPath.row].CombMag
//        let combMagStr = String(format: "%0.1f",combMag!)
//        let combMagAttrStr = NSMutableAttributedString(string:combMagStr)
//        combMagAttrStr.append(magAttrStr)
//        cell.starMagText.attributedText = combMagAttrStr
//      } else {
//        let starMagStr = cellStringArray[indexPath.row].StarMag
//        let starMagAttrStr = NSMutableAttributedString(string:starMagStr)
//        starMagAttrStr.append(magAttrStr)
//        cell.starMagText.attributedText = starMagAttrStr
//      }
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
      }
      
      cell.eventTime.text = formatEventTime(timeString: cellEventDetailStringArray[indexPath.row].EventTimeUtc)
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
        var sigmaIconValue = cellEventDetailArray[indexPath.row].BestStationPos!
        cell.sigmaImg.image = stationSigmaIcon(sigmaIconValue)   //set station sigma icon
      }
      
      if cellEventDetailArray[indexPath.row].StarColour != nil
      {
        cell.starMagImg.image = starColorIcon(cellEventDetailArray[indexPath.row].StarColour)
      }
      

      if cellEventDetailArray[indexPath.row].WeatherInfoAvailable != nil
      {
        //display weather info if forecast available, no display if no forecast
        if cellEventDetailArray[indexPath.row].WeatherInfoAvailable!
        {
          if cellEventDetailArray[indexPath.row].CloudCover != nil
          {
            var cloudIconValue = cellEventDetailArray[indexPath.row].CloudCover
            cell.cloudImg.image = cloudIcon(cloudIconValue)   // set cloud % icon
            cell.cloudText.text = String(format: "%d%%",cellEventDetailArray[indexPath.row].CloudCover!)
          }
          
          if cellEventDetailArray[indexPath.row].Wind != nil
          {
            var windStrengthIconValue = cellEventDetailArray[indexPath.row].Wind
  //          windStrengthIconValue = 0
            cell.windStrengthImg.image = windStrengthIcon(windStrengthIconValue)   //set wind strength icon
            cell.windyImg.image = windSignIcon(windStrengthIconValue)   //set wind strength icon
          }

           if cellEventDetailArray[indexPath.row].TempDegC != nil
          {
            var thermIconValue = cellEventDetailArray[indexPath.row].TempDegC
            cell.tempImg.image = thermIcon(thermIconValue)
            //set weather text to appropriate text
            cell.tempText.text = String(format: "%d°",cellEventDetailArray[indexPath.row].TempDegC!)
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
    
    func fillCellFields_Old(cell: inout MyEventsCollectionViewCell, indexPath: IndexPath)
    {
      let calloutFont =   UIFont.preferredFont(forTextStyle: .callout)
      let captionFont =   UIFont.preferredFont(forTextStyle: .caption1)
  //    let eventsStrings = self.assignMyEventStrings(myEvents: self.cellDataArray)
      //cell text
  //    cell.objectText.text = cellDataArray[indexPath.row]!.Object
  //    cell.objectText.text = myEventsStrings.Object
      cell.objectText.text = cellStringArray[indexPath.row].Object
  //    print("object=",cellStringArray[indexPath.row].Object)

      //create "m" superscript for star magnitude and magnitude drop
      let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,
                                                                         NSAttributedString.Key.baselineOffset: 5])
      let events = OWWebAPI.shared.loadEvents()
  //    let eventDetails = OWWebAPI.shared.loadDetails()
  //    print("########################")
  //    print("fillCellFields > eventsWithDetails > events = \n",eventsWithDetails.eventList)
  //    print("------------------------")
  //    print("fillCellFields > eventsWithDetails > details = \n",eventsWithDetails.eventsDetails)

  //    for (index, event) in events.enumerated()
  //    {
  //      print()
  //      print("event.Id = ",event.Id)
  ////      print("indexPath.row=",indexPath.row)
  //      let detailsIndex = eventDetails.index(where: { $0.Id == event.Id  })
  ////      print("detailsIndex=", detailsIndex)
  //      print("details.Id = ", eventDetails[detailsIndex!].Id)
  //    }

  //    print("°°°°events.count=",events.count)
  //    print("°°°°eventDetails.count=",eventDetails.count)
      
      
      
      if events.count == eventsWithDetails.eventsDetails.count
      {
        //use combined mag rather than star mag
        let combMag = eventsWithDetails.eventsDetails[indexPath.row].CombMag
        let combMagStr = String(format: "%0.1f",combMag!)
        let combMagAttrStr = NSMutableAttributedString(string:combMagStr)
        combMagAttrStr.append(magAttrStr)
        cell.starMagText.attributedText = combMagAttrStr
      } else {
        let starMagStr = cellStringArray[indexPath.row].StarMag
        let starMagAttrStr = NSMutableAttributedString(string:starMagStr)
        starMagAttrStr.append(magAttrStr)
        cell.starMagText.attributedText = starMagAttrStr
      }

      
      
  //    if cellDataArray[indexPath.row]!.MagDrop! >= 0.2
  //    {
  ////      let magDropStr = String(format: "%.01f",cellDataArray[indexPath.row]!.MagDrop)
  //      let magDropStr = String(format: "%.01f",cellDataArray[indexPath.row]!.MagDrop)
        let magDropAttrStr = NSMutableAttributedString(string:cellStringArray[indexPath.row].MagDrop, attributes:[NSAttributedString.Key.font : calloutFont])
  //      let magDropAttrStr = NSMutableAttributedString(string:magDropStr)
        magDropAttrStr.append(magAttrStr)
        cell.magDropText.attributedText = magDropAttrStr
  //    }
  //    else
  //    {
  //      let magDropStr = String(format: "%.02f",cellDataArray[indexPath.row]!.MagDrop)
  //      let magDropAttrStr = NSMutableAttributedString(string:magDropStr, attributes:[NSAttributedString.Key.font : calloutFont])
  //      magDropAttrStr.append(magAttrStr)
  //      cell.magDropText.attributedText = magDropAttrStr
  //    }
      cell.maxDurText.text = cellStringArray[indexPath.row].MaxDurSec
      cell.leadTime.text = leadTime(timeString: cellStringArray[indexPath.row].EventTimeUtc)
  //    print("check leadTime for completed")
      
      
      if cell.leadTime.text == "completed"
      {
  //      print("found completed")
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
      }
      
      
      cell.eventTime.text = formatEventTime(timeString: cellStringArray[indexPath.row].EventTimeUtc)
      //set time error field
      if cellDataArray[indexPath.row]!.ErrorInTimeSec != nil
      {
        let timeError = cellDataArray[indexPath.row]!.ErrorInTimeSec
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
      
      if cellDataArray[indexPath.row]!.BestStationPos != nil
      {
        var sigmaIconValue = cellDataArray[indexPath.row]!.BestStationPos!
        cell.sigmaImg.image = stationSigmaIcon(sigmaIconValue)   //set station sigma icon
      }
      
      if cellDataArray[indexPath.row]!.StarColour != nil
      {
        cell.starMagImg.image = starColorIcon(cellDataArray[indexPath.row]!.StarColour)
      }
      

      if cellDataArray[indexPath.row]!.WeatherInfoAvailable != nil
      {
        //display weather info if forecast available, no display if no forecast
        if cellDataArray[indexPath.row]!.WeatherInfoAvailable!
        {
          if cellDataArray[indexPath.row]!.CloudCover != nil
          {
            var cloudIconValue = cellDataArray[indexPath.row]!.CloudCover
            cell.cloudImg.image = cloudIcon(cloudIconValue)   // set cloud % icon
            cell.cloudText.text = String(format: "%d%%",cellDataArray[indexPath.row]!.CloudCover!)
          }
          
          if cellDataArray[indexPath.row]!.Wind != nil
          {
            var windStrengthIconValue = cellDataArray[indexPath.row]!.Wind
  //          windStrengthIconValue = 0
            cell.windStrengthImg.image = windStrengthIcon(windStrengthIconValue)   //set wind strength icon
            cell.windyImg.image = windSignIcon(windStrengthIconValue)   //set wind strength icon
          }

           if cellDataArray[indexPath.row]!.TempDegC != nil
          {
            var thermIconValue = cellDataArray[indexPath.row]?.TempDegC
            cell.tempImg.image = thermIcon(thermIconValue)
            //set weather text to appropriate text
            cell.tempText.text = String(format: "%d°",cellDataArray[indexPath.row]!.TempDegC!)
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

  func printEventInfo(eventItem item: Event)
  {
    print()
    print("Id =", item.Id)
    print("Object =", item.Object)
    print("StarMag =", item.StarMag)
    print("MagDrop =", item.MagDrop)
    print("MaxDurSec =", item.MaxDurSec)
    print("EventTimeUtc =", item.EventTimeUtc)
    print("ErrorInTimeSec =", item.ErrorInTimeSec)
    print("WeatherInfoAvailable =", item.WeatherInfoAvailable)
    print("CloudCover =", item.CloudCover)
    print("Wind =", item.Wind)
    print("TempDegC =", item.TempDegC)
    print("HighCloud =", item.HighCloud)
    print("BestStationPos =", item.BestStationPos)
    print("StarColour =",item.StarColour)
  }

  
    func assignMyEventStrings(myEvents: [Event?]) -> [EventStrings]
    {
      let calloutFont =   UIFont.preferredFont(forTextStyle: .callout)
      let captionFont =   UIFont.preferredFont(forTextStyle: .caption1)
      var myEventStrings = [EventStrings]()
      for (index, evnt) in myEvents.enumerated()
      {
        var event = evnt
  //      print("myEvents: index =",index,"   event=",event)
  //      myEventStrings.append(EventStrings(Id: "", Object: "", StarMag: "", MagDrop: "", MaxDurSec: "", EventTimeUtc: "", ErrorInTimeSec: "", WeatherInfoAvailable: "", CloudCover: "", Wind: "", TempDegC: "", HighCloud: "", BestStationPos: "", StarColour: ""))
        var eventStrings = EventStrings()
  //      print("myEventStrings=",myEventStrings)
        if event!.Id != nil { eventStrings.Id = event!.Id ?? "" }
  //      if event!.Object != nil { eventStrings.Object = event!.Object ?? "" }
        if event!.Object != nil { eventStrings.Object = event!.Object ?? "" }
  //      print("eventStrings.Object=",eventStrings.Object)
        
        //remove "bogus" number for planet satellite
        eventStrings.Object = eventStrings.Object.replacingOccurrences(of: "(-2147483648) ", with: "")
  //      print("eventStrings.Object=",eventStrings.Object)

        //*******check precision
        
         if event!.StarMag != nil
        {
  //        let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,
  //                                                                           NSAttributedString.Key.baselineOffset: 5])
  //        let starMagStr = String(format: "%.01f",event!.StarMag!)
  //        let starMagAttrStr = NSMutableAttributedString(string:starMagStr)
  //        starMagAttrStr.append(magAttrStr)
  //        cell.starMagText.attributedText = starMagAttrStr
          eventStrings.StarMag = String(format: "%.01f",event!.StarMag!)
        }

        if event!.MagDrop != nil
        {
          if event!.MagDrop! >= 0.2
          {
            //create "m" superscript for star magnitude and magnitude drop
  //          let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,
  //                                                                             NSAttributedString.Key.baselineOffset: 5])
  //          let starMagStr = myEventsStrings.StarMag
  //          let starMagAttrStr = NSMutableAttributedString(string:starMagStr)
  //          starMagAttrStr.append(magAttrStr)
  //          myEventStrings.StarMag.attributedText = starMagAttrStr

  //          let magDropStr = String(format: "%.01f",event!.MagDrop!)
            //      let magDropAttrStr = NSMutableAttributedString(string:magDropStr, attributes:[NSAttributedString.Key.font : calloutFont])
  //          let magDropAttrStr = NSMutableAttributedString(string:magDropStr)
  //          magDropAttrStr.append(magAttrStr)
            eventStrings.MagDrop = String(format: "%.01f",event!.MagDrop!)
          }
          else
          {
  //          let magDropStr = String(format: "%.02f",cellDataArray[indexPath.row]!.MagDrop)
  //          let magDropAttrStr = NSMutableAttributedString(string:magDropStr, attributes:[NSAttributedString.Key.font : calloutFont])
  //          magDropAttrStr.append(magAttrStr)
  //          cell.magDropText.attributedText = magDropAttrStr
            eventStrings.MagDrop = String(format: "%.02f",event!.MagDrop!)
          }

        }
        if event!.MaxDurSec != nil
        {
          eventStrings.MaxDurSec = String(format: "%.01f",event!.MaxDurSec!)
        }
        if event!.EventTimeUtc != nil { eventStrings.EventTimeUtc = event!.EventTimeUtc! }
        //***test***
        event!.ErrorInTimeSec = nil
        //***test***
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
        if event!.StarColour != nil
        {
          eventStrings.StarColour = String(format: "%d",event!.StarColour!)
        }
  //      print("eventStrings=",eventStrings)
        myEventStrings.append(eventStrings)
      }
  //    print()
  //    print("myEventStrings = ",myEventStrings)
      return myEventStrings
    }
    
    func assignEventDetailStrings(eventPlusDetails: [EventWithDetails?]) -> [EventDetailStrings]
    {
      let calloutFont =   UIFont.preferredFont(forTextStyle: .callout)
      let captionFont =   UIFont.preferredFont(forTextStyle: .caption1)
//       var myEventStrings = [EventStrings]()
      var eventDetailStringArray = [EventDetailStrings]()
      for (index, event) in eventPlusDetails.enumerated()
      {
        var eventStrings = EventDetailStrings()
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
        if event!.StarColour != nil
        {
          eventStrings.StarColour = String(format: "%d",event!.StarColour!)
        }
  //      print("eventStrings=",eventStrings)
        eventDetailStringArray.append(eventStrings)
      }
  //    print()
  //    print("myEventStrings = ",myEventStrings)
      return eventDetailStringArray
    }
    
  fileprivate func assignEventsWithDetails() {
    let tempEvents = OWWebAPI.shared.loadEvents()
    let tempDetails = OWWebAPI.shared.loadDetails()
    self.eventsWithDetails.eventList = []
    self.eventsWithDetails.eventsDetails = []
    self.eventsWithDetails.eventList = tempEvents
    for (index, event) in tempEvents.enumerated()
    {
//      print()
//      print("event.Id = ",event.Id)
      let detailsIndex = tempDetails.index(where: { $0.Id == event.Id  })
//      print("details.Id = ", tempDetails[detailsIndex!].Id)
      self.eventsWithDetails.eventsDetails.append(tempDetails[detailsIndex!])
    }
  }

}

// MARK: - OW Web API functions

extension MyEventsViewController: OWWebAPIDelegate
{
  func webLogTextDidChange(text: String)
  {
    DispatchQueue.main.async
      {
//        print("webLogTextDidChange>text to: ",text)
        self.spinnerLbl.text = text
    }
  }
}


extension MyEventsViewController: EKEventEditViewDelegate
{
  func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)
  {
    print("eventEditViewController > didCompleteWith")
    controller.dismiss(animated: true, completion: nil)
    print("eventEditViewController removed")
  }
}
