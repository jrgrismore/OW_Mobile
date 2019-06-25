//
//  DetailViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 3/23/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  var selection: String!
  var detailStr: String = ""
  var eventID: String = ""
  
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

  
  // MARK: - Spinner Outlets
  @IBOutlet weak var spinnerView: UIView!
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var spinnerLbl: UILabel!

  // MARK: - Label Outlets
  @IBOutlet weak var eventTitle: UILabel!
  @IBOutlet weak var eventRank: UILabel!
  @IBOutlet weak var eventTimeRemaining: UILabel!
  @IBOutlet weak var eventFeed: UILabel!
  
  @IBOutlet weak var eventStationID: UILabel!
  @IBOutlet weak var eventClouds: UILabel!
  @IBOutlet weak var eventTemperature: UILabel!
  @IBOutlet weak var eventChordDistance: UILabel!
  @IBOutlet weak var eventTime: UILabel!
  @IBOutlet weak var eventTimeError: UILabel!
  @IBOutlet weak var eventStarAlt: UILabel!
  @IBOutlet weak var eventSunAlt: UILabel!
  @IBOutlet weak var eventMoonAlt: UILabel!
  @IBOutlet weak var eventMoonSeparation: UILabel!
  
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

  @IBOutlet weak var eventCloudImg: UIImageView!
  @IBOutlet weak var eventWindStrengthImg: UIImageView!
  @IBOutlet weak var eventWindSignImg: UIImageView!
  @IBOutlet weak var eventTempImg: UIImageView!
  @IBOutlet weak var sigmaImg: UIImageView!
  @IBOutlet weak var starAltImg: UIImageView!
  @IBOutlet weak var moonAltImg: UIImageView!
  @IBOutlet weak var sunAltImg: UIImageView!
  
  @IBOutlet weak var asterRotAmpView: UIStackView!
  @IBOutlet weak var bvStarDiamView: UIStackView!
  
  // MARK: - Constraint Outlets
  @IBOutlet weak var shadowBarWidth: NSLayoutConstraint!
  
  
  // MARK: - View functions
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.spinnerView.layer.cornerRadius = 20
  }
  
   override func viewWillAppear(_ animated: Bool)
  {
    let detailEndpoint = OWWebAPI.shared.createEventDetailURL(owSession: OWWebAPI.owSession, eventID: detailData.Id!)
    print("detailEndpoint=",detailEndpoint)
    self.title = detailData.Object
    
    DispatchQueue.main.async
      {
        self.spinnerView.isHidden = false
        self.activitySpinner.startAnimating()
    }
    
    DispatchQueue.main.async{self.spinnerLbl.text = "Fetching Detail Data..."}
    usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds
    
    OWWebAPI.shared.retrieveEventDetails(eventID: detailData.Id!) { (myDetails, error) in
      DispatchQueue.main.async{self.spinnerLbl.text = "download complete"}
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds

      self.selectedEventDetails = myDetails!
      DispatchQueue.main.async{self.spinnerLbl.text = "updating details"}
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds
       self.updateEventInfoFields(eventItem: self.selectedEventDetails)
      DispatchQueue.main.async
        {
          self.activitySpinner.stopAnimating()
          self.spinnerView.isHidden = true
      }
    }
  }

  override func viewDidAppear(_ animated: Bool)
  {
    clearFieldsAndIcons()
  }
  
  
  // MARK: - Event Detail Functions
  func updateEventInfoFields(eventItem itm: EventDetails)
  {
    //for testing
    var item = itm
    
    DispatchQueue.main.async
    {
      self.eventTitle.attributedText = self.occultationEvent.updateObjectFld(item)
      self.eventRank.attributedText = self.occultationEvent.updateRankFld(item)
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

    
    var stationPosIconVal : Int?
    stationPosIconVal = 0
    if item.Stations![0].StationPos != nil
    {
      stationPosIconVal = item.Stations![0].StationPos!
    }
    DispatchQueue.main.async{self.sigmaImg.image = stationSigmaIcon(stationPosIconVal)}
    
    var stationChordDistStr = "Chord: — km"
    if item.Stations![0].ChordOffsetKm != nil
    {
      stationChordDistStr = String(format: "Chord: %0.0f km",item.Stations![0].ChordOffsetKm!)
    }
    DispatchQueue.main.async{self.eventChordDistance.text = stationChordDistStr}
    
    var stationName = "—"
    if item.Stations![0].StationName != nil
    {
      stationName = item.Stations![0].StationName!
    }
    DispatchQueue.main.async{self.eventStationID.text = stationName}
    
    updateEventTimeFlds(&item)
    
    var errorTimeStr = "—"
    if item.ErrorInTimeSec != nil
    {
      errorTimeStr = String(format: "+/-%0.0f sec",item.ErrorInTimeSec!)
    }
    DispatchQueue.main.async{self.eventTimeError.text = errorTimeStr}
    
    //determine if there's weather info available
    //    print("weather info available = ",item.Stations![0].WeatherInfoAvailable)
    if item.Stations![0].WeatherInfoAvailable != nil && item.Stations![0].WeatherInfoAvailable!
    {
      //      print("weather info IS available")
      //cloud info
      var cloudCoverStr = " —"
      var cloudIconValue: Int?
      if item.Stations![0].CloudCover != nil
      {
        cloudCoverStr = String(format: " %d%%",item.Stations![0].CloudCover!)
        cloudIconValue = item.Stations![0].CloudCover!
      }
      DispatchQueue.main.async{self.eventClouds.text = cloudCoverStr}
      DispatchQueue.main.async{self.eventCloudImg.image = cloudIcon(cloudIconValue)}
      
      //wind info
      var windSpeedIconValue: Int?
      var windSignIconValue: Int?
      if item.Stations![0].Wind != nil
      {
        windSignIconValue = item.Stations![0].Wind!
        windSpeedIconValue = item.Stations![0].Wind!
      }
      DispatchQueue.main.async{self.eventWindStrengthImg.image = windStrengthIcon(windSpeedIconValue) }
      DispatchQueue.main.async{self.eventWindSignImg.image = windSignIcon(windSignIconValue)}
      
      //temp info
      var tempStr = "—"
      if item.Stations![0].TempDegC != nil
      {
        tempStr = String(format: "%d°C",item.Stations![0].TempDegC!)
      }
      DispatchQueue.main.async{self.eventTemperature.text = tempStr}
      DispatchQueue.main.async{self.eventTempImg.image = thermIcon(item.Stations![0].TempDegC!)}
      
      //high cloud info
      //need code to set icon
      var highCloudStr = ""
      if item.Stations![0].HighCloud != nil
      {
        highCloudStr = String(format: "%@",item.Stations![0].HighCloud!.description)
      }
      
    } else {
      //      print("weather info NOT available")
      DispatchQueue.main.async{self.eventCloudImg.image = nil}
      DispatchQueue.main.async{self.eventClouds.text = ""}
      DispatchQueue.main.async{self.eventWindStrengthImg.image = nil}
      DispatchQueue.main.async{self.eventWindSignImg.image = nil}
      DispatchQueue.main.async{self.eventTempImg.image = nil}
      DispatchQueue.main.async{self.eventTemperature.text = ""}
    }
    
    var starAltStr = "—"
    if item.StarAlt != nil
    {
      starAltStr = String(format: "%0.0f°",item.StarAlt!)
    }
    DispatchQueue.main.async{self.eventStarAlt.text = starAltStr}
    
    var sunAltStr = "—"
    if item.SunAlt != nil
    {
      sunAltStr = String(format: "%0.0f°", item.SunAlt!)
      if item.SunAlt! > -12.0
      {
        DispatchQueue.main.async {self.sunAltImg.image = #imageLiteral(resourceName: "sun.png")}
      }
      else
      {
        DispatchQueue.main.async {self.sunAltImg.image = nil}
      }
    }
    else
    {
      DispatchQueue.main.async {self.sunAltImg.image = nil}
    }
    DispatchQueue.main.async{self.eventSunAlt.text = sunAltStr}
    
    var moonAltStr = "—"
    var moonPhaseImage: UIImage
    if item.MoonAlt != nil
    {
      moonAltStr = String(format: "%0.0f°", item.MoonAlt!)
      if item.MoonPhase != nil
      {
        moonPhaseImage =  moonAltIcon(item.MoonPhase!)
        DispatchQueue.main.async {self.moonAltImg.image = moonPhaseImage}
      }
      else
      {
        moonPhaseImage = moonAltIcon(0)
        DispatchQueue.main.async {self.moonAltImg.image = moonPhaseImage}
      }
    }
    DispatchQueue.main.async{self.eventMoonAlt.text = moonAltStr}
    
    var moonDist = "—"
    if item.MoonDist != nil
    {
      moonDist = String(format: "%0.0f", item.MoonDist!)
    }
    DispatchQueue.main.async{self.eventMoonSeparation.text = moonDist}
    
    //need code to set icon
    var starColorImage: UIImage
    if item.StarColour != nil
    {
      starColorImage = starColorIcon(item.StarColour)
      DispatchQueue.main.async{self.starAltImg.image = starColorImage}
    }
    else
    {
      DispatchQueue.main.async{self.starAltImg.image = nil}
    }
    
  }
  

  // MARK: - Field Update Functiosn
 
  
  
  
  
  fileprivate func updateEventTimeFlds(_ item: inout EventDetails) {
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
    DispatchQueue.main.async{self.eventTime.text = eventUtcStr}
    //    DispatchQueue.main.async{self.eventTimeRemaining.text = leadTimeStr + " on " + completionDateStr}
    DispatchQueue.main.async{self.eventTimeRemaining.attributedText = leadTimeAttrStr }
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
    self.eventTitle.text = "—"
    self.eventRank.text = "Rank: —"
    self.eventTimeRemaining.text = "_"
    self.eventFeed.text = "—"
    self.sigmaImg.image = nil
    self.eventStationID.text = "—"
    self.eventCloudImg.image = nil
    self.eventClouds.text = "—"
    self.eventWindStrengthImg.image = nil
    self.eventWindSignImg.image = nil
    self.eventTempImg.image = nil
    self.eventTemperature.text = "—"
    self.eventChordDistance.text = "Chord: — km"
    self.eventTime.text = "—"
    self.eventTimeError.text = "—"
    self.eventStarAlt.text = "—"
    self.eventSunAlt.text = "—"
    self.eventMoonAlt.text = "—"
    self.eventMoonSeparation.text = "—"
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
    print("eventStationID=\(eventStationID!.text!)")
    print("eventClouds=\(eventClouds!.text!)")
    print("eventTemperature=\(eventTemperature!.text!)")
    print("eventChordDistance=\(eventChordDistance!.text!)")
    print("eventTime=\(eventTime!.text!)")
    print("eventTimeError=\(eventTimeError!.text!)")
    print("eventStarAlt=\(eventStarAlt!.text!)")
    print("eventSunAlt=\(eventSunAlt.text)")
    print("eventMoonAlt=\(eventMoonAlt.text)")
    print("eventMoonSeparation=\(eventMoonSeparation.text)")
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
