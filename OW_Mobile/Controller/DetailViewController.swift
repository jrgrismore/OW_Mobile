//  DetailViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 3/23/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

var sizeClassIsRR = false

class DetailViewController: UIViewController
{
  let reuseIdentifier = "StationCell"
  @IBOutlet weak var stationCollectionView: UICollectionView!
  
  var detailData =
    Event(Id:"",
          Object:"",
          StarMag:0.0,
          MagDrop:0.0,
          MaxDurSec:0.0,
          EventTimeUtc:"",
          ErrorInTimeSec:0.0,
          WeatherInfoAvailable:false,
          CloudCover:0,
          Wind:0,
          TempDegC:0,
          HighCloud:false,
          BestStationPos:0,
          StarColour:0
  )
  
  var originalSelectedEventId = ""
  var selectionObject: String!
  var detailStr: String = ""
  var eventID: String = ""
  var reportStationId: Int?
  var complete: Bool = false
  var selectedEvent = EventWithDetails()
  var eventsWithDetails = [EventWithDetails]()
  
  var selectedStations = [ObserverStation]()
  var event = OccultationEvent()
  var stationCursor = UIView()
  var visibleIndexPaths = [IndexPath]()
  var currentStationIndexPath = IndexPath()
  
  var stationBarSubViewsExist = false
  var stationCursorExists = false
  var dimGray = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
  let tickBar = UIView()

  
  
  // MARK: - Spinner Outlets
  @IBOutlet weak var spinnerView: UIView!
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var spinnerLbl: UILabel!
  
  // MARK: - Label Outlets
  @IBOutlet weak var eventTitle: UILabel!
  @IBOutlet weak var eventRank: UILabel!
  @IBOutlet weak var eventTimeRemaining: UILabel!
  @IBOutlet weak var eventFeed: UILabel!
  
  @IBOutlet weak var stationPageControl: UIPageControl!
  @IBOutlet weak var eventRA: UILabel!
  @IBOutlet weak var j2000Lbl: UILabel!
  @IBOutlet weak var eventDec: UILabel!
  @IBOutlet weak var eventStarBV: UILabel!
  @IBOutlet weak var eventStarDiameter: UILabel!
  
  @IBOutlet weak var eventAsteroidOrigin: UILabel!
  @IBOutlet weak var eventAsteroidDiameter: UILabel!
  @IBOutlet weak var eventStarMagnitude: UILabel!
  @IBOutlet weak var eventAsteroidMagnitude: UILabel!
  @IBOutlet weak var eventCombinedMagnitude: UILabel!
  @IBOutlet weak var eventMagnitudeDrop: UILabel!
  @IBOutlet weak var eventMaxDur: UILabel!
  
  @IBOutlet weak var eventCameraSectionTitle: UILabel!
  @IBOutlet weak var eventCamCombinedMag: UILabel!
  @IBOutlet weak var eventCamMagDrop: UILabel!
  @IBOutlet weak var eventCamAseroidRotation: UILabel!
  @IBOutlet weak var eventCamRotationAmplitude: UILabel!
  @IBOutlet weak var eventLat: UILabel!
  @IBOutlet weak var eventLon: UILabel!
  
  // MARK: - View Outlets
  @IBOutlet var eventDetailView: UIView!
  @IBOutlet weak var shadowSigmaView: UIView!
  @IBOutlet weak var weatherBarView: UIView!
  @IBOutlet weak var centerGrayBar: UIView!
  @IBOutlet weak var sigma3BarView: UIView!
  @IBOutlet weak var sigma2BarView: UIView!
  @IBOutlet weak var sigma1BarView: UIView!
  @IBOutlet weak var shadowBarView: UIView!
  @IBOutlet weak var centerBarView: UIView!
//  @IBOutlet weak var userBarView: UIView!
  @IBOutlet weak var userBarView: UIView!
  
  @IBOutlet weak var asterRotAmpView: UIStackView!
  @IBOutlet weak var bvStarDiamView: UIStackView!
  @IBOutlet weak var bottomGrayBar: UIView!
  
  @IBOutlet weak var reportBtn: UIButton!
  
  @IBOutlet weak var latLonStack: UIStackView!
  
  
  // MARK: - Constraint Outlets
  @IBOutlet weak var shadowBarWidth: NSLayoutConstraint!
  @IBOutlet weak var sigma1Width: NSLayoutConstraint!
  @IBOutlet weak var sigma2Width: NSLayoutConstraint!
  @IBOutlet weak var sigma3Width: NSLayoutConstraint!
  
  // MARK: - View functions
  override func viewDidLoad()
  {
//    print("viewDidLoad")
    super.viewDidLoad()
    stationCollectionView.delegate = self
    stationCollectionView.dataSource = self
    self.spinnerView.layer.cornerRadius = 20
    NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name:  UIDevice.orientationDidChangeNotification, object: nil)
    if self.view.traitCollection.horizontalSizeClass == .regular && self.view.traitCollection.verticalSizeClass == .regular
    {
      sizeClassIsRR = true
    }
    self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    NotificationCenter.default.addObserver(self, selector: #selector(handleEventTimer), name: NSNotification.Name(rawValue: NotificationKeys.dataRefreshIsDone), object: nil)
  }
  
//  @objc func testHandleEventTimer()
//  {
//    print("DetailViewController > testHandleEventTimer")
//  }
  @objc func handleEventTimer()
  {
    print("DetailViewController > handleEventTimer")
    DispatchQueue.main.async {
      self.eventsWithDetails = OWWebAPI.shared.loadEventsWithDetails()
      print("eventsWithDetails.count=",self.eventsWithDetails.count)
      print("originalSelectedEventId=",self.originalSelectedEventId)
      let selectedEventIndex = self.eventsWithDetails.index(where: { $0.Id == self.originalSelectedEventId })
    print("selectedEventIndex=",selectedEventIndex)
//    print("eventsWithDetails[selectedEventIndex!].Id=",eventsWithDetails[selectedEventIndex!].Id)
      if selectedEventIndex != nil && self.eventsWithDetails.count > 0
    {
      self.selectedEvent = self.eventsWithDetails[selectedEventIndex!]
//      print("selectedEvent=",selectedEvent)
    } else {
      print("!#!#!# Event Missing !#!#!#")
      //event no longer in MyEvents list, display alert
      var missingEventAlert = UIAlertController(title: "This event is no longer in the MyEvents List", message: "Returning to MyEvents List", preferredStyle: .alert)
      //cancdl
      var cancelAction = UIAlertAction(title: "OK", style: .cancel) { _ in
        //go back to MyEvents
         _ = self.navigationController?.popToRootViewController(animated: false)
//        DispatchQueue.main.async {
//                  self.tabBarController!.selectedIndex = 0
//        }
      }
      missingEventAlert.addAction(cancelAction)
      //show alert
      self.present(missingEventAlert, animated: true, completion: nil)
    }//end if
    }//end dispatch

    print("DetailViewController > eventRefreshFailed=",eventRefreshFailed)
    if eventRefreshFailed
    {
      //terminate automatic update activities and show alert
      var autoUpdateAlert = UIAlertController(title: "Automatic Events Update Failed!  No Internet Connection.", message: "Cancel Automatic Updating, or Retry?\n(You can re-enable automatic updates in Settings)", preferredStyle: .alert)
      //retry
      var retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
        print("retry")
        refreshEventsWithDetails(completionHandler: {() -> () in
          print("DetailViewController > refreshEventsWithDetails > completionHandler")
          print("start refresh timer")
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
      DispatchQueue.main.async {
              print("updateDetails")
        self.eventDetailView.isHidden = false
        self.adjustCellWidth()
        let primaryIndex = OccultationEvent.primaryStationIndex(self.selectedStations)
        self.currentStationIndexPath = IndexPath(item:primaryIndex!, section: 0)
        self.updateEventInfoFields(eventItem: self.selectedEvent)
        self.updateShadowPlot(self.selectedEvent)
        self.stationCollectionView.scrollToItem(at: IndexPath(item: primaryIndex!, section: 0), at: .centeredHorizontally, animated: false)
        
        self.stationCollectionView.reloadData()
        
        self.stationPageControl.numberOfPages = self.selectedStations.count
        self.stationPageControl.currentPage = self.currentStationIndexPath.row
        
        self.shadowSigmaView.isHidden = false
        self.stationCollectionView.isHidden = false
        self.updateLatLonFlds()
      }
    }
  }

  
  override func viewWillAppear(_ animated: Bool)
  {
    print("viewWillAppear")
//    print("selectedEvent=",selectedEvent)
    UIApplication.shared.isIdleTimerDisabled = true
    
    originalSelectedEventId = selectedEvent.Id!
    
    stationCollectionView.isHidden = true
    
    eventDetailView.isHidden = false
    shadowSigmaView.isHidden = true
//    stationCollectionView.isHidden = true
    stationBarSubViewsExist = false
    stationCursorExists = false
    self.title = selectionObject
    let chordSortedStations = OccultationEvent.stationsSortedByChordOffset(selectedEvent, order: .ascending)

    selectedStations = chordSortedStations

    let primaryIndex = OccultationEvent.primaryStationIndex(selectedEvent)
    if complete
    {
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
    } else {
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
    }
   }
  
  override func viewDidAppear(_ animated: Bool)
  {
    print("viewDidAppear")
    eventDetailView.isHidden = false
    adjustCellWidth()
    let primaryIndex = OccultationEvent.primaryStationIndex(selectedStations)
    currentStationIndexPath = IndexPath(item:primaryIndex!, section: 0)
    updateEventInfoFields(eventItem: selectedEvent)
    updateShadowPlot(self.selectedEvent)
    stationCollectionView.scrollToItem(at: IndexPath(item: primaryIndex!, section: 0), at: .centeredHorizontally, animated: false)
    
    stationCollectionView.reloadData()
    
    stationPageControl.numberOfPages = selectedStations.count
    stationPageControl.currentPage = currentStationIndexPath.row
    
    shadowSigmaView.isHidden = false
    stationCollectionView.isHidden = false
    updateLatLonFlds()
   }
  
  override func viewWillLayoutSubviews()
  {
//    print("viewWillLayoutSubviews")
    stationCollectionView.frame.size.width = self.view.safeAreaLayoutGuide.layoutFrame.size.width

    super.viewWillLayoutSubviews()
  }
  
  override func viewDidLayoutSubviews()
  {
//    print("viewDidLayoutSubviews")
    super.viewDidLayoutSubviews()
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
  {
    super.willTransition(to: newCollection, with: coordinator)
  }
  
  @objc func deviceRotated()
  {
//    print()
//    print("deviceRotated")
//    switch UIDevice.current.orientation {
//    case .landscapeLeft:
//      print("landscape left")
//    case .landscapeRight:
//      print("landscape right")
//    case .portrait:
//      print("portrait")
//    case .portraitUpsideDown:
//      print("portrait upsidedown")
//    case .faceUp:
//      print("face up")
//    case .faceDown:
//      print("face down")
//    default:
//      print("other")
//    }
    
    DispatchQueue.main.async {
      self.stationCollectionView.setNeedsLayout()
      self.adjustCellWidth()
      self.updateShadowPlot(self.selectedEvent)
      let primaryIndex = OccultationEvent.primaryStationIndex(self.selectedStations)
      self.currentStationIndexPath = IndexPath(item:primaryIndex!, section: 0)
      self.stationCollectionView.scrollToItem(at: self.currentStationIndexPath, at: .centeredHorizontally, animated: false)

      self.stationPageControl.currentPage = self.currentStationIndexPath.row
      
      //move primary here?  need selected event and plot width
//      self.moveCursorToStation(indexPath: self.currentStationIndexPath)
    }
   }
  
  override func viewWillDisappear(_ animated: Bool)
  {
//    print("viewWillDisappear")
    UIApplication.shared.isIdleTimerDisabled = false
    eventDetailView.isHidden = true
//printShadowPlotDiagnostics(headerStr: "viewWillDisappear end")
  }
  
  // MARK: - Event Detail Functions
  func updateEventInfoFields(eventItem itm: EventWithDetails)
  {
    //testing var
    var item = itm
    
    selectedStations = OccultationEvent.stationsSortedByChordOffset(item, order: .ascending)
    
    self.eventTitle.attributedText = self.event.updateObjectFld(item)
    self.eventRank.attributedText = self.event.updateRankFld(item)
    DispatchQueue.main.async
      {
        let primaryStationIndex = OccultationEvent.primaryStationIndex(self.selectedStations)
        
        let primaryStationEventTime = self.selectedStations[primaryStationIndex!].EventTimeUtc
//        print("primaryStationEventTime=",primaryStationEventTime)
        
        let timeTuple = currentEvent.updateUTCEventTimeFlds(&item,stationIndex: primaryStationIndex!)
//        var remainingTime: NSMutableAttributedString = timeTuple.remainingTime as! NSMutableAttributedString
        var remainingTime = timeTuple.remainingTime.string
//        if remainingTime.string == "completed"
        if remainingTime == "completed"
        {
//          print("Detail > found completed")
//          remainingTime = NSMutableAttributedString(string: "")
          remainingTime = ""
          //dim/gray out asteriod hame, date and time
          self.eventTitle.textColor = self.dimGray
          self.eventRank.textColor = self.dimGray
          self.eventFeed.textColor = self.dimGray
        } else {
          let onDayOfMonth = " on " + utcStrToLocalDayOfMonth(eventTimeStr: primaryStationEventTime!)!
//          print("onDayOfMonth=",onDayOfMonth)
//          let dayOfMonthAttrStr: NSAttributedString = NSAttributedString(string: onDayOfMonth)
          let dayOfMonthAttrStr = onDayOfMonth
//          let dayOfMonthAttrStr: NSMutableAttributedString = onDayOfMonth as! NSMutableAttributedString
          remainingTime.append(dayOfMonthAttrStr)
        }
        
        //this does not take effect until return to previous view controller
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
        
        self.eventTimeRemaining.attributedText = self.formatLabelandField(label: "", field: remainingTime, units: "")
        self.eventFeed.attributedText = self.event.updateFeedFld(item)
        self.eventRA.attributedText = self.event.updateRAFld(item)
        if appSettings.starEpochIsJ2000
        {
          self.j2000Lbl.isHidden = false
        } else {
          self.j2000Lbl.isHidden = true
        }
        self.eventDec.attributedText = self.event.updateDecFld(item)
        self.eventAsteroidOrigin.attributedText = self.event.updateAsteroidClassFld(item)
        self.eventAsteroidDiameter.attributedText = self.event.updateAsteroidDiamKM(item)
        self.eventStarMagnitude.attributedText = self.event.updateStarMagFld(item)
        self.eventAsteroidMagnitude.attributedText = self.event.updateAsteroidMagFld(item)
        self.eventCombinedMagnitude.attributedText = self.event.updateCombinedMagFld(item)
        self.eventMagnitudeDrop.attributedText = self.event.updateMagDropFld(item)
        self.eventMaxDur.attributedText = self.event.updateMaxDurFld(item)
        self.bvStarDiamView.isHidden = self.event.hideBVStarDiamView(item)
        //hide BV ad star diameter if both are nil
        if self.bvStarDiamView.isHidden == false
        {
          self.eventStarBV.attributedText = self.event.updateBVFld(item)
          self.eventStarDiameter.attributedText =  self.event.updateStarDiamFld(item)
        }
        //hide asteroid rotation and amplitude if both are nil
        self.asterRotAmpView.isHidden = self.event.hideAsterRotAmpView(item)
        if self.asterRotAmpView.isHidden == false
        {
          self.eventCamAseroidRotation.attributedText = self.event.updateAsteroidRotationFld(item)
          self.eventCamRotationAmplitude.attributedText = self.event.updateAsteroidRotationAmpFld(item)
        }

    }   // end DispatchQueue.main.async
  }
  
  func updateStationFlds(cell: inout StationCell, indexPath: IndexPath, stations: [ObserverStation], itm: EventWithDetails)
  {
//    print("updateStationFlds")
    var item = itm
    
    cell.sigmaImg.accessibilityIdentifier = "sigmaImg"
    cell.eventCloudImg.accessibilityIdentifier = "cloudImg"
    cell.eventWindSignImg.accessibilityIdentifier = "windSignImg"
    cell.eventWindStrengthImg.accessibilityIdentifier = "windStrengthImg"
    cell.starAltImg.accessibilityIdentifier = "starAltImg"
    cell.sunAltImg.accessibilityIdentifier = "sunAltImg"
    cell.moonAltImg.accessibilityIdentifier = "moonAltImg"
    cell.eventMoonSeparation.accessibilityIdentifier = "moonSepImg"
    //add accessibilityIdentifier to aid debugging
    cell.stationStack.accessibilityIdentifier = "stationStack"
    cell.topStack.accessibilityIdentifier = "topStack"
    cell.locationStack.accessibilityIdentifier = "locationStack"
    cell.cloudStack.accessibilityIdentifier = "cloudStack"
    cell.windStack.accessibilityIdentifier = "windStack"
    cell.tempStack.accessibilityIdentifier = "tempStack"
    cell.middleStack.accessibilityIdentifier = "middleStack"
    cell.reportImg.accessibilityIdentifier = "reportImg"
    cell.bottomStack.accessibilityIdentifier = "bottomStack"
    cell.starAltStack.accessibilityIdentifier = "starAltStack"
    cell.sunAltStack.accessibilityIdentifier = "sunAltStack"
    cell.moonAltStack.accessibilityIdentifier = "moonAltStack"
    cell.moonSepStack.accessibilityIdentifier = "moonAltStack"

    
    let stationIndex = indexPath.item
//    print("updateStationFlds > stations[stationIndex].StationId=",stations[stationIndex].StationId)
    print("station latitude=",stations[stationIndex].Latitude,"   longitude=",stations[stationIndex].Longitude)
    
    var stationPosIconVal : Int?
    stationPosIconVal = 0
    if stations[stationIndex].StationPos != nil
    {
      stationPosIconVal = stations[stationIndex].StationPos!
    }
    cell.sigmaImg.image = stationSigmaIcon(stationPosIconVal)
    
    var stationChordDistStr = "Chord: — km"
    if stations[stationIndex].ChordOffsetKm != nil
    {
      stationChordDistStr = String(format: "Chord: %0.0f km",stations[stationIndex].ChordOffsetKm!)
    }
    cell.eventChordDistance.text = stationChordDistStr
    
    var stationName = "—"
    if stations[stationIndex].StationName != nil
    {
      stationName = stations[stationIndex].StationName!
    }
    if stations[stationIndex].CountryCode != nil
    {
      stationName = stationName + " (" + stations[stationIndex].CountryCode! + ")"
    }
    cell.eventStationID.text = stationName
    
    if appSettings.detailTimeIsLocal
    {
      let timeTuple = event.updateLocalEventTimeFlds(&item, stationIndex: indexPath.row)
      cell.eventTime.text = timeTuple.eventTime
    } else {
      let timeTuple = event.updateUTCEventTimeFlds(&item, stationIndex: indexPath.row)
      cell.eventTime.text = timeTuple.eventTime
    }

    var errorTimeStr = "—"
    if item.ErrorInTimeSec != nil
    {
      errorTimeStr = String(format: "+/-%0.0f sec",item.ErrorInTimeSec!)
    }
    cell.eventTimeError.text = errorTimeStr
    
    let report = stations[stationIndex].Report
    reportStationId = stations[stationIndex].StationId
    if complete
    {
      switch report {
      case 0:
        //NotReported
        //If station is not for current user, leave event time and time error visible
        //If station is for current user, display Report Observation button
        if stations[stationIndex].IsOwnStation!
        {
          cell.reportImg.isHidden = true
          cell.eventTime.isHidden = true
          cell.eventTimeError.isHidden = true
          cell.reportBtn.isHidden = false
        } else {
          cell.reportImg.isHidden = true
          cell.eventTime.isHidden = false
          cell.eventTimeError.isHidden = false
          cell.reportBtn.isHidden = true
        }
//        }
      case 1:
        //Miss
        //show negative icon and hide event time and time error
        cell.reportImg.image = #imageLiteral(resourceName: "rep_neg.png")
        cell.reportImg.isHidden = false
        cell.eventTime.text = "Miss"
        cell.eventTime.isHidden = false
        cell.eventTimeError.isHidden = true
        cell.reportBtn.isHidden = true
      case 2:
        //Clouded
        //show grey icon? and hide event time and time error
        cell.reportImg.image = #imageLiteral(resourceName: "rep_grey.png")
        cell.reportImg.isHidden = false
        cell.eventTime.text = "Clouded"
        cell.eventTime.isHidden = false
        cell.eventTimeError.isHidden = true
        cell.reportBtn.isHidden = true
      case 3:
        //Failed (reported in OW as 'Technical Failure')
        //show fail icon and hide event time and time error
        cell.reportImg.image = #imageLiteral(resourceName: "rep_fail.png")
        cell.reportImg.isHidden = false
        cell.eventTime.text = "Fail"
        cell.eventTime.isHidden = false
        cell.eventTimeError.isHidden = true
        cell.reportBtn.isHidden = true
      case 4:
        //Positive
        //show positive icon and hide event time and time error
        cell.eventTime.text = "Positive"
        if let eventDuration = stations[stationIndex].ReportedDuration   // original
        {
          let eventDurationStr = String(format: "  %0.2f sec",eventDuration)
          cell.eventTime.text = "Positive" + eventDurationStr
        }
        cell.reportImg.image = #imageLiteral(resourceName: "rep_pos.png")
        cell.reportImg.isHidden = false
        cell.eventTime.isHidden = false
        cell.eventTimeError.isHidden = true
        cell.reportBtn.isHidden = true
      case 5:
        //NoObservation
        //leave event time and time error visible
        cell.reportImg.image = #imageLiteral(resourceName: "rep_grey.png")
        cell.reportImg.isHidden = false
        cell.eventTime.text = "No Observation"
        cell.eventTime.isHidden = false
        cell.eventTimeError.isHidden = true
        cell.reportBtn.isHidden = true
      case 6:
        //ReportToFollow (reported in OW as 'Observed, Report to follow')
        //If station is not for current user, display follow icon and hide event time and time error
        //If station is for current user, display Report Observation button
        if stations[stationIndex].IsOwnStation!
        {
          cell.reportImg.isHidden = true
          cell.eventTime.isHidden = true
          cell.eventTimeError.isHidden = true
          cell.reportBtn.isHidden = false
        } else {
          cell.reportImg.image = #imageLiteral(resourceName: "rep_follow.png")
          cell.reportImg.isHidden = false
          cell.eventTime.text = "Report to Follow"
          cell.eventTime.isHidden = false
          cell.eventTimeError.isHidden = true
          cell.reportBtn.isHidden = true
        }
      default:
        //NotReported
        //leave event time and time error visible
        //      cell.reportImg.image = nil
        cell.reportImg.isHidden = true
        cell.eventTime.isHidden = false
        cell.eventTimeError.isHidden = false
        cell.reportBtn.isHidden = true
      }
    } else {
      cell.reportImg.isHidden = true
      cell.eventTime.isHidden = false
      cell.eventTimeError.isHidden = false
      cell.reportBtn.isHidden = true
    }
    
    //determine if there's weather info available
    if stations[stationIndex].WeatherInfoAvailable != nil && stations[stationIndex].WeatherInfoAvailable!
    {
      //cloud info
      var cloudCoverValue: Int?
      var cloudCoverStr = " —"
      var cloudIconValue: Int?
      if stations[stationIndex].CloudCover != nil
      {
        cloudCoverValue = stations[stationIndex].CloudCover! * 10
        cloudCoverStr = String(format: " %d%%",cloudCoverValue!)
        cloudIconValue = cloudCoverValue
      }
      cell.eventClouds.text = cloudCoverStr
      cell.eventCloudImg.image = cloudIcon(cloudIconValue)
      //wind info
      var windSpeedIconValue: Int?
      var windSignIconValue: Int?
      if stations[stationIndex].Wind != nil
      {
        windSignIconValue = stations[stationIndex].Wind!
        windSpeedIconValue = stations[stationIndex].Wind!
      }
      cell.eventWindStrengthImg.image = windStrengthIcon(windSpeedIconValue)
      cell.eventWindSignImg.image = windSignIcon(windSignIconValue)
      //temp info
      var tempStr = "—"
      cell.eventTempImg.image = thermIcon(stations[stationIndex].TempDegC!)
      if stations[stationIndex].TempDegC != nil
      {
        if appSettings.tempIsCelsius
        {
          tempStr = String(format: "%d°C",stations[stationIndex].TempDegC!)
        } else {
          var tempF = celsiusToFahrenheit(degreesC: Double(stations[stationIndex].TempDegC!))
          tempStr = String(format: "%d°F",Int(tempF.rounded()))
        }
      }
      cell.eventTemperature.text = tempStr
      //high cloud info
      var highCloudStr = ""
      if stations[stationIndex].HighCloud != nil
      {
        highCloudStr = String(format: "%@",stations[stationIndex].HighCloud!.description)
      }
    } else {
//      print("not complete")
      cell.eventCloudImg.image = nil
      cell.eventClouds.text = ""
      cell.eventWindStrengthImg.image = nil
      cell.eventWindSignImg.image = nil
      cell.eventTempImg.image = nil
      cell.eventTemperature.text = ""
    }
    
    var starAltStr = "—"
    if stations[stationIndex].StarAlt != nil
    {
      starAltStr = String(format: "%0.0f°",stations[stationIndex].StarAlt!)
      starAltStr = starAltStr + assignAzIndicatorStr(azimuth: stations[stationIndex].StarAz!, azFormat: appSettings.azimuthIsDegrees
      )
    }
    cell.eventStarAlt.text = starAltStr
    
    var sunAltStr = "—"
    if stations[stationIndex].SunAlt != nil
    {
      sunAltStr = String(format: "%0.0f°", stations[stationIndex].SunAlt!)
      if stations[stationIndex].SunAlt! > -12.0
      {
        cell.sunAltImg.image =  #imageLiteral(resourceName: "sun")
        cell.eventSunAlt.text = sunAltStr
      }
      else
      {
        cell.sunAltImg.image = nil
        cell.eventSunAlt.text = "   "
      }
    }
    else
    {
      cell.sunAltImg.image = nil
      cell.eventSunAlt.text = "   "
    }
    
    var moonAltStr = "—"
    var moonPhaseImage: UIImage
    if stations[stationIndex].MoonAlt != nil
    {
      moonAltStr = String(format: "%0.0f°", stations[stationIndex].MoonAlt!)
      moonAltStr = moonAltStr + assignAzIndicatorStr(azimuth: stations[stationIndex].MoonAz!, azFormat: appSettings.azimuthIsDegrees)
      if stations[stationIndex].MoonPhase != nil
      {
        moonPhaseImage =  moonAltIcon(stations[stationIndex].MoonPhase)
        cell.moonAltImg.image = moonPhaseImage
      }
      else
      {
        moonPhaseImage = moonAltIcon(0)
        cell.moonAltImg.image = moonPhaseImage
      }
    }

    var moonDist = "—"
    if stations[stationIndex].MoonDist != nil
    {
      moonDist = String(format: "%0.0f°", stations[stationIndex].MoonDist!)
    }
    cell.eventMoonSeparation.text = moonDist
    if stations[stationIndex].MoonAlt! >= 0.0
    {
      cell.eventMoonAlt.text = moonAltStr
//      cell.eventMoonSeparation.isHidden = false
//      cell.eventMoonSepImg.isHidden = false
      cell.moonSepStack.isHidden = false
    } else {
      cell.eventMoonAlt.text = "(below hzn)"
//      cell.eventMoonSeparation.isHidden = true
//      cell.eventMoonSepImg.isHidden = true
      cell.moonSepStack.isHidden = true
    }

    var starColorImage: UIImage
    if stations[stationIndex].StarColour != nil
    {
      starColorImage = starColorIcon(stations[stationIndex].StarColour!)
      cell.starAltImg.image = starColorImage
    }
    else
    {
      cell.starAltImg.image = nil
    }
     
  }
    
  func printShadowPlotDiagnostics(headerStr: String)
  {
    print()
    print(headerStr)
    print("shadowBarView.frame.size.width=",shadowBarView.frame.size.width)
    print("sigma1BarView.frame.size.width=",sigma1BarView.frame.size.width)
    print("sigma2BarView.frame.size.width=",sigma2BarView.frame.size.width)
    print("sigma3BarView.frame.size.width=",sigma3BarView.frame.size.width)
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    print("shadowBarView.bounds.size.width=",shadowBarView.bounds.size.width)
    print("sigma1BarView.bounds.size.width=",sigma1BarView.bounds.size.width)
    print("sigma2BarView.bounds.size.width=",sigma2BarView.bounds.size.width)
    print("sigma3BarView.bounds.size.width=",sigma3BarView.bounds.size.width)
    print()
  }
  
  func updateShadowPlot(_ item: EventWithDetails)
  {
    var plotWidthKm = totalPlotWidthKm(item, scale: .sigma3Edge)
    DispatchQueue.main.async
      {
//        print()
//        print("updateShadowPlot")
        let outerChordWidth = farthestChordWidth(item)
        self.sigma1BarView.isHidden = false
        self.sigma2BarView.isHidden = false
        self.sigma3BarView.isHidden = false
        if outerChordWidth > sigma3WidthKm(item)
        {
          plotWidthKm = totalPlotWidthKm(item, scale: .farthestChord)
        } else if outerChordWidth > sigma2WidthKm(item)
        {
          plotWidthKm = totalPlotWidthKm(item, scale: .sigma3Edge)
        } else if outerChordWidth > sigma1WidthKm(item)
        {
          plotWidthKm = totalPlotWidthKm(item, scale: .sigma2Edge)
          self.sigma3BarView.isHidden = true
        } else if outerChordWidth > shadowWidthKm(item)
        {
          plotWidthKm = totalPlotWidthKm(item, scale: .sigma1Edge)
           self.sigma2BarView.isHidden = true
          self.sigma3BarView.isHidden = true
        } else if outerChordWidth <= shadowWidthKm(item)
        {
          plotWidthKm = totalPlotWidthKm(item, scale: .shadowEdge)
          self.sigma1BarView.isHidden = true
          self.sigma2BarView.isHidden = true
          self.sigma3BarView.isHidden = true
        }
        let plotBarFactors = plotBarsWidthFactors(item, totalPlotWidthKm: plotWidthKm)

        self.shadowBarWidth.constant = self.weatherBarView.bounds.width * CGFloat(plotBarFactors.shadowBarFactor)
        self.sigma1Width.constant = self.weatherBarView.bounds.width * CGFloat(plotBarFactors.sigma1BarFactor)
        self.sigma2Width.constant = self.weatherBarView.bounds.width * CGFloat(plotBarFactors.sigma2BarFactor)
        self.sigma3Width.constant = self.weatherBarView.bounds.width * CGFloat(plotBarFactors.sigma3BarFactor)

//        self.sigma3BarView.frame.size.width = self.weatherBarView.bounds.width * CGFloat(plotBarFactors.sigma3BarFactor)

        self.weatherBarView.subviews.forEach( { $0 .removeFromSuperview() })
        self.addStationsSubviews(plotWidthKm)
        self.addStationCursor()

        self.moveCursorToStation(indexPath: self.visibleStationIndexPath())
        self.movePrimaryStationBar(item, plotWidthKm)
        self.addPlotTicks(plotWidthKM: plotWidthKm)
    }  // dispatch end
  }
  
  func moveCursorToStation(indexPath: IndexPath)
  {
    let currentIndex = indexPath.item
//    print("currentIndex=",currentIndex)
//    DispatchQueue.main.async
//      {
//        print("moveCursorToStation")
        if self.weatherBarView.subviews[currentIndex].frame.origin.x >= self.weatherBarView.frame.minX
          && self.weatherBarView.subviews[currentIndex].frame.origin.x < self.weatherBarView.frame.maxX
        {
          self.stationCursor.isHidden = false
          let currentStationView = self.weatherBarView.subviews[currentIndex]
          self.stationCursor.frame.origin.x = currentStationView.frame.origin.x + (currentStationView.frame.width / 2) - self.stationCursor.frame.width / 2
        } else {
          self.stationCursor.isHidden = true
        }
//    }
  }

   func movePrimaryStationBar(_ item: EventWithDetails, _ plotWidthKm: Double)
   {
//     print("movePrimaryStationBar")
       var primaryStation = OccultationEvent.primaryStation(item)!
          let primaryFactor = plotStationBarFactor(station: primaryStation, totalPlotWidthKm: plotWidthKm)
          DispatchQueue.main.async
            {
              self.userBarView.frame.origin.x = self.centerBarView.frame.origin.x + (self.weatherBarView.bounds.width / 2) * CGFloat(primaryFactor)
          }
  }

  func visibleStationIndexPath() -> IndexPath
  {
    let visibleRect = CGRect(origin: stationCollectionView.contentOffset, size: stationCollectionView.bounds.size)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    let visibleStationIndexPath = stationCollectionView.indexPathForItem(at: visiblePoint)!
    return visibleStationIndexPath
  }
  
  func addStationsSubviews(_ plotWidthKm: Double)
  {
//    print("addStationsSubviews")
        for station in self.selectedStations
      {
        let stationFactor = plotStationBarFactor(station: station, totalPlotWidthKm: plotWidthKm)
        let stationView = UIView()
        stationView.frame.size.width = 2
        stationView.frame.size.height = self.weatherBarView.frame.height
        let stationViewHalfWidth = (stationView.frame.size.width / 2)
        stationView.frame.origin.x = self.centerBarView.frame.origin.x + (self.centerBarView.frame.size.width / 2) - stationViewHalfWidth + (self.weatherBarView.bounds.width / 2) * CGFloat(stationFactor)
        stationView.frame.origin.y = self.weatherBarView.frame.origin.y
        if self.detailData.WeatherInfoAvailable!
        {
          stationView.backgroundColor = cloudColor(station.CloudCover)
        } else {
          stationView.backgroundColor = .gray
        }
        self.weatherBarView.addSubview(stationView)
      }
  }
  
  func addStationCursor()
  {
    //add station cursor subview
//    print("addStationCursor")
//    DispatchQueue.main.async
//      {
    self.stationCursor.frame.size.width = 11
    self.stationCursor.frame.size.height = 3
    self.stationCursor.frame.origin.y = self.weatherBarView.frame.origin.y + self.weatherBarView.frame.height - self.centerGrayBar.frame.height - self.stationCursor.frame.height
    self.stationCursor.frame.origin.x = self.centerBarView.frame.origin.x
    self.stationCursor.backgroundColor = .black
    self.weatherBarView.addSubview(self.stationCursor)
    self.weatherBarView.bringSubviewToFront(self.stationCursor)
//    }
  }
  
  func addPlotTicks(plotWidthKM: Double)
  {
//    print("addPlotTicks")
    let tickWidth = 1.0
    let tickHeight = 3.0
    let tickColor = UIColor.darkGray
    let tickStep = 100.0
    let tickEnd = plotWidthKM / 2
    self.tickBar.backgroundColor = #colorLiteral(red: 0.9991671443, green: 0.8578354716, blue: 0.7157068849, alpha: 1)
    self.tickBar.frame.size.width = self.shadowSigmaView.frame.size.width
    self.tickBar.frame.size.height = 5
    self.tickBar.frame.origin.y = self.bottomGrayBar.frame.origin.y + (self.bottomGrayBar.frame.size.height - self.tickBar.frame.size.height) / 2
    self.shadowSigmaView.addSubview(self.tickBar)
    
    for view in self.tickBar.subviews
    {
      view.removeFromSuperview()
    }
    
    //zero tick
    let zeroTick = UIView()
    zeroTick.frame.size.width = CGFloat(tickWidth)
    zeroTick.frame.size.height = CGFloat(tickHeight)
    zeroTick.backgroundColor = tickColor
    zeroTick.frame.origin.x = self.centerBarView.frame.origin.x + (self.centerBarView.frame.size.width / 2) - (zeroTick.frame.size.width / 2)
    zeroTick.frame.origin.y = self.tickBar.bounds.origin.y
    self.tickBar.addSubview(zeroTick)

    if plotWidthKM > tickStep
    {

      for tickKM in stride(from: 0,to: tickEnd, by: tickStep)
      {
        if tickKM > 0
        {
          let positiveTick = UIView()
          let negativeTick = UIView()

          positiveTick.frame.size.width = CGFloat(tickWidth)
          positiveTick.frame.size.height = CGFloat(tickHeight)
          positiveTick.backgroundColor = tickColor
//          positiveTick.frame.origin.x = self.centerBarView.frame.origin.x + (self.weatherBarView.bounds.width / 2) * CGFloat(tickKM / (plotWidthKM / 2))
          positiveTick.frame.origin.x = self.centerBarView.frame.origin.x + (self.centerBarView.frame.size.width / 2) - (zeroTick.frame.size.width / 2) + (self.weatherBarView.bounds.width / 2) * CGFloat(tickKM / (plotWidthKM / 2))
          positiveTick.frame.origin.y = self.tickBar.bounds.origin.y
          self.tickBar.addSubview(positiveTick)

          negativeTick.frame.size.width = CGFloat(tickWidth)
          negativeTick.frame.size.height = CGFloat(tickHeight)
          negativeTick.backgroundColor = tickColor
//          negativeTick.frame.origin.x = self.centerBarView.frame.origin.x - (self.weatherBarView.bounds.width / 2) * CGFloat(tickKM / (plotWidthKM / 2))
          negativeTick.frame.origin.x = self.centerBarView.frame.origin.x + (self.centerBarView.frame.size.width / 2) - (zeroTick.frame.size.width / 2) - (self.weatherBarView.bounds.width / 2) * CGFloat(tickKM / (plotWidthKM / 2))
          negativeTick.frame.origin.y = self.tickBar.bounds.origin.y
          self.tickBar.addSubview(negativeTick)
        }
      }
    }
    self.tickBar.setNeedsLayout()
  }

  
//  @IBAction func handleReport(_ sender: Any)
//  {
//    print(">>>Report Obervations button tapped<<<")
//    print("reportStationId=",reportStationId)
//  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == "SubmitReportSegue"
    {
      if let dest = segue.destination as? ReportViewController
      {
        dest.eventId = selectedEvent.Id
        print("dest.eventId=",dest.eventId)
        dest.stationId = reportStationId
        print("dest.stationId=",dest.stationId)
        dest.astroName = selectionObject
        dest.observedLocation = selectedStations[currentStationIndexPath.item].StationName
      }
    }
  }

  @IBAction func mapLatLon(_ sender: Any)
  {
        print("launchAppleMaps")
    //     let myAddress = "2201+Heidi+Ct,Bartlesville,OK,USA"
    let latStr = String(format: "%0.5f",selectedStations[currentStationIndexPath.row].Latitude!)
    let lonStr = String(format: "%0.5f",selectedStations[currentStationIndexPath.row].Longitude!)
    
        let locationStr = latStr + "," + lonStr
        if let url = URL(string:"http://maps.apple.com/?address=\(locationStr)") {
          print("url=",url)
            UIApplication.shared.open(url)
        }

  }
  
  
  
}

// MARK: -  Extension - Colllection functions
extension DetailViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return selectedStations.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
//    print("cellForItemAt")
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StationCell
//    cell.backgroundColor = #colorLiteral(red: 0.2043271959, green: 0.620110333, blue: 0.6497597098, alpha: 1)
    cell.backgroundColor = #colorLiteral(red: 0.3866960108, green: 0.623185575, blue: 0.6741087437, alpha: 1)
//    print("indexPath=",indexPath)
    updateStationFlds(cell: &cell, indexPath: indexPath, stations: selectedStations, itm: selectedEvent)
    return cell
  }
  
  func adjustCellWidth()
  {
    let cellHeight = stationCollectionView.bounds.height
//    print("cellHeight=",cellHeight)
    if let flowLayout = self.stationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
    {
      flowLayout.minimumLineSpacing = 0
      flowLayout.minimumInteritemSpacing = 0
      flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      let cellWidth = self.stationCollectionView.bounds.width - flowLayout.minimumLineSpacing
      stationCollectionView.bounds.origin.x = 0
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  func updateLatLonFlds()
  {
    //update event fields with station latitude and longitude
    let decimalLat = selectedStations[currentStationIndexPath.row].Latitude
    let decimalLon = selectedStations[currentStationIndexPath.row].Longitude
    var dmsLatTuple = (0,0,0.0)
    var dmsLonTuple = (0,0,0.0)
    if decimalLat != nil
    {
      dmsLatTuple = floatDegreesToDMS(floatDeg: decimalLat!)
    }
    if decimalLon != nil
    {
      dmsLonTuple = floatDegreesToDMS(floatDeg: decimalLon!)
    }
    print()
    print("station index=",currentStationIndexPath.row,"   IsOwnStation=",selectedStations[currentStationIndexPath.row].IsOwnStation!)
    print("station name=",selectedStations[currentStationIndexPath.row].StationName!)
    print("chord=",selectedStations[currentStationIndexPath.row].ChordOffsetKm!)
    print("decimalLat=",decimalLat,"   decimalLon=",decimalLon)
    print("dmsLat=",dmsLatTuple,"   dmsLon=",dmsLonTuple)
    print()
    if selectedStations[currentStationIndexPath.row].IsOwnStation!
    {
      self.eventLat.attributedText = self.event.updateLatitudeFld(selectedStations[currentStationIndexPath.row])
      self.eventLon.attributedText = self.event.updateLongitudeFld(selectedStations[currentStationIndexPath.row])
      self.latLonStack.isHidden = false
    } else {
      self.eventLat.attributedText = NSAttributedString(string: "")
      self.eventLon.attributedText = NSAttributedString(string: "")
      self.latLonStack.isHidden = true
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    //    DispatchQueue.main.async {print("scrollViewDidEndDecelerating")}
    currentStationIndexPath = visibleStationIndexPath()
    moveCursorToStation(indexPath: visibleStationIndexPath())
    stationPageControl.currentPage = currentStationIndexPath.row
    updateLatLonFlds()
  }
}


// MARK: -  Extension - Utility functions
extension DetailViewController
{
  func formatLabelandField(label: String, field: String, units: String) -> NSAttributedString
  {
    let labelFont =   UIFont.preferredFont(forTextStyle: .callout)
    let fieldFont =   UIFont.preferredFont(forTextStyle: .headline)
    let unitsFont = labelFont
    
    let labelAttributes: [NSMutableAttributedString.Key: Any] = [.font: labelFont]
    let fieldAttributes: [NSMutableAttributedString.Key: Any] = [.font: fieldFont]
    let unitsAttributes: [NSMutableAttributedString.Key: Any] = [.font: unitsFont]
    
    let labelAttrStr = NSMutableAttributedString(string: label, attributes: labelAttributes)
    let fieldAttrStr = NSAttributedString(string: field, attributes: fieldAttributes)
    let unitsAttrStr = NSAttributedString(string: units, attributes: unitsAttributes)
    
    labelAttrStr.append(fieldAttrStr)
    labelAttrStr.append(unitsAttrStr)
    
    return labelAttrStr
  }
  
  func clearFieldsAndIcons()
  {
    self.eventTitle.text = "—"
    self.eventRank.text = "Rank: —"
    self.eventTimeRemaining.text = "_"
    self.eventFeed.text = "—"
    self.eventRA.text = "RA —"
    self.eventDec.text = "DE   —"
    self.eventStarBV.text = "B-V   —"
    self.eventStarDiameter.text = "Stellar Dia.          -"
    self.eventAsteroidOrigin.text = "—"
    self.eventAsteroidDiameter.text = "Diameter        —"
    self.eventStarMagnitude.text = "Star Mag     —"
    self.eventAsteroidMagnitude.text = "Aster. Mag     —"
    self.eventCombinedMagnitude.text = "Comb. Mag       —"
    self.eventMagnitudeDrop.text = "Mag Drop       —"
    self.eventCamAseroidRotation.text = "Rotation       —"
    self.eventCamRotationAmplitude.text = "Amplitude       —"
    self.eventCamCombinedMag.text = "Comb. Mag  —"
    self.eventCamMagDrop.text = "Mag Drop  —"
  }
  
  func printEventDetails()
  {
    print("eventTitle=\(eventTitle!.text ?? "")")
    print("eventRank=\(eventRank!.text ?? "")")
    print("eventTimeRemaining=\(eventTimeRemaining!.text ?? "")")
    print("eventFeed=\(eventFeed!.text ?? "")")
    print("weatherBarView=\(weatherBarView!)")
    print("sigma1BarView=\(sigma1BarView!)")
    print("shadowBarView=\(shadowBarView!)")
    print("centerBarView=\(centerBarView!)")
    print("eventRA=\(eventRA.text ?? "")")
    print("eventDec=\(eventDec.text ?? "")")
    print("eventStarBV=\(eventStarBV.text ?? "")")
    print("eventStarDiameter=\(eventStarDiameter.text ?? "")")
    print("eventAsteroidOrigin=\(eventAsteroidOrigin.text ?? "")")
    print("eventAsteroidDiameter=\(eventAsteroidDiameter.text ?? "")")
    print("eventStarMagnitude=\(eventStarMagnitude.text ?? "")")
    print("eventAsteroidMagnitude=\(eventAsteroidMagnitude.text ?? "")")
    print("eventCombinedMagnitude=\(eventCombinedMagnitude.text ?? "")")
    print("eventMagnitudeDrop=\(eventMagnitudeDrop.text ?? "")")
    print("eventCameraSectionTitle=\(eventCameraSectionTitle.text ?? "")")
    print("eventCamCombinedMag=\(eventCamCombinedMag.text ?? "")")
    print("eventCamMagDrop=\(eventCamMagDrop.text ?? "")")
    print("eventCamAseroidRotation=\(eventCamAseroidRotation.text ?? "")")
    print("eventCamRotationAmplitude=\(eventCamRotationAmplitude.text ?? "")")
  }
  
}
