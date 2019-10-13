//
//  StationCell.swift
//  OW_Mobile
//
//  Created by John Grismore on 6/27/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class StationCell: UICollectionViewCell
{
  @IBOutlet weak var eventStationID: UILabel!
  @IBOutlet weak var sigmaImg: UIImageView!
  
  @IBOutlet weak var eventClouds: UILabel!
  @IBOutlet weak var eventCloudImg: UIImageView!
  
  @IBOutlet weak var eventWindStrengthImg: UIImageView!
  @IBOutlet weak var eventWindSignImg: UIImageView!
  
  @IBOutlet weak var eventTemperature: UILabel!
  @IBOutlet weak var eventTempImg: UIImageView!
  
  @IBOutlet weak var eventChordDistance: UILabel!
  @IBOutlet weak var eventTime: UILabel!
  @IBOutlet weak var eventTimeError: UILabel!
  
  @IBOutlet weak var eventStarAlt: UILabel!
  @IBOutlet weak var starAltImg: UIImageView!
  
  @IBOutlet weak var eventSunAlt: UILabel!
  @IBOutlet weak var sunAltImg: UIImageView!
  
  @IBOutlet weak var eventMoonAlt: UILabel!
  @IBOutlet weak var moonAltImg: UIImageView!
  
  @IBOutlet weak var eventMoonSeparation: UILabel!
  
  @IBOutlet weak var reportImg: UIImageView!
  
  func clearStationFields()
  {
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
  }
  
}
