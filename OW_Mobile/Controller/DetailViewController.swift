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
  
  @IBOutlet weak var spinnerView: UIView!
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var spinnerLbl: UILabel!
  
//  var detailData = [Event?]()
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

  @IBOutlet weak var eventTitle: UILabel!
  @IBOutlet weak var eventRank: UILabel!
  @IBOutlet weak var eventTimeRemaining: UILabel!
  @IBOutlet weak var eventFeed: UILabel!
  
  @IBOutlet weak var weatherBarView: UIView!
  @IBOutlet weak var sigma3BarView: UIView!
  @IBOutlet weak var sigma2BarView: UIView!
  @IBOutlet weak var sigma1BarView: UIView!
  @IBOutlet weak var shadowBarView: UIView!
  @IBOutlet weak var centerBarView: UIView!
  @IBOutlet weak var userBarView: UIView!
  
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
  
  @IBOutlet weak var eventCloudImg: UIImageView!
  @IBOutlet weak var eventWindStrengthImg: UIImageView!
  @IBOutlet weak var eventWindSignImg: UIImageView!
  @IBOutlet weak var eventTempImg: UIImageView!
  @IBOutlet weak var sigmaImg: UIImageView!
  @IBOutlet weak var starAltImg: UIImageView!
  @IBOutlet weak var moonAltImg: UIImageView!
  @IBOutlet weak var sunAltImg: UIImageView!
  
  @IBOutlet weak var shadowBarWidth: NSLayoutConstraint!
  @IBOutlet weak var asterRotAmpView: UIStackView!
  @IBOutlet weak var bvStarDiamView: UIStackView!
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.spinnerView.layer.cornerRadius = 20
    
//    detailLbl.text = selection
//    print("detail data =")
//    let detailStr = eventInfoToString(eventItem: detailData)
//    detailLbl.text = detailStr
    
  }
  
   override func viewWillAppear(_ animated: Bool)
  {
//    clearFieldsAndIcons()
    
    let detailEndpoint = OWWebAPI.shared.createEventDetailURL(owSession: OWWebAPI.owSession, eventID: detailData.Id!)
    print("detailEndpoint=",detailEndpoint)
    self.title = detailData.Object
    
    DispatchQueue.main.async
      {
        self.spinnerView.isHidden = false
        self.activitySpinner.startAnimating()
    }
    
    //    let OWWebAPI.shared = OWWebAPI()
    DispatchQueue.main.async{self.spinnerLbl.text = "Fetching Detail Data..."}
    usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds
    
    OWWebAPI.shared.retrieveEventDetails(eventID: detailData.Id!) { (myDetails, error) in
      DispatchQueue.main.async{self.spinnerLbl.text = "download complete"}
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds

      self.selectedEventDetails = myDetails!
      DispatchQueue.main.async{self.spinnerLbl.text = "updating details"}
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds
       self.setEventInfoFields(eventItem: self.selectedEventDetails)
      DispatchQueue.main.async
        {
          self.activitySpinner.stopAnimating()
          self.spinnerView.isHidden = true
      }
//      OWWebAPI.owSession.invalidateAndCancel()
    }   //??????????
    
  }

  override func viewDidAppear(_ animated: Bool)
  {
//    print("viewDidAppear")
    clearFieldsAndIcons()
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
  
  func setEventInfoFields(eventItem itm: EventDetails)
  {
    var item = itm  //for testing
//    var objectStr = "—"
    var objectAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.StarName != nil
    {
      objectAttrStr = self.formatLabelandField(label:"", field: item.StarName!, units:"")
//      objectStr = "occults " + item.StarName!
    }
    DispatchQueue.main.async{self.eventTitle.attributedText = objectAttrStr}
    
//    var rankStr = "Rank: —"
    var rankAttrStr: NSAttributedString = NSMutableAttributedString(string: "Rank: —")
    if item.Rank != nil
    {
      rankAttrStr = self.formatLabelandField(label:"Rank: ", field: String(format: "%d",item.Rank!), units:"")
      
//      rankStr = String(format: "Rank: %d",item.Rank!)
    }
    DispatchQueue.main.async{self.eventRank.attributedText = rankAttrStr}

//    var feedStr = "—"
    var feedAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.Feed != nil
    {
      feedAttrStr = self.formatLabelandField(label:"", field: item.Feed!, units:"")
//      feedStr = item.Feed!
    }
    DispatchQueue.main.async{self.eventFeed.attributedText = feedAttrStr}

//    var raStr = "RA   —"
    var raAttrStr: NSAttributedString = NSMutableAttributedString(string: "RA   —")
    if item.RAHours != nil
    {
      //******convert decimal hours to hh:mm:ss
      let raTuple = floatRAtoHMS(floatRA: item.RAHours!)
//      raStr = String(format: "RA %0.2f",item.RAHours!)
      let raFldStr = String(format: "%02dh %02dm %04.1fs",raTuple.hours,raTuple.minutes,raTuple.seconds)
      raAttrStr = self.formatLabelandField(label:"RA ", field: raFldStr, units:"")
//      raStr = String(format: "RA  %02dh %02dm %04.1fs",raTuple.hours,raTuple.minutes,raTuple.seconds)
    }
    DispatchQueue.main.async{self.eventRA.attributedText = raAttrStr}

//    var decStr = "DE   —"
    var decAttrStr: NSAttributedString = NSMutableAttributedString(string: "DE   —")
    if item.DEDeg != nil
    {
      //******convert decimal degrees to dd:mm:ss
      let decTuple = floatDecToDMS(floatDegrees: item.DEDeg!)
//      decStr = String(format: "DE %0.2f",item.DEDeg!)
      let decFldStr = String(format: "%+03d° %02d' %04.1f\"",decTuple.degrees,labs(decTuple.minutes),fabs(decTuple.seconds))
      decAttrStr = self.formatLabelandField(label:"DE ", field: decFldStr, units:"")
//     decStr = String(format: "DE  %+03d° %02d' %04.1f\"",decTuple.degrees,labs(decTuple.minutes),fabs(decTuple.seconds))
    }
    DispatchQueue.main.async{self.eventDec.attributedText = decAttrStr}

    if item.BV == nil && item.StellarDia == nil
    {
      //hide view
      DispatchQueue.main.async {self.bvStarDiamView.isHidden = true}
    } else {
      DispatchQueue.main.async {self.bvStarDiamView.isHidden = false}
//      var bvStr = "B-V   —"
      var bvAttrStr: NSAttributedString = NSMutableAttributedString(string: "B-V   —")
      if item.BV != nil
      {
//        bvStr = String(format: "B-V %0.3f",item.BV!)
        bvAttrStr = self.formatLabelandField(label:"B-V ", field: String(format: "%0.3f",item.BV!), units:"")
      }
      DispatchQueue.main.async{self.eventStarBV.attributedText = bvAttrStr}
      
//      var stellarDiamStr = "Stellar Dia.          —"
      var starDiamAttrStr: NSAttributedString = NSMutableAttributedString(string: "Stellar Dia.          —")
      if item.StellarDia != nil
      {

//        stellarDiamStr = String(format: "Stellar Dia. %0.1f mas",item.StellarDia!)
        starDiamAttrStr = self.formatLabelandField(label:"Stellar Dia. ", field: String(format: "%0.1f",item.StellarDia!), units:" mas")
      }
      DispatchQueue.main.async{self.eventStarDiameter.attributedText =  starDiamAttrStr}
    }
    
//    var asteroidClassStr = "—"
    var asteroidClassAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.AstClass != nil
    {
//      asteroidClassStr = item.AstClass!
      asteroidClassAttrStr = self.formatLabelandField(label:"", field: item.AstClass!, units:"")
    }
    DispatchQueue.main.async{self.eventAsteroidOrigin.attributedText = asteroidClassAttrStr}

//    var asteroidDiamStr = "Diameter        —"
    var asteroidDiamAttrStr: NSAttributedString = NSMutableAttributedString(string: "Diam        —")
    if item.AstDiaKm != nil
    {
//      asteroidDiamStr = String(format: "Diameter %0.1f km",item.AstDiaKm!)
      asteroidDiamAttrStr = self.formatLabelandField(label:"Diam ", field: String(format: "%0.1f",item.AstDiaKm!), units:" km")
      //set shadow bar width
//      print("asteroidDiameterStr=",asteroidDiamStr)
      let shadowWidth = item.AstDiaKm!
//      print("shadwWidth=",shadowWidth)
      //create test sigma1 width until Hristo provides this
      let sigwid = Double.random(in: (shadowWidth - shadowWidth*0.5)...(shadowWidth + shadowWidth*0.5) )
      let sig1Width = item.OneSigmaErrorWidthKm!
      //      let sigwid = shadowWidth / 2
//      print("sigwid=",sigwid)
      
      let stationsExistBeyondSigma1:Bool = true
      
      var plotBarsTuple = shadowSigmaBarScales(astDiam: item.AstDiaKm!, sigma1Width: sig1Width , stationsExistPastSigma1: stationsExistBeyondSigma1)
//      print("total width = \(plotBarsTuple.totalWidthKm) Km")
      
      let totalBarsWidthKm = pathBarsTotalWidth(astDiamKm: item.AstDiaKm!, sigma1WidthKm: sig1Width, stationsExistPastSigma1: stationsExistBeyondSigma1)
//      print("pathBarsTotslWidth = \(totalBarsWidthKm) Km")
      
      //set bar views to full width before applying scale factor
      DispatchQueue.main.sync
      {
        self.shadowBarView.bounds.size.width = self.weatherBarView.bounds.width
        self.sigma1BarView.bounds.size.width = self.weatherBarView.bounds.width
        self.sigma2BarView.bounds.size.width = self.weatherBarView.bounds.width
        
      }
      let shadowFactor = shadowWidth / totalBarsWidthKm
      let sigma1Factor = (shadowWidth + (2 * sig1Width)) / totalBarsWidthKm
      let sigma2Factor = (shadowWidth + (4 * sig1Width)) / totalBarsWidthKm
      let sigma3Factor = (shadowWidth + (6 * sig1Width)) / totalBarsWidthKm
//      print("shadow factor=",plotBarsTuple.shadowBarWidthFactor)
//      print("shadowFactor=",shadowFactor)
//      print("sigma1 factor=",plotBarsTuple.sigma1BarWidthFactor)
//      print("sigma1Factor=",sigma1Factor)
//      print("sigma2 factor=",plotBarsTuple.sigma2BarWidthFactor)
//      print("sigma2Factor=",sigma2Factor)

      DispatchQueue.main.sync
      {
//        self.shadowBarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarsTuple.shadowBarWidthFactor), y: 1.0)
//        self.sigma1BarView.transform = CGAffineTransform(scaleX: CGFloat(plotBarsTuple.sigma1BarWidthFactor), y: 1.0)
        self.shadowBarView.transform = CGAffineTransform(scaleX: CGFloat(shadowFactor), y: 1.0)
        self.sigma1BarView.transform = CGAffineTransform(scaleX: CGFloat(sigma1Factor), y: 1.0)
        self.userBarView.frame.origin.x = self.centerBarView.frame.origin.x + (self.weatherBarView.bounds.width / 2) * CGFloat((item.Stations![0].ChordOffsetKm! / totalBarsWidthKm))
      }
      
      if stationsExistBeyondSigma1
      {
        DispatchQueue.main.sync
          {
            self.sigma2BarView.transform = CGAffineTransform(scaleX: CGFloat(sigma2Factor), y: 1.0)
            self.sigma2BarView.isHidden = false
            self.sigma3BarView.isHidden = false
        }
      }
      else
      {
        DispatchQueue.main.sync
          {
            self.sigma2BarView.isHidden = true
            self.sigma3BarView.isHidden = true
        }
      }
      DispatchQueue.main.async {self.eventAsteroidDiameter.attributedText = asteroidDiamAttrStr}
    }

//    var starMagStr = "Star Mag     —"
    var starMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Star Mag     —")
    if item.StarMag != nil
    {
//      starMagStr = String(format: "Star Mag %0.2f",item.StarMag!)
      starMagAttrStr = self.formatLabelandField(label:"Star Mag ", field: String(format: "%0.2f",item.StarMag!), units:"")
    }
    DispatchQueue.main.async{self.eventStarMagnitude.attributedText = starMagAttrStr}

//    var asterMagStr = "Aster. Mag     —"
    var asterMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Aster. Mag     —")
    if item.AstMag != nil
    {
//      asterMagStr = String(format: "Aster. Mag %0.2f",item.AstMag!)
      asterMagAttrStr = self.formatLabelandField(label:"Aster. Mag ", field: String(format: "%0.2f",item.AstMag!), units:"")
    }
    DispatchQueue.main.async{self.eventAsteroidMagnitude.attributedText = asterMagAttrStr}

//    var combMagStr = "Comb. Mag       —"
    var combMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Comb. Mag       —")
     if item.CombMag != nil
    {
//      combMagStr = String(format: "Comb. Mag %0.2f",item.CombMag!)
      combMagAttrStr = self.formatLabelandField(label:"Comb. Mag  ", field: String(format: "%0.2f",item.CombMag!), units:"")
    }
    DispatchQueue.main.async{self.eventCombinedMagnitude.attributedText = combMagAttrStr}

//    var magDropStr = "Mag Drop       —"
    var magDropAttrStr: NSAttributedString = NSMutableAttributedString(string: "Mag Drop       —")
    if item.MagDrop != nil
    {
//      magDropStr = String(format: "Mag Drop %0.2f",item.MagDrop!)
      magDropAttrStr = self.formatLabelandField(label:"Mag Drop ", field: String(format: "%0.2f",item.MagDrop!), units:"")
    }
    DispatchQueue.main.async{self.eventMagnitudeDrop.attributedText = magDropAttrStr}
    
    if item.AstRotationHrs == nil && item.AstRotationAmplitude == nil
    {
      DispatchQueue.main.async{self.asterRotAmpView.isHidden = true}
    }
    else
    {
      DispatchQueue.main.async{self.asterRotAmpView.isHidden = false}
//      var asterRotationStr = "Rotation       —"
      var asterRotationAttrStr: NSAttributedString = NSMutableAttributedString(string: "Rotation       —")
      if item.AstRotationHrs != nil
      {
//        asterRotationStr = String(format: "Rotation %0.3fh",item.AstRotationHrs!)
        asterRotationAttrStr = self.formatLabelandField(label:"Rotation ", field: String(format: "%0.3fh",item.AstRotationHrs!), units:"")
      }
      DispatchQueue.main.async{self.eventCamAseroidRotation.attributedText = asterRotationAttrStr}
      
//      var asterAmpStr = "Amplitude       —"
      var asterAmpAttrStr: NSAttributedString = NSMutableAttributedString(string: "Amplitude       —")
      if item.AstRotationAmplitude != nil
      {
//        asterAmpStr = String(format: "Amplitude %0.2fm",item.AstRotationAmplitude!)
        asterAmpAttrStr = self.formatLabelandField(label:"Amplitude ", field: String(format: "%0.2fm",item.AstRotationAmplitude!), units:"")
      }
      DispatchQueue.main.async{self.eventCamRotationAmplitude.attributedText = asterAmpAttrStr}
    }
    
    
    //camera combined magnitude ???
    DispatchQueue.main.async{self.eventCamCombinedMag.text = "??? Comb. Mag ???"}

    //camera mag drop ???
    DispatchQueue.main.async{self.eventCamMagDrop.text = "??? Mag Drop ???"}

    
 
//    var maxdurStr = ""
//    if item.MaxDurSec != nil
//    {
//      maxdurStr = String(format: "%0.2f",item.MaxDurSec!)
//      DispatchQueue.main.async{self.event.text = String(format: "%0.2f",item.MaxDurSec!)}
//    }
    
    
    //need code to set color
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

//    print("selectedEventDetails = ",self.selectedEventDetails)
//    DispatchQueue.main.async {self.printEventDetails()}
  }

  
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
