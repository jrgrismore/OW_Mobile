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

  var selectionObject: String!
  var detailStr: String = ""
  var eventID: String = ""
  var complete: Bool = false
  var selectedEvent = EventWithDetails()
  var eventsWithDetails = [EventWithDetails]()

  var stationsDetails = [EventDetails]()
//  var selectedStations = [Station]()
  var selectedStations = [ObserverStation]()
//  var selectedEventDetails = EventDetails()
    //  var selectedEventDetails = EventWithDetails()
  var event = OccultationEvent()
  var stationCursor = UIView()
  var visibleIndexPaths = [IndexPath]()
  
//  var selectedEvent = EventWithDetails()

  var currentStationIndexPath = IndexPath()
  
  var stationBarSubViewsExist = false
  var stationCursorExists = false
  var dimGray = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
  
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
    self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    eventDetailView.isHidden = false
    stationBarSubViewsExist = false
    stationCursorExists = false
    
//    let detailObject = detailData.Object!.replacingOccurrences(of: "(-2147483648) ", with: "")
//    self.title = detailObject
    self.title = selectionObject
    
//    stationsDetails = OWWebAPI.shared.loadDetails()
//    let detailsIndex = stationsDetails.index(where: { $0.Id == detailData.Id  })
//    selectedEventDetails = stationsDetails[detailsIndex!]

    
    let selectedEventIndex = eventsWithDetails.index(where: { $0.Id == eventID  } )
    
//    selectedEvent = eventsWithDetails[selectedEventIndex!]
    let primaryStation = OccultationEvent.primaryStation(selectedEvent)
    
//    let tempEvent = OccultationEvent()
    let chordSortedStations = OccultationEvent.stationsSortedByChordOffset(selectedEvent, order: .ascending)
    
    selectedStations = chordSortedStations
    
    let primaryIndex = OccultationEvent.primaryStationIndex(selectedEvent)
    updateEventInfoFields(eventItem: selectedEvent)
    if complete
    {
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
    } else {
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]
    }
    
     DispatchQueue.main.async
    {
        self.stationCollectionView.scrollToItem(at: IndexPath(item: primaryIndex!, section: 0), at: .centeredHorizontally, animated: false)
        self.stationCollectionView.layoutIfNeeded()
    }
    }
  
  override func viewDidAppear(_ animated: Bool)
  {
    adjustCellWidth()
    let primaryIndex = OccultationEvent.primaryStationIndex(selectedStations)
    currentStationIndexPath = IndexPath(item:primaryIndex!, section: 0)
    DispatchQueue.main.async
      {
        self.stationCollectionView.scrollToItem(at: IndexPath(item: primaryIndex!, section: 0), at: .centeredHorizontally, animated: false)
        self.moveCursorToStation(indexPath: IndexPath(item: primaryIndex!, section: 0))
    }
    updateShadowPlot(selectedEvent)
  }
  
  override func viewWillLayoutSubviews()
  {
    stationCollectionView.frame.size.width = self.view.safeAreaLayoutGuide.layoutFrame.size.width
    super.viewWillLayoutSubviews()
  }
  
  override func viewDidLayoutSubviews()
  {
    super.viewDidLayoutSubviews()
   }

  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
  {
    super.willTransition(to: newCollection, with: coordinator)
  }
  
  @objc func deviceRotated()
  {
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

  DispatchQueue.main.async {
    self.stationCollectionView.setNeedsLayout()
    self.adjustCellWidth()
    self.updateShadowPlot(self.selectedEvent)
    self.stationCollectionView.scrollToItem(at: self.currentStationIndexPath, at: .centeredHorizontally, animated: false)
  }
  moveCursorToStation(indexPath: currentStationIndexPath)
}

  override func viewWillDisappear(_ animated: Bool)
  {
    eventDetailView.isHidden = true
   }
  
  // MARK: - Event Detail Functions
  func updateEventInfoFields(eventItem itm: EventWithDetails)
  {
    //testing var
    var item = itm
    let primaryStation = OccultationEvent.primaryStation(item)!

    selectedStations = OccultationEvent.stationsSortedByChordOffset(item, order: .ascending)

    self.eventTitle.attributedText = self.event.updateObjectFld(item)
    self.eventRank.attributedText = self.event.updateRankFld(item)
    DispatchQueue.main.async
      {
        let primaryStationIndex = OccultationEvent.primaryStationIndex(self.selectedStations)
        let timeTuple = currentEvent.updateEventTimeFlds(&item,stationIndex: primaryStationIndex!)
        var remainingTime: NSMutableAttributedString = timeTuple.remainingTime as! NSMutableAttributedString
        if remainingTime.string == "completed"
        {
          print("Detail > found completed")
          remainingTime = NSMutableAttributedString(string: "")
          //dim/gray out asteriod hame, date and time
          self.eventTitle.textColor = self.dimGray
          self.eventRank.textColor = self.dimGray
          self.eventFeed.textColor = self.dimGray
        }
        //this does not take effect until return to previous view controller
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title3)]

        self.eventTimeRemaining.attributedText = remainingTime
        self.eventFeed.attributedText = self.event.updateFeedFld(item)
        self.eventRA.attributedText = self.event.updateRAFld(item)
        self.eventDec.attributedText = self.event.updateDecFld(item)
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
  
  func updateStationFlds(cell: inout StationCell, indexPath: IndexPath, stations: [ObserverStation], itm: EventWithDetails)
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
    
    let timeTuple = event.updateEventTimeFlds(&item, stationIndex: indexPath.row)
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
//    if item.StarAlt != nil
    if stations[stationIndex].StarAlt != nil
    {
      starAltStr = String(format: "%0.0f°",stations[stationIndex].StarAlt!)
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
    cell.eventMoonAlt.text = moonAltStr
    
    var moonDist = "—"
    if stations[stationIndex].MoonDist != nil
    {
      moonDist = String(format: "%0.0f°", stations[stationIndex].MoonDist!)
    }
    cell.eventMoonSeparation.text = moonDist
    
    var starColorImage: UIImage
    if stations[stationIndex].StarColour != nil
    {
      starColorImage = starColorIcon(Int(stations[stationIndex].StarColour!))
      cell.starAltImg.image = starColorImage
    }
    else
    {
      cell.starAltImg.image = nil
    }
  }
  
  func updateShadowPlot(_ item: EventWithDetails)
  {
    let stationsExistBeyondSigma1:Bool = OccultationEvent.barPlotToSigma3(item)
    
    var plotWidthKm = totalPlotWidthKm(item, scale: .sigma3Edge)
    let outerChordWidth = farthestChordWidth(item)
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
    
    let plotBarFactors = plotBarsWidthFactors(item, totalPlotWidthKm: plotWidthKm)
    
    self.shadowBarView.bounds.size.width = self.weatherBarView.bounds.width
    self.sigma1BarView.bounds.size.width = self.weatherBarView.bounds.width
    self.sigma2BarView.bounds.size.width = self.weatherBarView.bounds.width
    self.sigma3BarView.bounds.size.width = self.weatherBarView.bounds.width
    
    self.shadowBarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.shadowBarFactor), y: 1.0)
    self.sigma1BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.sigma1BarFactor), y: 1.0)
    self.sigma2BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.sigma2BarFactor), y: 1.0)
    self.sigma3BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarFactors.sigma3BarFactor), y: 1.0)
    
    let primaryStation = OccultationEvent.primaryStation(item)!
    let primaryChordOffset = primaryStation.ChordOffsetKm!
    let primaryFactor = plotStationBarFactor(station: primaryStation, totalPlotWidthKm: plotWidthKm)
    self.userBarView.frame.origin.x = self.centerBarView.frame.origin.x + (self.weatherBarView.bounds.width / 2) * CGFloat(primaryFactor)
    
    self.weatherBarView.subviews.forEach( { $0 .removeFromSuperview() })
    addStationsSubviews(plotWidthKm)
    addStationCursor()
  }
  
  func moveCursorToStation(indexPath: IndexPath)
  {
    var currentIndex = indexPath.item
    DispatchQueue.main.async
      {
        if self.weatherBarView.subviews[currentIndex].frame.origin.x >= self.weatherBarView.frame.minX
          && self.weatherBarView.subviews[currentIndex].frame.origin.x < self.weatherBarView.frame.maxX
        {
          self.stationCursor.isHidden = false
          let currentStationView = self.weatherBarView.subviews[currentIndex]
          self.stationCursor.frame.origin.x = currentStationView.frame.origin.x + (currentStationView.frame.width / 2) - self.stationCursor.frame.width / 2
        } else {
          self.stationCursor.isHidden = true
        }
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
    for (index,station) in selectedStations.enumerated()
    {
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
    return selectedStations.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StationCell
    cell.backgroundColor = #colorLiteral(red: 0.2043271959, green: 0.620110333, blue: 0.6497597098, alpha: 1)
    updateStationFlds(cell: &cell, indexPath: indexPath, stations: selectedStations, itm: selectedEvent)
    return cell
  }
  
  func adjustCellWidth()
  {
    var cellHeight = stationCollectionView.bounds.height
    if let flowLayout = self.stationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
    {
      flowLayout.minimumLineSpacing = 0
      flowLayout.minimumInteritemSpacing = 0
      flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      var cellWidth = self.stationCollectionView.bounds.width - flowLayout.minimumLineSpacing
      stationCollectionView.bounds.origin.x = 0
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    currentStationIndexPath = visibleStationIndexPath()
    moveCursorToStation(indexPath: visibleStationIndexPath())
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
  
}
