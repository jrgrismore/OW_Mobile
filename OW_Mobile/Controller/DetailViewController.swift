//
//  DetailViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 3/23/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
  let reuseIdentifier = "StationCell"
  @IBOutlet weak var stationCollectionView: UICollectionView!
 
  var selection: String!
  var detailStr: String = ""
  var eventID: String = ""
  
  var stationsDetails = [EventDetails]()
  var selectedStations = [Station]()
  
  var detailData = Event(Id:"",
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
  
  var selectedEventDetails = EventDetails()

  var occultationEvent = OccultationEvent()

//  var occultationStation = OccultationStation(station: <#Station#>)
  
  
  // MARK: - Spinner Outlets
  @IBOutlet weak var spinnerView: UIView!
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var spinnerLbl: UILabel!

  // MARK: - Label Outlets
  @IBOutlet weak var eventTitle: UILabel!
  @IBOutlet weak var eventRank: UILabel!
  @IBOutlet weak var eventTimeRemaining: UILabel!
  @IBOutlet weak var eventFeed: UILabel!
  
//  @IBOutlet weak var eventStationID: UILabel!
//  @IBOutlet weak var eventClouds: UILabel!
//  @IBOutlet weak var eventTemperature: UILabel!
//  @IBOutlet weak var eventChordDistance: UILabel!
//  @IBOutlet weak var eventTime: UILabel!
//  @IBOutlet weak var eventTimeError: UILabel!
//  @IBOutlet weak var eventStarAlt: UILabel!
//  @IBOutlet weak var eventSunAlt: UILabel!
//  @IBOutlet weak var eventMoonAlt: UILabel!
//  @IBOutlet weak var eventMoonSeparation: UILabel!
  
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
  @IBOutlet weak var weatherBarView: UIView!
  @IBOutlet weak var sigma3BarView: UIView!
  @IBOutlet weak var sigma2BarView: UIView!
  @IBOutlet weak var sigma1BarView: UIView!
  @IBOutlet weak var shadowBarView: UIView!
  @IBOutlet weak var centerBarView: UIView!
  @IBOutlet weak var userBarView: UIView!

//  @IBOutlet weak var eventCloudImg: UIImageView!
//  @IBOutlet weak var eventWindStrengthImg: UIImageView!
//  @IBOutlet weak var eventWindSignImg: UIImageView!
//  @IBOutlet weak var eventTempImg: UIImageView!
//  @IBOutlet weak var sigmaImg: UIImageView!
//  @IBOutlet weak var starAltImg: UIImageView!
//  @IBOutlet weak var moonAltImg: UIImageView!
//  @IBOutlet weak var sunAltImg: UIImageView!
  
  @IBOutlet weak var asterRotAmpView: UIStackView!
  @IBOutlet weak var bvStarDiamView: UIStackView!
  
  // MARK: - Constraint Outlets
  @IBOutlet weak var shadowBarWidth: NSLayoutConstraint!
  
  
  // MARK: - View functions
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    print("numberOfItemsInSection")
    print("stationDetails.count=",selectedStations.count)
    return selectedStations.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    print("cellForItemAt indexPath:",indexPath)
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StationCell
    cell.backgroundColor = #colorLiteral(red: 0.2043271959, green: 0.620110333, blue: 0.6497597098, alpha: 1)
    //    fillCellFields(cell: &cell, indexPath: indexPath)
//    updateEventInfoFields(eventItem: selectedEventDetails)
//    updateStationFlds(cell: &cell, indexPath: indexPath, eventItem: stationsDetails[0])
    updateStationFlds(cell: &cell, indexPath: indexPath, stations: selectedStations, itm: selectedEventDetails)
    return cell
  }
  
  
  
  // MARK: - View functions
  override func viewWillLayoutSubviews()
  {
    print("viewWillLayoutSubviews")
    super.viewWillLayoutSubviews()
    stationCollectionView.collectionViewLayout.invalidateLayout()
    //set cell size
//    let cellsInRow = 5
    //    var cellHeight = 180
    var cellHeight = stationCollectionView.bounds.height-6
    //set layout attributes
    if let flowLayout = self.stationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
    {
      //      print("UIScreen.main.bounds.width=",UIScreen.main.bounds.width)
      //      print("myEventsCollection.bounds.width=",myEventsCollection.bounds.width)
      flowLayout.minimumLineSpacing = 3
      flowLayout.minimumInteritemSpacing = 0
      flowLayout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      //      print("totalHInsets=",totalHInsets)
      //      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
      //      print("totalInteritemSpace=",totalInteritemSpace)
      //            let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      //            let cellWidth = (stationCollectionView.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      //      print("cellWidth=",cellWidth)
      //? is this the right way to do this ?
      //            let cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width - totalHInsets
      //?does this work for all screen sizes and orientations?
      var cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width - flowLayout.minimumLineSpacing
      //      var cellWidth = self.stationCollectionView.bounds.width - totalHInsets
      //      var cellWidth = self.stationCollectionView.bounds.width - flowLayout.minimumInteritemSpacing
      //      cellHeight = 100
      //      cellWidth = 100
      print("cell height=",cellHeight,"   cell width=",cellWidth)
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
//    let detailEndpoint = OWWebAPI.shared.createEventDetailURL(owSession: OWWebAPI.owSession, eventID: detailData.Id!)
//    print("detailEndpoint=",detailEndpoint)
    self.title = detailData.Object
    
    stationsDetails = OWWebAPI.shared.loadDetails()
//   let detailsList = OWWebAPI.shared.loadDetails()
//    let detailsIndex = detailsList.index(where: { $0.Id == detailData.Id  })
    let detailsIndex = stationsDetails.index(where: { $0.Id == detailData.Id  })
    selectedEventDetails = stationsDetails[detailsIndex!]
    selectedStations = selectedEventDetails.Stations!
//    stationsDetails = selectedEventDetails.Stations![0]
    print("DetailsViewController > details = ",selectedEventDetails)
    print("DetailsViewController > stationDetails = ",stationsDetails)
    print()
    print("selectedEventDetails=",selectedEventDetails)
    //pretty print stations sorted by chord offset
    print()
    print("chord sorted stations")
    let chordSortedStations = self.occultationEvent.stationsSortedByChordOffset(selectedEventDetails, order: .ascending)
    for station in chordSortedStations
    {
      let stationForPrint = OccultationStation(station: station)
      stationForPrint.prettyPrint()
    }

    
    updateEventInfoFields(eventItem: selectedEventDetails)
    self.stationCollectionView.reloadData()

    
//    var detailsIndex = 0
//    for details in detailsList
//    {
//      if details.Id == detailData.Id
//      {
//        print("found match.  details = ", details)
//        selectedEventDetails = details
//    clearFieldsAndIcons()
    //       print("DetailsViewController > details = ",selectedEventDetails)
// updateStationFlds(cell: &cell, eventItem: stationsDetails)
//        break
//      }
//      detailsIndex = detailsIndex + 1
    }
    
    
    
//    OWWebAPI.shared.retrieveEventDetails(eventID: detailData.Id!) { (myDetails, error) in
//      DispatchQueue.main.async{self.spinnerLbl.text = "download complete"}
//      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds
//
//      self.selectedEventDetails = myDetails!
//      DispatchQueue.main.async{self.spinnerLbl.text = "updating details"}
//      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds
////       self.updateEventInfoFields(eventItem: self.selectedEventDetails)
//      DispatchQueue.main.async
//        {
//          self.activitySpinner.stopAnimating()
//          self.spinnerView.isHidden = true
//      }
//
//
//
//    }
//  }

  override func viewDidAppear(_ animated: Bool)
  {
//    clearFieldsAndIcons()
//        stationCollectionView.reloadData()
  }
  
  
  // MARK: - Event Detail Functions
  //  func updateEventInfoFields(indexPath:IndexPath,eventItem itm: EventDetails) //cell: inout StationCell,
  func updateEventInfoFields(eventItem itm: EventDetails)
  {
    print("begin updateEventInfoFields")
    //for testing
    var item = itm
    
    DispatchQueue.main.async
    {
      self.eventTitle.attributedText = self.occultationEvent.updateObjectFld(item)
      self.eventRank.attributedText = self.occultationEvent.updateRankFld(item)
      let timeTuple = self.updateEventTimeFlds(&item)
      self.eventTimeRemaining.attributedText = timeTuple.remainingTime
      self.eventFeed.attributedText = self.occultationEvent.updateFeedFld(item)
      self.eventRA.attributedText = self.occultationEvent.updateRAFld(item)
      self.eventDec.attributedText = self.occultationEvent.updateDecFld(item)
      //insert BVStarDiamView here
      self.eventAsteroidOrigin.attributedText = self.occultationEvent.updateAsteroidClassFld(item)
      self.eventAsteroidDiameter.attributedText = self.occultationEvent.updateAsteroidDiamKM(item)
      self.eventStarMagnitude.attributedText = self.occultationEvent.updateStarMagFld(item)
      self.eventAsteroidMagnitude.attributedText = self.occultationEvent.updateAsteroidMagFld(item)
      self.eventCombinedMagnitude.attributedText = self.occultationEvent.updateCombinedMagFld(item)
      self.eventMagnitudeDrop.attributedText = self.occultationEvent.updateMagDropFld(item)
      self.bvStarDiamView.isHidden = self.occultationEvent.hideBVStarDiamView(item)
      //hide BV ad star diameter if both are nil
      if self.bvStarDiamView.isHidden == false
      {
        self.eventStarBV.attributedText = self.occultationEvent.updateBVFld(item)
        self.eventStarDiameter.attributedText =  self.occultationEvent.updateStarDiamFld(item)
      }
      //hide asteroid rotation and amplitude if both are nil
      self.asterRotAmpView.isHidden = self.occultationEvent.hideAsterRotAmpView(item)
      if self.asterRotAmpView.isHidden == false
      {
        self.eventCamAseroidRotation.attributedText = self.occultationEvent.updateAsteroidRotationFld(item)
        self.eventCamRotationAmplitude.attributedText = self.occultationEvent.updateAsteroidRotationAmpFld(item)
      }
 
      //update shadow bars plot
      let stationsExistBeyondSigma1:Bool = self.occultationEvent.barPlotToSigma3(item)
      
      self.shadowBarView.bounds.size.width = self.weatherBarView.bounds.width
      self.sigma1BarView.bounds.size.width = self.weatherBarView.bounds.width
      self.sigma2BarView.bounds.size.width = self.weatherBarView.bounds.width
      let barsTuple = self.occultationEvent.updateShadowBarView(item,stationsExistPastSigma1: stationsExistBeyondSigma1)
      self.shadowBarView.transform = CGAffineTransform(scaleX: CGFloat(barsTuple.shadowFactor), y: 1.0)
      self.sigma1BarView.transform = CGAffineTransform(scaleX: CGFloat(barsTuple.sig1Factor), y: 1.0)
      self.userBarView.frame.origin.x = self.centerBarView.frame.origin.x + (self.weatherBarView.bounds.width / 2) * CGFloat((item.Stations![0].ChordOffsetKm! / pathBarsTotalWidth(astDiamKm: item.AstDiaKm!, sigma1WidthKm: item.OneSigmaErrorWidthKm!, stationsExistPastSigma1: stationsExistBeyondSigma1)))
      
      if stationsExistBeyondSigma1
      {
            self.sigma2BarView.transform = CGAffineTransform(scaleX: CGFloat(barsTuple.sig2Factor), y: 1.0)
            self.sigma2BarView.isHidden = false
            self.sigma3BarView.isHidden = false  //always scaled to full width
       }
      else
      {
            self.sigma2BarView.isHidden = true
            self.sigma3BarView.isHidden = true
      }
    }   // end DispatchQueue.main.async

//*******************************************************************
// containing view is hidden until these are implemented in web api
      //camera combined magnitude ???
//      DispatchQueue.main.async{self.eventCamCombinedMag.text = "??? Comb. Mag ???"}
      //camera mag drop ???
//      DispatchQueue.main.async{self.eventCamMagDrop.text = "??? Mag Drop ???"}
//*******************************************************************

    
    
    DispatchQueue.main.async
    {
      //print stations
     self.occultationEvent.printStations(item)
      //print primary station
      print()
      print("primary station = ",self.occultationEvent.primaryStation(item))
      //print own stations
      print()
      for myStation in self.occultationEvent.myStations(item)!
      {
        print("myStation = ",myStation)
      }
      //print others' stations
      print()
      for otherStation in self.occultationEvent.otherStations(item)!
      {
        print("others' stations = ",otherStation)
      }
      //print index of primary station
      print("primary station index = ",self.occultationEvent.primaryStationIndex(item))
      //print station at last index
      print("last station = ", self.occultationEvent.stationAtIndex(index: item.Stations!.count-1, item))
      //print stations sorted by ChordOffsetKm fron negative to positive (L to R)
      print("station sort = \n",self.occultationEvent.stationsSortedByChordOffset(item,order: .descending))
      //print stations sorted by Cloud Cover fron negative to positive (L to R)
      print("station sort = \n",self.occultationEvent.stationsSortedByCloudCover(item,order: .descending))
      //pretty print stations sorted by chord offset
      let chordSortedStations = self.occultationEvent.stationsSortedByChordOffset(item, order: .ascending)
      for station in chordSortedStations
      {
        let stationForPrint = OccultationStation(station: station)
        stationForPrint.prettyPrint()
      }
      
    }
    print("end updateEventInfoFields")
  }

//  func updateStationFlds(cell: inout StationCell, indexPath: IndexPath, eventItem: EventDetails)
  func updateStationFlds(cell: inout StationCell, indexPath: IndexPath, stations: [Station], itm: EventDetails)
    {
      var item = itm
      
      let stationIndex = indexPath.row
      print("begin updateStationFlds")
      var stationPosIconVal : Int?
      stationPosIconVal = 0
      if stations[stationIndex].StationPos != nil
      {
        stationPosIconVal = stations[stationIndex].StationPos!
      }
      //    DispatchQueue.main.async{cell.sigmaImg.image = stationSigmaIcon(stationPosIconVal)}
      cell.sigmaImg.image = stationSigmaIcon(stationPosIconVal)
      
      var stationChordDistStr = "Chord: — km"
      if stations[stationIndex].ChordOffsetKm != nil
      {
        stationChordDistStr = String(format: "Chord: %0.0f km",stations[stationIndex].ChordOffsetKm!)
      }
      //    DispatchQueue.main.async{self.eventChordDistance.text = stationChordDistStr}
      cell.eventChordDistance.text = stationChordDistStr
      
      var stationName = "—"
      if stations[stationIndex].StationName != nil
      {
        stationName = stations[stationIndex].StationName!
      }
      //    DispatchQueue.main.async{self.eventStationID.text = stationName}
      cell.eventStationID.text = stationName
      
      let timeTuple = updateEventTimeFlds(&item)
      cell.eventTime.text = timeTuple.eventTime
      //    cell.eventTimeRemaining.
      
      var errorTimeStr = "—"
      if item.ErrorInTimeSec != nil
      {
        errorTimeStr = String(format: "+/-%0.0f sec",item.ErrorInTimeSec!)
      }
      //    DispatchQueue.main.async{self.eventTimeError.text = errorTimeStr}
      cell.eventTimeError.text = errorTimeStr
      
      //determine if there's weather info available
      //    print("weather info available = ",item.Stations![0].WeatherInfoAvailable)
      if stations[stationIndex].WeatherInfoAvailable != nil && stations[stationIndex].WeatherInfoAvailable!
      {
        //      print("weather info IS available")
        //cloud info
        var cloudCoverStr = " —"
        var cloudIconValue: Int?
        if stations[stationIndex].CloudCover != nil
        {
          cloudCoverStr = String(format: " %d%%",stations[stationIndex].CloudCover!)
          cloudIconValue = stations[stationIndex].CloudCover!
        }
        //      DispatchQueue.main.async{self.eventClouds.text = cloudCoverStr}
        //      DispatchQueue.main.async{self.eventCloudImg.image = cloudIcon(cloudIconValue)}
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
        //      DispatchQueue.main.async{self.eventWindStrengthImg.image = windStrengthIcon(windSpeedIconValue) }
        //      DispatchQueue.main.async{self.eventWindSignImg.image = windSignIcon(windSignIconValue)}
        cell.eventWindStrengthImg.image = windStrengthIcon(windSpeedIconValue)
        cell.eventWindSignImg.image = windSignIcon(windSignIconValue)
        
        //temp info
        var tempStr = "—"
        if stations[stationIndex].TempDegC != nil
        {
          tempStr = String(format: "%d°C",stations[stationIndex].TempDegC!)
        }
        //      DispatchQueue.main.async{self.eventTemperature.text = tempStr}
        //      DispatchQueue.main.async{self.eventTempImg.image = thermIcon(item.Stations![0].TempDegC!)}
        cell.eventTemperature.text = tempStr
        cell.eventTempImg.image = thermIcon(stations[stationIndex].TempDegC!)
        
        //high cloud info
        //need code to set icon
        var highCloudStr = ""
        if stations[stationIndex].HighCloud != nil
        {
          highCloudStr = String(format: "%@",stations[stationIndex].HighCloud!.description)
        }
        
      } else {
        //      print("weather info NOT available")
        //      DispatchQueue.main.async{self.eventCloudImg.image = nil}
        //      DispatchQueue.main.async{self.eventClouds.text = ""}
        //      DispatchQueue.main.async{self.eventWindStrengthImg.image = nil}
        //      DispatchQueue.main.async{self.eventWindSignImg.image = nil}
        //      DispatchQueue.main.async{self.eventTempImg.image = nil}
        //      DispatchQueue.main.async{self.eventTemperature.text = ""}
        
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
      //    DispatchQueue.main.async{self.eventStarAlt.text = starAltStr}
      cell.eventStarAlt.text = starAltStr
      
      var sunAltStr = "—"
      if item.SunAlt != nil
      {
        sunAltStr = String(format: "%0.0f°", item.SunAlt!)
        if item.SunAlt! > -12.0
        {
          //        DispatchQueue.main.async {self.sunAltImg.image = #imageLiteral(resourceName: "sun.png")}
          cell.sunAltImg.image =  #imageLiteral(resourceName: "sun")
        }
        else
        {
          //        DispatchQueue.main.async {self.sunAltImg.image = nil}
          cell.sunAltImg.image = nil
        }
      }
      else
      {
        //      DispatchQueue.main.async {self.sunAltImg.image = nil}
        cell.sunAltImg.image = nil
      }
      //    DispatchQueue.main.async{self.eventSunAlt.text = sunAltStr}
      cell.eventSunAlt.text = sunAltStr
      
      var moonAltStr = "—"
      var moonPhaseImage: UIImage
      if item.MoonAlt != nil
      {
        moonAltStr = String(format: "%0.0f°", item.MoonAlt!)
        if item.MoonPhase != nil
        {
          moonPhaseImage =  moonAltIcon(item.MoonPhase!)
          //        DispatchQueue.main.async {self.moonAltImg.image = moonPhaseImage}
          cell.moonAltImg.image = moonPhaseImage
        }
        else
        {
          moonPhaseImage = moonAltIcon(0)
          //        DispatchQueue.main.async {self.moonAltImg.image = moonPhaseImage}
          cell.moonAltImg.image = moonPhaseImage
        }
      }
      //    DispatchQueue.main.async{self.eventMoonAlt.text = moonAltStr}
      cell.eventMoonAlt.text = moonAltStr
      
      var moonDist = "—"
      if item.MoonDist != nil
      {
        moonDist = String(format: "%0.0f", item.MoonDist!)
      }
      //    DispatchQueue.main.async{self.eventMoonSeparation.text = moonDist}
      cell.eventMoonSeparation.text = moonDist
      
      //need code to set icon
      var starColorImage: UIImage
      if item.StarColour != nil
      {
        starColorImage = starColorIcon(item.StarColour)
        //      DispatchQueue.main.async{self.starAltImg.image = starColorImage}
        cell.starAltImg.image = starColorImage
      }
      else
      {
        //      DispatchQueue.main.async{self.starAltImg.image = nil}
        cell.starAltImg.image = nil
      }
      print("end updateStationFlds")
    }
   

  // MARK: - Field Update Functiosn
 
  
  
  
  
  fileprivate func updateEventTimeFlds(_ item: inout EventDetails) -> (eventTime:String, remainingTime:NSAttributedString)
  {
    //need code to format time properly
    var eventUtcStr = "—"
    var leadTimeStr = "—"
    var leadTimeAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    var completionDateStr = "—"
    if item.Stations![0].EventTimeUtc != nil
    {
      //      print("item.Stations![0].EventTimeUtc = ",item.Stations![0].EventTimeUtc!)
      eventUtcStr = formatEventTime(timeString: item.Stations![0].EventTimeUtc!)
      //      print("evnetUtcStr =",eventUtcStr)
      leadTimeStr = leadTime(timeString: item.Stations![0].EventTimeUtc!)
      leadTimeAttrStr = self.formatLabelandField(label:"", field: leadTimeStr, units:"")
      //      print("leadTimeStr = ",leadTimeStr)
      let eventDateFormatter = DateFormatter()
      eventDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
      eventDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
      let completionDate = eventDateFormatter.date(from: item.Stations![0].EventTimeUtc!)!
      //      print("completion date = ",completionDate)
      eventDateFormatter.dateFormat = "dd MMM yyyy"
      //      completionDateStr = eventDateFormatter.string(from: (eventDateFormatter.date(from: item.Stations![0].EventTimeUtc!)!) )
      completionDateStr = eventDateFormatter.string(from: completionDate )
    }
//    cell.eventTime.text = eventUtcStr
    //    DispatchQueue.main.async{self.eventTimeRemaining.text = leadTimeStr + " on " + completionDateStr}
//    DispatchQueue.main.async{self.eventTimeRemaining.attributedText = leadTimeAttrStr }
    return (completionDateStr,leadTimeAttrStr)
  }
  
  
  // MARK: -  Field Utility functions
  //may not need this later
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
    
    
//    self.sigmaImg.image = nil
//    self.eventStationID.text = "—"
//    self.eventCloudImg.image = nil
//    self.eventClouds.text = "—"
//    self.eventWindStrengthImg.image = nil
//    self.eventWindSignImg.image = nil
//    self.eventTempImg.image = nil
//    self.eventTemperature.text = "—"
//    self.eventChordDistance.text = "Chord: — km"
//    self.eventTime.text = "—"
//    self.eventTimeError.text = "—"
//    self.eventStarAlt.text = "—"
//    self.eventSunAlt.text = "—"
//    self.eventMoonAlt.text = "—"
//    self.eventMoonSeparation.text = "—"
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
//    print("eventStationID=\(eventStationID!.text!)")
//    print("eventClouds=\(eventClouds!.text!)")
//    print("eventTemperature=\(eventTemperature!.text!)")
//    print("eventChordDistance=\(eventChordDistance!.text!)")
//    print("eventTime=\(eventTime!.text!)")
//    print("eventTimeError=\(eventTimeError!.text!)")
//    print("eventStarAlt=\(eventStarAlt!.text!)")
//    print("eventSunAlt=\(eventSunAlt.text)")
//    print("eventMoonAlt=\(eventMoonAlt.text)")
//    print("eventMoonSeparation=\(eventMoonSeparation.text)")
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
