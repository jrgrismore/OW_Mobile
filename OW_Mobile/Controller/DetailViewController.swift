//
//  DetailViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 3/23/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

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
  
  var stationsDetails = [EventDetails]()
  var selectedStations = [Station]()
  var selectedEventDetails = EventDetails()
  var event = OccultationEvent()
  var stationCursor = UIView()
  var visibleIndexPaths = [IndexPath]()
  
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
  override func viewWillLayoutSubviews()
  {
    super.viewWillLayoutSubviews()
    stationCollectionView.collectionViewLayout.invalidateLayout()
    var cellHeight = stationCollectionView.bounds.height
    //set layout attributes
    if let flowLayout = self.stationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
    {
      flowLayout.minimumLineSpacing = 0
      flowLayout.minimumInteritemSpacing = 0
      flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      var cellWidth = self.stationCollectionView.bounds.width - flowLayout.minimumLineSpacing
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    stationCollectionView.delegate = self
    stationCollectionView.dataSource = self
    self.spinnerView.layer.cornerRadius = 20
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    print()
    print(">viewWillAppear")
    eventDetailView.isHidden = false
    
   self.title = detailData.Object
    
    stationsDetails = OWWebAPI.shared.loadDetails()
    let detailsIndex = stationsDetails.index(where: { $0.Id == detailData.Id  })
    selectedEventDetails = stationsDetails[detailsIndex!]
    let chordSortedStations = self.event.stationsSortedByChordOffset(selectedEventDetails, order: .ascending)
    
    selectedStations = chordSortedStations
    
    let primaryIndex = self.event.primaryStationIndex(chordSortedStations)
    print("scroll to primaryIndex = ",primaryIndex)
    updateEventInfoFields(eventItem: selectedEventDetails)
    self.stationCollectionView.reloadData()
    DispatchQueue.main.async
      {
        self.stationCollectionView.scrollToItem(at: IndexPath(item: primaryIndex!, section: 0), at: .centeredHorizontally, animated: false)
        self.moveCursorToStation(indexPath: IndexPath(item: primaryIndex!, section: 0))
    }
    print("<viewWillAppear")
    print()
  }
  
  override func viewDidAppear(_ animated: Bool)
  {
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    eventDetailView.isHidden = true
  }
  
  // MARK: - Event Detail Functions
  func updateEventInfoFields(eventItem itm: EventDetails)
  {
    print(">updateEventInfoFields")
    //for testing
    var item = itm
//    selectedStations = self.event.stationsSortedByChordOffset(item, order: .ascending)
    
    DispatchQueue.main.async
      {
        self.eventTitle.attributedText = self.event.updateObjectFld(item)
        self.eventRank.attributedText = self.event.updateRankFld(item)
//        let timeTuple = self.updateEventTimeFlds(&item)
        let timeTuple = self.event.updateEventTimeFlds(&item)
        self.eventTimeRemaining.attributedText = timeTuple.remainingTime
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
        cell.eventSunAlt.text = ""
      }
    }
    else
    {
      cell.sunAltImg.image = nil
      cell.eventSunAlt.text = ""
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
      moonDist = String(format: "%0.0f", item.MoonDist!)
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

  fileprivate func updateShadowPlot(_ item: EventDetails)
  {
    //update shadow bars plot
    let stationsExistBeyondSigma1:Bool = self.event.barPlotToSigma3(item)
    
    var plotWidthKm = totalPlotWidthKm(item, scale: .sigma3Edge)
    let outerChordWidth = farthestChordWidth(item)
    print("outerChordWidth=",outerChordWidth)
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
    } else if outerChordWidth > shadowWidthKm(item)
    {
      plotWidthKm = totalPlotWidthKm(item, scale: .sigma1Edge)
    } else if outerChordWidth <= shadowWidthKm(item)
    {
      plotWidthKm = totalPlotWidthKm(item, scale: .shadowEdge)
    }
    print("plotWidthKm=",plotWidthKm)

    
    
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
    print()
//    print("primaryChordOffset=",primaryChordOffset)
    let primaryFactor = plotStationBarFactor(station: primaryStation, totalPlotWidthKm: plotWidthKm)
//    print("primaryFactor=",primaryFactor)
    self.userBarView.frame.origin.x = self.centerBarView.frame.origin.x + (self.weatherBarView.bounds.width / 2) * CGFloat(primaryFactor)
    
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
    
    
    
    //add station cursor subview
    self.stationCursor.frame.size.width = 11
    self.stationCursor.frame.size.height = 3
    self.stationCursor.frame.origin.y = self.weatherBarView.frame.origin.y + self.weatherBarView.frame.height - self.centerGrayBar.frame.height - self.stationCursor.frame.height
    self.stationCursor.frame.origin.x = self.centerBarView.frame.origin.x
    self.stationCursor.backgroundColor = .black
    self.weatherBarView.addSubview(self.stationCursor)
    self.weatherBarView.bringSubviewToFront(self.stationCursor)
    
//    print("primary station index = ",self.event.primaryStationIndex(self.selectedStations))
    print("<updateEventInfoFields")
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
    print()
    print(">collectionView")
//    print("cellForItemAt > indexPath:",indexPath)
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StationCell
    cell.backgroundColor = #colorLiteral(red: 0.2043271959, green: 0.620110333, blue: 0.6497597098, alpha: 1)
    updateStationFlds(cell: &cell, indexPath: indexPath, stations: selectedStations, itm: selectedEventDetails)
    //    moveCursorToStation(indexPath: indexPath)
    visibleIndexPaths = collectionView.indexPathsForVisibleItems
    print("<collectionView")
    print()
    return cell
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    print()
    print(">scrollViewDidEndDecelerating")
//    print("visibleIndexPaths=",visibleIndexPaths)
    let visibleRect = CGRect(origin: stationCollectionView.contentOffset, size: stationCollectionView.bounds.size)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    let visibleIndexPath = stationCollectionView.indexPathForItem(at: visiblePoint)
    moveCursorToStation(indexPath: visibleIndexPath!)
    print("<scrollViewDidEndDecelerating")
  }
  
  func moveCursorToStation(indexPath: IndexPath)
  {
    print()
    print(">moveCursorToStation")
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
        print("<moveCursorToStation")
        print()
    }
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
