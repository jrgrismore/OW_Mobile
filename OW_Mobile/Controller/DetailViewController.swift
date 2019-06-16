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
  @IBOutlet weak var sigma2BarView: UIView!
  @IBOutlet weak var sigma1BarView: UIView!
  @IBOutlet weak var centerBarView: UIView!
  
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
        print("start spinner")
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
    var objectStr = "—"
    if item.StarName != nil
    {
      objectStr = "occults " + item.StarName!
    }
    DispatchQueue.main.async{self.eventTitle.text = objectStr}
    
    var rankStr = "Rank: —"
    if item.Rank != nil
    {
      rankStr = String(format: "Rank: %d",item.Rank!)
    }
    DispatchQueue.main.async{self.eventRank.text = rankStr}

    var feedStr = "—"
    if item.Feed != nil
    {
      feedStr = item.Feed!
    }
    DispatchQueue.main.async{self.eventFeed.text = feedStr}

    var raStr = "RA   —"
    if item.RAHours != nil
    {
      //******convert decimal hours to hh:mm:ss
      let raTuple = floatRAtoHMS(floatRA: item.RAHours!)
//      raStr = String(format: "RA %0.2f",item.RAHours!)
      raStr = String(format: "RA  %02dh %02dm %04.1fs",raTuple.hours,raTuple.minutes,raTuple.seconds)
    }
    DispatchQueue.main.async{self.eventRA.text = raStr}

    var decStr = "DE   —"
    if item.DEDeg != nil
    {
      //******convert decimal degrees to dd:mm:ss
      let decTuple = floatDecToDMS(floatDegrees: item.DEDeg!)
//      decStr = String(format: "DE %0.2f",item.DEDeg!)
      decStr = String(format: "DE  %+03d° %02d' %04.1f\"",decTuple.degrees,labs(decTuple.minutes),fabs(decTuple.seconds))
    }
    DispatchQueue.main.async{self.eventDec.text = decStr}

    var bvStr = "B-V   —"
    if item.BV != nil
    {
      bvStr = String(format: "B-V %0.3f",item.BV!)
     }
    DispatchQueue.main.async{self.eventStarBV.text = bvStr}

    var stellarDiamStr = "Stellar Dia.          —"
     if item.SellarDia != nil
    {
      stellarDiamStr = String(format: "Stellar Dia. %0.1f mas",item.SellarDia!)
    }
    DispatchQueue.main.async{self.eventStarDiameter.text =  stellarDiamStr}

    var asteroidClassStr = "—"
    if item.AstClass != nil
    {
      asteroidClassStr = item.AstClass!
    }
    DispatchQueue.main.async{self.eventAsteroidOrigin.text = asteroidClassStr}

    var asteroidDiamStr = "Diameter        —"
    if item.AstDia != nil
    {
      asteroidDiamStr = String(format: "Diameter %0.0f",item.AstDia!)
    }
    DispatchQueue.main.async{self.eventAsteroidDiameter.text = asteroidDiamStr}

    var starMagStr = "Star Mag     —"
    if item.StarMag != nil
    {
      starMagStr = String(format: "Star Mag %0.2f",item.StarMag!)
    }
    DispatchQueue.main.async{self.eventStarMagnitude.text = starMagStr}

    var asterMagStr = "Aster. Mag     —"
    if item.AstMag != nil
    {
      asterMagStr = String(format: "Aster. Mag %0.2f",item.AstMag!)
    }
    DispatchQueue.main.async{self.eventAsteroidMagnitude.text = asterMagStr}

    var combMagStr = "Comb. Mag       —"
     if item.CombMag != nil
    {
      combMagStr = String(format: "Comb. Mag %0.2f",item.CombMag!)
    }
    DispatchQueue.main.async{self.eventCombinedMagnitude.text = combMagStr}

    var magDropStr = "Mag Drop       —"
    if item.MagDrop != nil
    {
      magDropStr = String(format: "Mag Drop %0.2f",item.MagDrop!)

    }
    DispatchQueue.main.async{self.eventMagnitudeDrop.text = magDropStr}
    
    var asterRotationStr = "Rotation       —"
     if item.AstRotationHrs != nil
    {
      asterRotationStr = String(format: "Rotation %0.3fh",item.AstRotationHrs!)
    }
    DispatchQueue.main.async{self.eventCamAseroidRotation.text = asterRotationStr}

    var asterAmpStr = "Amplitude       —"
    if item.AstRotationAmplitude != nil
    {
      asterAmpStr = String(format: "Amplitude %0.2fm",item.AstRotationAmplitude!)
    }
    DispatchQueue.main.async{self.eventCamRotationAmplitude.text = asterAmpStr}

    
    
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

    var stationID = "Station ID   —"
    if item.Stations![0].StationId != nil
    {
      stationID = String(format: "Station ID %d",item.Stations![0].StationId!)
    }
    DispatchQueue.main.async{self.eventStationID.text = stationID}

    //need code to format time properly
    var eventUtcStr = "—"
    var leadTimeStr = "—"
    var completionDateStr = "—"
    if item.Stations![0].EventTimeUtc != nil
    {
//      print("item.Stations![0].EventTimeUtc = ",item.Stations![0].EventTimeUtc!)
      eventUtcStr = formatEventTime(timeString: item.Stations![0].EventTimeUtc!)
//      print("evnetUtcStr =",eventUtcStr)
      leadTimeStr = leadTime(timeString: item.Stations![0].EventTimeUtc!)
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
    DispatchQueue.main.async{self.eventTimeRemaining.text = leadTimeStr + " on " + completionDateStr}

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
    }
    DispatchQueue.main.async{self.eventSunAlt.text = sunAltStr}

    var moonAltStr = "—"
    if item.MoonAlt != nil
    {
      moonAltStr = String(format: "%0.0f°", item.MoonAlt!)
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
    print("sigma2BarView=\(sigma2BarView!)")
    print("sigma1BarView=\(sigma1BarView!)")
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
