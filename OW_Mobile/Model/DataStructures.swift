//
//  DataStructures.swift
//  OW_Mobile
//
//  Created by John Grismore on 5/16/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import Foundation


//UserDefaults Keys Enum
struct UDKeys
{
  static let myEventList = "myEventList"
}

//Event structure matching JSON keys
struct Event: Codable
{
  var Id: String?
  var Object: String?
  var StarMag: Double?
  var MagDrop: Double?
  var MaxDurSec: Double?
  var EventTimeUtc: String?
  var ErrorInTimeSec: Double?
  var WeatherInfoAvailable: Bool?   //weather info available
  var CloudCover: Int?
  var Wind: Int?
  var TempDegC: Int?
  var HighCloud: Bool?
  var BestStationPos: Int?
  var StarColour: Int?
}

struct MyEvents: Codable
{
  var events: [Event]
}

//Event strings structure
struct EventStrings: Codable
{
  var Id: String = ""
  var Object: String = ""
  var StarMag: String = ""
  var MagDrop: String = ""
  var MaxDurSec: String = ""
  var EventTimeUtc: String = ""
  var ErrorInTimeSec: String = ""
  var WeatherInfoAvailable: String = ""   //weather info available
  var CloudCover: String = ""
  var Wind: String = ""
  var TempDegC: String = ""
  var HighCloud: String = ""
  var BestStationPos: String = ""
  var StarColour: String = ""
 }
var myEventsStrings = EventStrings()    //???????/

struct EventDetails: Codable
{
  var Id: String?
  var Object: String?
  var StarMag: Double?
  var MagDrop: Double?
  var MaxDurSec: Double?
  var ErrorInTimeSec: Double?
  var StarColour: Int?
  var Stations: [Station]?
  var Feed: String?
  var Rank: Int?
  var BV: Double?
  var CombMag: Double?
  var AstMag: Double?
  var MoonDist: Double?
  var MoonPhase: Int?
  var AstDia: Double?
  var AstDistUA: Double?
  var RAHours: Double?
  var DEDeg: Double?
  var StarAlt: Double?
  var StarAz: Double?
  var SunAlt: Double?
  var MoonAlt: Double?
  var MoonAz: Double?
  var SellarDia: Double?
  var StarName: String?
  var OtherStarNames: String?
  var AstClass: String?
  var AstRotationHrs: Double?
  var AstRotationAmplitude: Double?
  var PredictionUpdated: String?
}

struct Station: Codable
{
  var StationId: Int?
  var EventTimeUtc: String?
  var WeatherInfoAvailable: Bool?
  var CloudCover: Int?
  var Wind: Int?
  var TempDegC: Int?
  var HighCloud: Bool?
  var StationPos: Int?
  var ChordOffsetKm: Double?
}
