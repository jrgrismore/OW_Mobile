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

  var selection: String!
  var detailStr: String = ""
  var eventID: String = ""
  var complete: Bool = false
  
  var stationsDetails = [EventDetails]()
  var selectedStations = [Station]()
  var selectedEventDetails = EventDetails()
  var event = OccultationEvent()
  var stationCursor = UIView()
  var visibleIndexPaths = [IndexPath]()
  
  var currentStationIndexPath = IndexPath()
  
  var stationBarSubViewsExist = false
  var stationCursorExists = false
  
  // MARK: - Spinner Outlets
  @IBOutlet weak var spinnerView: UIView!
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var spinnerLbl: UILabel!
  
  // MARK: - Label Outlets
  @IBOutlet weak var eventTitle: UILabel!
  @IBOutlet weak var eventRank: UILabel!
  @IBOutlet weak var eventTimeRemaining: UILabel!
  @IBOutlet weak var eventFeed: UILabel!
  
  @IBOutlet weak var eventRA: UILabel!
  @IBOutlet weak var eventDec: UILabel!
  @IBOutlet weak var eventStarBV: UILabel!
  @IBOutlet weak var eventStarDiameter: UILabel!
  
  @IBOutlet weak var eventAsteroidOrigin: UILabel!
  @IBOutlet weak var eventAsteroidDiameter: UILabel!
  @IBOutlet weak var eventStarMagnitude: UILabel!
  @IBOutlet weak var eventAsteroidMagnitude: UILabel!
  @IBOutlet weak var eventCombinedMagnitude: UILabel!
  @IBOutlet weak var eventMagnitudeDrop: UILabel!
  
  @IBOutlet weak var eventCameraSectionTitle: UILabel!
  @IBOutlet weak var eventCamCombinedMag: UILabel!
  @IBOutlet weak var eventCamMagDrop: UILabel!
  @IBOutlet weak var eventCamAseroidRotation: UILabel!
  @IBOutlet weak var eventCamRotationAmplitude: UILabel!
  
  // MARK: - View Outlets
  @IBOutlet var eventDetailView: UIView!
  @IBOutlet weak var weatherBarView: UIView!
  @IBOutlet weak var centerGrayBar: UIView!
  @IBOutlet weak var sigma3BarView: UIView!
  @IBOutlet weak var sigma2BarView: UIView!
  @IBOutlet weak var sigma1BarView: UIView!
  @IBOutlet weak var shadowBarView: UIView!
  @IBOutlet weak var centerBarView: UIView!
  @IBOutlet weak var userBarView: UIView!
  
  @IBOutlet weak var asterRotAmpView: UIStackView!
  @IBOutlet weak var bvStarDiamView: UIStackView!
  
  // MARK: - Constraint Outlets
  @IBOutlet weak var shadowBarWidth: NSLayoutConstraint!
  
  // MARK: - View functions
  override func viewDidLoad()
  {
    super.viewDidLoad()
    stationCollectionView.delegate = self
    stationCollectionView.dataSource = self
    self.spinnerView.layer.cornerRadius = 20
    NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name:  UIDevice.orientationDidChangeNotification, object: nil)
    if self.view.traitCollection.horizontalSizeClass == .regular && self.view.traitCollection.verticalSizeClass == .regular
    {
      sizeClassIsRR = true
    }
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
//    print()
//    print("viewWillAppear")
//    
//    print("complete=",complete)
    

    eventDetailView.isHidden = false
    stationBarSubViewsExist = false
    stationCursorExists = false
    
    let detailObject = detailData.Object!.replacingOccurrences(of: "(-2147483648) ", with: "")
    self.title = detailObject
    
    stationsDetails = OWWebAPI.shared.loadDetails()
    let detailsIndex = stationsDetails.index(where: { $0.Id == detailData.Id  })
    selectedEventDetails = stationsDetails[detailsIndex!]
    let chordSortedStations = self.event.stationsSortedByChordOffset(selectedEventDetails, order: .ascending)
    
    selectedStations = chordSortedStations
    
    let primaryIndex = self.event.primaryStationIndex(chordSortedStations)
    updateEventInfoFields(eventItem: selectedEventDetails)
    if complete
    {
//      print(":::::set color to darkGray")
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                                                      NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
    } else {
//      print(":::::set color to white")
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                      NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
    }
    
     DispatchQueue.main.async
    {
        self.stationCollectionView.scrollToItem(at: IndexPath(item: primaryIndex!, section: 0), at: .centeredHorizontally, animated: false)
        self.stationCollectionView.layoutIfNeeded()
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
    }
//      print("currentStationIndexPath=",currentStationIndexPath)
    }
  
  override func viewDidAppear(_ animated: Bool)
  {
//    print()
//    print("viewDidAppear")

    // temporarily added to test station left scroll problem
    // seems to work 8/25/19
    adjustCellWidth()
    
    
    //    print("safe area height =",self.view.safeAreaLayoutGuide.layoutFrame.size.height)
    //    print("safe area width =",self.view.safeAreaLayoutGuide.layoutFrame.size.width)
    //    print("stationCollectionView.bounds.width=",stationCollectionView.bounds.width)
    let primaryIndex = self.event.primaryStationIndex(selectedStations)
    currentStationIndexPath = IndexPath(item:primaryIndex!, section: 0)
    DispatchQueue.main.async
      {
        self.stationCollectionView.scrollToItem(at: IndexPath(item: primaryIndex!, section: 0), at: .centeredHorizontally, animated: false)
        self.moveCursorToStation(indexPath: IndexPath(item: primaryIndex!, section: 0))
    }
    updateShadowPlot(selectedEventDetails)
//    print("currentStationIndexPath=",currentStationIndexPath)
//    print()
  }
  
  override func viewWillLayoutSubviews()
  {
//    print()
    stationCollectionView.frame.size.width = self.view.safeAreaLayoutGuide.layoutFrame.size.width
//    print("viewWillLayoutSubviews")
//    print("safe area height =",self.view.safeAreaLayoutGuide.layoutFrame.size.height)
//    print("safe area width =",self.view.safeAreaLayoutGuide.layoutFrame.size.width)
//    print("stationCollectionView.bounds.width=",stationCollectionView.bounds.width)
    super.viewWillLayoutSubviews()
    
    
    //temporarily disabled to test station left scroll problem
//      adjustCellWidth()
    
    
//    currentStationIndexPath = visibleStationIndexPath()
//    print("currentStationIndexPath=",currentStationIndexPath)
//   print()
  }
  
  override func viewDidLayoutSubviews()
  {
//    print()
//    print("viewDidLayoutSubviews")
//    print("safe area height =",self.view.safeAreaLayoutGuide.layoutFrame.size.height)
//    print("safe area width =",self.view.safeAreaLayoutGuide.layoutFrame.size.width)
//    print("stationCollectionView.bounds.width=",stationCollectionView.bounds.width)
    super.viewDidLayoutSubviews()
//    print("stationCollectionView.bounds.width=",stationCollectionView.bounds.width)
//    currentStationIndexPath = visibleStationIndexPath()
//    print("currentStationIndexPath=",currentStationIndexPath)
//    stationCollectionView.collectionViewLayout.invalidateLayout()
//    print("==================")
   }

  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
  {
//    print()
//    print("willTransition")
    super.willTransition(to: newCollection, with: coordinator)
//    print("safe area width =",self.view.safeAreaLayoutGuide.layoutFrame.size.width)
//    print("stationCollectionView.bounds.width=",stationCollectionView.bounds.width)
//    currentStationIndexPath = visibleStationIndexPath()
//    print("currentStationIndexPath=",currentStationIndexPath)
//  print("currentStationIndexPath=",currentStationIndexPath)
//   print()
  }
  
  @objc func deviceRotated()
  {
//  print()
//  print("deviceRotated")
  //    print("safe area height =",self.view.safeAreaLayoutGuide.layoutFrame.size.height)
//  print("safe area width =",self.view.safeAreaLayoutGuide.layoutFrame.size.width)
//  print("stationCollectionView.bounds.width=",stationCollectionView.bounds.width)
  switch UIDevice.current.orientation {
  case .landscapeLeft:
    print("landscape left")
  case .landscapeRight:
    print("landscape right")
  case .portrait:
    print("portrait")
  case .portraitUpsideDown:
    print("portrait upsidedown")
  case .faceUp:
    print("face up")
  case .faceDown:
    print("face down")
  default:
    print("other")
  }
//  print("stationCollectionView.bounds.width=",stationCollectionView.bounds.width)
//  print()
//  currentStationIndexPath = visibleStationIndexPath()

  DispatchQueue.main.async {
    self.stationCollectionView.setNeedsLayout()
    self.adjustCellWidth()
    self.updateShadowPlot(self.selectedEventDetails)
//    self.currentStationIndexPath = self.visibleStationIndexPath()
    self.stationCollectionView.scrollToItem(at: self.currentStationIndexPath, at: .centeredHorizontally, animated: false)
  }
//  print("currentStationIndexPath=",currentStationIndexPath)
//  let chordSortedStations = self.event.stationsSortedByChordOffset(selectedEventDetails, order: .ascending)
//  let primaryIndex = self.event.primaryStationIndex(chordSortedStations)
//  moveCursorToStation(indexPath: IndexPath(item: primaryIndex!, section: 0))
//  print("deviceRotated > visibleStationIndexPath()=",visibleStationIndexPath())
//  print("deviceRotated > currentStationIndexPath=",currentStationIndexPath)
//  moveCursorToStation(indexPath: visibleStationIndexPath())
  moveCursorToStation(indexPath: currentStationIndexPath)

//  stationCollectionView.reloadData()

//  print()
}

  override func viewWillDisappear(_ animated: Bool)
  {
    eventDetailView.isHidden = true
//    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
   }
  
  // MARK: - Event Detail Functions
  func updateEventInfoFields(eventItem itm: EventDetails)
  {
    //testing var
    var item = itm
    selectedStations = self.event.stationsSortedByChordOffset(item, order: .ascending)
    
    DispatchQueue.main.async
      {
        self.eventTitle.attributedText = self.event.updateObjectFld(item)
        self.eventRank.attributedText = self.event.updateRankFld(item)
        let timeTuple = self.event.updateEventTimeFlds(&item)
        var remainingTime: NSMutableAttributedString = timeTuple.remainingTime as! NSMutableAttributedString
        if remainingTime.string == "completed"
        {
          print("Detail > found completed")
          remainingTime = NSMutableAttributedString(string: "")
          //dim/gray out asteriod hame, date and time
          self.eventTitle.textColor = .darkGray
          self.eventRank.textColor = .darkGray
          self.eventFeed.textColor = .darkGray
        }
        //this does not take effect until return to previous view controller
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]

        self.eventTimeRemaining.attributedText = remainingTime
        self.eventFeed.attributedText = self.event.updateFeedFld(item)
        self.eventRA.attributedText = self.event.updateRAFld(item)
        self.eventDec.attributedText = self.event.updateDecFld(item)
        //insert BVStarDiamView here
        self.eventAsteroidOrigin.attributedText = self.event.updateAsteroidClassFld(item)
        self.eventAsteroidDiameter.attributedText = self.event.updateAsteroidDiamKM(item)
        self.eventStarMagnitude.attributedText = self.event.updateStarMagFld(item)
        self.eventAsteroidMagnitude.attributedText = self.event.updateAsteroidMagFld(item)
        self.eventCombinedMagnitude.attributedText = self.event.updateCombinedMagFld(item)
        self.eventMagnitudeDrop.attributedText = self.event.updateMagDropFld(item)
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
        self.updateShadowPlot(item)
    }   // end DispatchQueue.main.async
  }
  
  func updateStationFlds(cell: inout StationCell, indexPath: IndexPath, stations: [Station], itm: EventDetails)
  {
    var item = itm
    let stationIndex = indexPath.item
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
    cell.eventStationID.text = stationName
    
//    let timeTuple = updateEventTimeFlds(&item)
    let timeTuple = event.updateEventTimeFlds(&item)
    cell.eventTime.text = timeTuple.eventTime
    
    var errorTimeStr = "—"
    if item.ErrorInTimeSec != nil
    {
      errorTimeStr = String(format: "+/-%0.0f sec",item.ErrorInTimeSec!)
    }
    cell.eventTimeError.text = errorTimeStr
    
    //determine if there's weather info available
    if stations[stationIndex].WeatherInfoAvailable != nil && stations[stationIndex].WeatherInfoAvailable!
    {
      //cloud info
      var cloudCoverStr = " —"
      var cloudIconValue: Int?
      if stations[stationIndex].CloudCover != nil
      {
        cloudCoverStr = String(format: " %d%%",stations[stationIndex].CloudCover!)
        cloudIconValue = stations[stationIndex].CloudCover!
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
      if stations[stationIndex].TempDegC != nil
      {
        tempStr = String(format: "%d°C",stations[stationIndex].TempDegC!)
      }
      
      cell.eventTemperature.text = tempStr
      cell.eventTempImg.image = thermIcon(stations[stationIndex].TempDegC!)
      
      //high cloud info
      var highCloudStr = ""
      if stations[stationIndex].HighCloud != nil
      {
        highCloudStr = String(format: "%@",stations[stationIndex].HighCloud!.description)
      }
      
    } else {
      cell.eventCloudImg.image = nil
      cell.eventClouds.text = ""
      cell.eventWindStrengthImg.image = nil
      cell.eventWindSignImg.image = nil
      cell.eventTempImg.image = nil
      cell.eventTemperature.text = ""
    }
    
    var starAltStr = "—"
    if item.StarAlt != nil
    {
      starAltStr = String(format: "%0.0f°",item.StarAlt!)
    }
    cell.eventStarAlt.text = starAltStr
    
    var sunAltStr = "—"
    if item.SunAlt != nil
    {
      sunAltStr = String(format: "%0.0f°", item.SunAlt!)
      if item.SunAlt! > -12.0
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
    if item.MoonAlt != nil
    {
      moonAltStr = String(format: "%0.0f°", item.MoonAlt!)
      if item.MoonPhase != nil
      {
        moonPhaseImage =  moonAltIcon(item.MoonPhase!)
        cell.moonAltImg.image = moonPhaseImage
      }
      else
      {
        moonPhaseImage = moonAltIcon(0)
        cell.moonAltImg.image = moonPhaseImage
      }
    }
    cell.eventMoonAlt.text = moonAltStr
    
    var moonDist = "—"
    if item.MoonDist != nil
    {
      moonDist = String(format: "%0.0f°", item.MoonDist!)
    }
    cell.eventMoonSeparation.text = moonDist
    
    var starColorImage: UIImage
    if item.StarColour != nil
    {
      starColorImage = starColorIcon(item.StarColour)
      cell.starAltImg.image = starColorImage
    }
    else
    {
      cell.starAltImg.image = nil
    }
  }
  
  func updateShadowPlot(_ item: EventDetails)
  {
//    print()
//    print("updateShadowPlot")
    //update shadow bars plot
    let stationsExistBeyondSigma1:Bool = self.event.barPlotToSigma3(item)
    
    var plotWidthKm = totalPlotWidthKm(item, scale: .sigma3Edge)
    let outerChordWidth = farthestChordWidth(item)
    //    print("outerChordWidth=",outerChordWidth)
    sigma1BarView.isHidden = false
    sigma2BarView.isHidden = false
    sigma3BarView.isHidden = false
    if outerChordWidth > sigma3WidthKm(item)
    {
      print(".farthesChord")
      plotWidthKm = totalPlotWidthKm(item, scale: .farthestChord)
    } else if outerChordWidth > sigma2WidthKm(item)
    {
      plotWidthKm = totalPlotWidthKm(item, scale: .sigma3Edge)
    } else if outerChordWidth > sigma1WidthKm(item)
    {
      plotWidthKm = totalPlotWidthKm(item, scale: .sigma2Edge)
      sigma3BarView.isHidden = true
    } else if outerChordWidth > shadowWidthKm(item)
    {
      plotWidthKm = totalPlotWidthKm(item, scale: .sigma1Edge)
      sigma2BarView.isHidden = true
      sigma3BarView.isHidden = true
    } else if outerChordWidth <= shadowWidthKm(item)
    {
      plotWidthKm = totalPlotWidthKm(item, scale: .shadowEdge)
      sigma1BarView.isHidden = true
      sigma2BarView.isHidden = true
      sigma3BarView.isHidden = true
    }
    //    print("plotWidthKm=",plotWidthKm)
    
    let plotBarFactors = plotBarsWidthFactors(item, totalPlotWidthKm: plotWidthKm)
    
    self.shadowBarView.bounds.size.width = self.weatherBarView.bounds.width
    self.sigma1BarView.bounds.size.width = self.weatherBarView.bounds.width
    self.sigma2BarView.bounds.size.width = self.weatherBarView.bounds.width
    self.sigma3BarView.bounds.size.width = self.weatherBarView.bounds.width
    
    self.shadowBarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.shadowBarFactor), y: 1.0)
    self.sigma1BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.sigma1BarFactor), y: 1.0)
    self.sigma2BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.sigma2BarFactor), y: 1.0)
    self.sigma3BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.sigma3BarFactor), y: 1.0)
    
    let primaryStation = self.event.primaryStation(item)!
    let primaryChordOffset = primaryStation.ChordOffsetKm!
    //    print("primaryChordOffset=",primaryChordOffset)
    let primaryFactor = plotStationBarFactor(station: primaryStation, totalPlotWidthKm: plotWidthKm)
    //    print("primaryFactor=",primaryFactor)
    self.userBarView.frame.origin.x = self.centerBarView.frame.origin.x + (self.weatherBarView.bounds.width / 2) * CGFloat(primaryFactor)
    
    self.weatherBarView.subviews.forEach( { $0 .removeFromSuperview() })
    addStationsSubviews(plotWidthKm)
    addStationCursor()
    
    //    print("primary station index = ",self.event.primaryStationIndex(self.selectedStations))
    //    print("<updateEventInfoFields")
//    print("currentStationIndexPath=",currentStationIndexPath)
  }
  
  func moveCursorToStation(indexPath: IndexPath)
  {
//    print()
//    print(">moveCursorToStation")
    //    print("station indexPath.item=",indexPath.item)
    //    for subview in self.weatherBarView.subviews
    //    {
    //      subview.backgroundColor = .black
    //    }
    var currentIndex = indexPath.item
    //    if let tempIndex = self.weatherBarView.subviews.firstIndex(where: {$0.tag == indexPath.item} )
    //    {
    //      currentIndex = tempIndex
    //    }
    DispatchQueue.main.async
      {
        //        print("currentIndex=",currentIndex)
        //        print("selectedStations[currentIndex]=",self.selectedStations[currentIndex])
        //        for station in self.selectedStations
        //        {
        //          print("station.chordOffset=",station.ChordOffsetKm)
        //        }
        //        print("self.weatherBarView.subviews[currentIndex].frame.origin.x=",self.weatherBarView.subviews[currentIndex].frame.origin.x)
        //        print("self.weatherBarView.bounds.minX=",self.weatherBarView.bounds.minX)
        //        print("self.weatherBarView.subviews[currentIndex].frame.origin.x=",self.weatherBarView.subviews[currentIndex].frame.origin.x)
        //        print("self.weatherBarView.bounds.maxX=",self.weatherBarView.bounds.maxX)
        if self.weatherBarView.subviews[currentIndex].frame.origin.x >= self.weatherBarView.frame.minX
          && self.weatherBarView.subviews[currentIndex].frame.origin.x < self.weatherBarView.frame.maxX
        {
          //          print("show station cursor")
          self.stationCursor.isHidden = false
          let currentStationView = self.weatherBarView.subviews[currentIndex]
          //          currentStationView.backgroundColor = .red
          self.stationCursor.frame.origin.x = currentStationView.frame.origin.x + (currentStationView.frame.width / 2) - self.stationCursor.frame.width / 2
        } else {
          //          print("hide station cursor")
          self.stationCursor.isHidden = true
        }
        //        print("<moveCursorToStation")
        //        print()
    }
//    print("currentStationIndexPath=",currentStationIndexPath)
  }

  func visibleStationIndexPath() -> IndexPath
  {
//    print()
//    print("visibleStationIndexPath")
    let visibleRect = CGRect(origin: stationCollectionView.contentOffset, size: stationCollectionView.bounds.size)
    //    print("visibleRect=",visibleRect)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    //    print("visiblePoint=",visiblePoint)
    let visibleStationIndexPath = stationCollectionView.indexPathForItem(at: visiblePoint)!
//    print("visibleStationIndexPath=",visibleStationIndexPath)
//    print("visbleStationIndexPath.item=",visibleStationIndexPath.item)
    //    print("visbleStationIndexPath.section=",visibleStationIndexPath.section)
    //    currentStationIndexPath = visibleStationIndexPath
//    print("currentStationIndexPath=",currentStationIndexPath)
//    print()
    return visibleStationIndexPath
  }

  func addStationsSubviews(_ plotWidthKm: Double)
  {
    //    if stationsExistBeyondSigma1
    //    {
    //
    //      self.sigma2BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.sigma2BarFactor), y: 1.0)
    //      self.sigma3BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.sigma3BarFactor), y: 1.0)
    //      self.sigma2BarView.isHidden = false
    //      self.sigma3BarView.isHidden = false  //always scaled to full width
    //    }
    //    else
    //    {
    //      self.sigma2BarView.isHidden = true
    //      self.sigma3BarView.isHidden = true
    //    }
    
    
    
    //    for (index,station) in item.Stations!.enumerated()
    for (index,station) in selectedStations.enumerated()
    {
      //      let stationFactor = self.event.assignStationFactor(item, station: station, stationsExistPastSigma1: stationsExistBeyondSigma1)
      let stationFactor = plotStationBarFactor(station: station, totalPlotWidthKm: plotWidthKm)
      var stationView = UIView()
      stationView.frame.origin.x = self.centerBarView.frame.origin.x + (self.weatherBarView.bounds.width / 2) * CGFloat(stationFactor)
      stationView.frame.origin.y = self.weatherBarView.frame.origin.y
      stationView.frame.size.width = 3
      stationView.frame.size.height = self.weatherBarView.frame.height
      if detailData.WeatherInfoAvailable!
      {
        stationView.backgroundColor = cloudColor(station.CloudCover)
      } else {
        stationView.backgroundColor = .gray
      }
      self.weatherBarView.addSubview(stationView)
      //      print("index=",index,"stationView.frame.origin.x=",stationView.frame.origin.x)
    }
  }
  
  func addStationCursor()
  {
    //add station cursor subview
    self.stationCursor.frame.size.width = 11
    self.stationCursor.frame.size.height = 3
    self.stationCursor.frame.origin.y = self.weatherBarView.frame.origin.y + self.weatherBarView.frame.height - self.centerGrayBar.frame.height - self.stationCursor.frame.height
    self.stationCursor.frame.origin.x = self.centerBarView.frame.origin.x
    self.stationCursor.backgroundColor = .black
    self.weatherBarView.addSubview(self.stationCursor)
    self.weatherBarView.bringSubviewToFront(self.stationCursor)
  }
}


// MARK: -  Extension - Colllection functions
extension DetailViewController: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
//    print("> number of items")
//    print("selectedStations:")
//    for (index,station) in self.selectedStations.enumerated()
//    {
//      print("index=",index)
//      print(station)
//      print()
//    }
//    print()
//
    return selectedStations.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
//    print()
//    print(">collectionView")
//    print("cellForItemAt > indexPath:",indexPath)
//    print("station=",selectedStations[indexPath.item])
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StationCell
    cell.backgroundColor = #colorLiteral(red: 0.2043271959, green: 0.620110333, blue: 0.6497597098, alpha: 1)
    updateStationFlds(cell: &cell, indexPath: indexPath, stations: selectedStations, itm: selectedEventDetails)
    //    moveCursorToStation(indexPath: indexPath)
//    visibleIndexPaths = collectionView.indexPathsForVisibleItems
//    currentStationIndexPath = visibleStationIndexPath()
//    print("<collectionView")
//    print()
    return cell
  }
  
  func adjustCellWidth()
  {
//    print()
//    print("adjustCellWidth")
    var cellHeight = stationCollectionView.bounds.height
    if let flowLayout = self.stationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
    {
      flowLayout.minimumLineSpacing = 0
      flowLayout.minimumInteritemSpacing = 0
      flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      var cellWidth = self.stationCollectionView.bounds.width - flowLayout.minimumLineSpacing
      //      var cellWidth = self.view.safeAreaLayoutGuide.layout - flowLayout.minimumLineSpacing
      //      print("stationCollectionView.bounds.width=",stationCollectionView.bounds.width)
      //      print("adjusted cellWidth=",cellWidth)
      stationCollectionView.bounds.origin.x = 0
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
//      print("flowLayout.itemSize=",flowLayout.itemSize)
//      print("currentStationIndexPath=",currentStationIndexPath)
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
//    print()
//    print(">scrollViewDidEndDecelerating")
//    print("visibleIndexPaths=",visibleIndexPaths)
//    moveCursorToStation(indexPath: visibleStationIndexPath)
    currentStationIndexPath = visibleStationIndexPath()
    moveCursorToStation(indexPath: visibleStationIndexPath())
//    print("<scrollViewDidEndDecelerating")
//    print("currentStationIndexPath=",currentStationIndexPath)
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
    
    var labelAttrStr = NSMutableAttributedString(string: label, attributes: labelAttributes)
    let fieldAttrStr = NSAttributedString(string: field, attributes: fieldAttributes)
    let unitsAttrStr = NSAttributedString(string: units, attributes: unitsAttributes)
    
    labelAttrStr.append(fieldAttrStr)
    labelAttrStr.append(unitsAttrStr)
    
    return labelAttrStr
  }
  
  func clearFieldsAndIcons()
  {
    print("begin clearFieldsAndIcons")
    self.eventTitle.text = "—"
    self.eventRank.text = "Rank: —"
    self.eventTimeRemaining.text = "_"
    self.eventFeed.text = "—"
    self.eventRA.text = "RA —"
    self.eventDec.text = "DE   —"
    self.eventStarBV.text = "B-V   —"
    self.eventStarDiameter.text = "Stellar Dia.          —"
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
    print("end clearFieldsAndIcons")
  }
  
  func printEventDetails()
  {
    print("eventTitle=\(eventTitle!.text!)")
    print("eventRank=\(eventRank!.text!)")
    print("eventTimeRemaining=\(eventTimeRemaining!.text!)")
    print("eventFeed=\(eventFeed!.text!)")
    print("weatherBarView=\(weatherBarView!)")
    print("sigma1BarView=\(sigma1BarView!)")
    print("shadowBarView=\(shadowBarView!)")
    print("centerBarView=\(centerBarView!)")
    print("eventRA=\(eventRA.text)")
    print("eventDec=\(eventDec.text)")
    print("eventStarBV=\(eventStarBV.text)")
    print("eventStarDiameter=\(eventStarDiameter.text)")
    print("eventAsteroidOrigin=\(eventAsteroidOrigin.text)")
    print("eventAsteroidDiameter=\(eventAsteroidDiameter.text)")
    print("eventStarMagnitude=\(eventStarMagnitude.text)")
    print("eventAsteroidMagnitude=\(eventAsteroidMagnitude.text)")
    print("eventCombinedMagnitude=\(eventCombinedMagnitude.text)")
    print("eventMagnitudeDrop=\(eventMagnitudeDrop.text)")
    print("eventCameraSectionTitle=\(eventCameraSectionTitle.text)")
    print("eventCamCombinedMag=\(eventCamCombinedMag.text)")
    print("eventCamMagDrop=\(eventCamMagDrop.text)")
    print("eventCamAseroidRotation=\(eventCamAseroidRotation.text)")
    print("eventCamRotationAmplitude=\(eventCamRotationAmplitude.text)")
  }
  
  func testStation()
  {
    //*********************station tests**********************
    //    var testStations = [Station]()
    //    var newStation = Station()
    //    newStation.StationId = 1
    //    newStation.StationName = "Station Name"
    //    newStation.EventTimeUtc = "2019-07-04T21:04:57.488"
    //    newStation.WeatherInfoAvailable = true
    //    newStation.CloudCover = 5
    //    newStation.Wind = 3
    //    newStation.TempDegC = 24
    //    newStation.HighCloud = false
    //    newStation.StationPos = 1
    //
    //    newStation.ChordOffsetKm = 10     //test value
    //
    //    newStation.OccultDistanceKm = 1.1
    //    newStation.IsOwnStation = true
    //    newStation.IsPrimaryStation = true
    //    testStations.append(newStation)
    //
    //    var testItem = EventDetails()
    //    testItem.Id = "id123456789"
    //    testItem.Object = "Test Object"
    //    testItem.StarMag = 9.87
    //    testItem.MagDrop = 6.54
    //    testItem.MaxDurSec = 1.23
    //    testItem.ErrorInTimeSec = 0.7
    //    testItem.StarColour = 3
    //    testItem.Stations = testStations
    //    testItem.Feed = "Test Feed"
    //    testItem.Rank = 97
    //    testItem.BV = 0.543
    //    testItem.CombMag = 9.99
    //    testItem.AstMag = 14.7
    //    testItem.MoonDist = 1.1
    //    testItem.MoonPhase = 11
    //
    //    testItem.AstDiaKm = 20     //test value
    //
    //    testItem.AstDistUA = 1.1
    //    testItem.RAHours = 12.345
    //    testItem.DEDeg = 67.89
    //    testItem.StarAlt = 35.7
    //    testItem.StarAz = 123.4
    //    testItem.SunAlt = -11
    //    testItem.MoonAlt = 11
    //    testItem.MoonAz = 11
    //    testItem.StellarDia = 0.05
    //    testItem.StarName = "TYC 123"
    //    testItem.OtherStarNames = ""
    //    testItem.AstClass = "NEO"
    //    testItem.AstRotationHrs = 7.8
    //    testItem.AstRotationAmplitude = 0.9
    //    testItem.PredictionUpdated = "July 4, 2019"
    //
    //    testItem.OneSigmaErrorWidthKm = 20     //test value
    //
    //    item = testItem
    //********************************************************
  }
}
