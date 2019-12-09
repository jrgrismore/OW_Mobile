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
  @IBOutlet weak var eventMoonSepImg: UIImageView!
  
  //@IBOutlet weak var reportImg: UIImageView!
  @IBOutlet weak var reportImg: UIImageView!
  
  
  //these outlets only needed for layout debugging
  @IBOutlet weak var stationStack: UIStackView!
  @IBOutlet weak var topStack: UIStackView!
  @IBOutlet weak var locationStack: UIStackView!
  @IBOutlet weak var cloudStack: UIStackView!
  @IBOutlet weak var windStack: UIStackView!
  @IBOutlet weak var tempStack: UIStackView!
  @IBOutlet weak var middleStack: UIStackView!
  @IBOutlet weak var bottomStack: UIStackView!
  @IBOutlet weak var starAltStack: UIStackView!
  @IBOutlet weak var sunAltStack: UIStackView!
  @IBOutlet weak var moonAltStack: UIStackView!
  @IBOutlet weak var moonSepStack: UIStackView!
  
  @IBOutlet weak var reportBtn: UIButton!
  
  
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
