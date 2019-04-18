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

  @IBOutlet weak var eventTitle: UILabel!
  @IBOutlet weak var evenkRank: UILabel!
  @IBOutlet weak var eventTimeRemaining: UILabel!
  @IBOutlet weak var eventFeed: UILabel!
  
  @IBOutlet weak var weatherBarView: UIView!
  @IBOutlet weak var sigma2BarView: UIView!
  @IBOutlet weak var sigma1BarView: UIView!
  @IBOutlet weak var centerBarView: UIView!
  
  @IBOutlet weak var eventLocation: UILabel!
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
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
//    detailLbl.text = selection
//    print("detail data =")
    let detailStr = eventInfoToString(eventItem: detailData)
//    detailLbl.text = detailStr
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    self.title = detailData.Object
   }
  func eventInfoToString(eventItem item: Event) -> String
  {
    let idStr = String(format: "Id = %@",item.Id)
    let objectStr = String(format: "Object = %@",item.Object)
    let starmagStr = String(format: "StarMag = %0.2f",item.StarMag)
    let magdropStr = String(format: "MagDrop = %0.2f",item.MagDrop)
    let maxdurStr = String(format: "MaxDurSec = %0.2f",item.MaxDurSec)
    let eventutcStr = String(format: "EventTimeUtc = %@",item.EventTimeUtc)
    let errortimeStr = String(format: "ErrorInTimeSec = %0.2f",item.ErrorInTimeSec  )
    let weatherStr = String(format: "WeatherInfoAvailable = %@",item.WeatherInfoAvailable.description)
    let cloudcoverStr = String(format: "CloudCover = %d",item.CloudCover)
    let windStr = String(format: "Wind = %d",item.Wind)
    let tempStr = String(format: "TempDegC = %d",item.TempDegC)
    let highcloudStr = String(format: "HighCloud = %@",item.HighCloud.description)
    let stationposStr = String(format: "BestStationPos = %d",item.BestStationPos)
    let starcolourStr = String(format: "StarColour = %d",item.StarColour)

    let eventStr =  idStr + "\n" +
    objectStr + "\n" +
    starmagStr + "\n" +
    magdropStr + "\n" +
    maxdurStr + "\n" +
    eventutcStr + "\n" +
    errortimeStr + "\n" +
    weatherStr + "\n" +
    cloudcoverStr + "\n" +
    windStr + "\n" +
    tempStr + "\n" +
    highcloudStr + "\n" +
    stationposStr + "\n" +
    starcolourStr + "\n"
    
    printEventDetails()
    
   return eventStr
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
    print("eventTitle=\(eventTitle.text)")
    print("evenkRank=\(evenkRank.text)")
    print("eventTimeRemaining=\(eventTimeRemaining.text)")
    print("eventFeed=\(eventFeed.text)")
    print("weatherBarView=\(weatherBarView)")
    print("sigma2BarView=\(sigma2BarView)")
    print("sigma1BarView=\(sigma1BarView)")
    print("centerBarView=\(centerBarView)")
    print("eventLocation=\(eventLocation.text)")
    print("eventClouds=\(eventClouds.text)")
    print("eventTemperature=\(eventTemperature.text)")
    print("eventChordDistance=\(eventChordDistance.text)")
    print("eventTime=\(eventTime.text)")
    print("eventTimeError=\(eventTimeError.text)")
    print("eventStarAlt=\(eventStarAlt.text)")
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
