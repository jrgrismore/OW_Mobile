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

  @IBOutlet weak var detailLbl: UILabel!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
//    detailLbl.text = selection
    print("detail data =")
    let detailStr = eventInfoToString(eventItem: detailData)
    detailLbl.text = detailStr
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

}
