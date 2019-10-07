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
  static let myEventDetails = "myEventDetails"
  static let lastEventListUpdate = "lastEventListUpdate"
  static let eventsWithDetails = "eventsWithDetails"
}

//Unified event with details structure matching JSON keys
struct EventWithDetails: Codable
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
  var Stations: [ObserverStation]?   //station array
  var Feed: String?
  var Rank: Int?
  var BV: Double?
  var CombMag: Double?
  var AstMag: Double?
  var MoonDist: Double?
  var MoonPhase: Int?
  var AstDiaKm: Double?
  var AstDistUA: Double?
  var RAHours: Double?
  var DEDeg: Double?
  var StarAlt: Double?
  var StarAz: Double?
  var SunAlt: Double?
  var MoonAlt: Double?
  var MoonAz: Double?
  var StellarDiaMas: Double?
  var StarName: String?
  var OtherStarNames: String?
  var AstClass: String?
  var AstRotationHrs: Double?
  var AstRotationAmplitude: Double?
  var PredictionUpdated: String?
  var OneSigmaErrorWidthKm: Double?
}

//stations data structure to be embedded in unified event detail structure
struct ObserverStation: Codable
{
  var StationId: Int?
  var StationName: String?
  var EventTimeUtc: String?
  var WeatherInfoAvailable: Bool?
  var CloudCover: Int?
  var Wind: Int?
  var TempDegC: Int?
  var HighCloud: Bool?
  var StationPos: Int?
  var ChordOffsetKm: Double?
  var OccultDistanceKm: Double?
  var IsOwnStation: Bool?
  var IsPrimaryStation: Bool?
  var ErrorInTimeSec: Double?
  var StarAlt: Double?
  var StarAz: Double?
  var SunAlt: Double?
  var MoonAlt: Double?
  var MoonAz: Double?
  var MoonDist: Double?
  var MoonPhase: Double?
  var CombMag: Double?
  var StarColour: Double?
}
var eventsWithDetails = [EventWithDetails]()  //event array of unified data
var currentEvent = OccultationEvent()   //event



//*** now superceded
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
//  var Details: EventDetails
}

//*** now superceded
struct MyEvents: Codable
{
  var events: [Event]
}

//*** now superceded
struct MyEventListDetails: Codable
{
  var eventList: [Event]
  var eventsDetails: [EventDetails]
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

//*** now superceded
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
  var AstDiaKm: Double?
  var AstDistUA: Double?
  var RAHours: Double?
  var DEDeg: Double?
  var StarAlt: Double?
  var StarAz: Double?
  var SunAlt: Double?
  var MoonAlt: Double?
  var MoonAz: Double?
  var StellarDia: Double?
  var StarName: String?
  var OtherStarNames: String?
  var AstClass: String?
  var AstRotationHrs: Double?
  var AstRotationAmplitude: Double?
  var PredictionUpdated: String?
  var OneSigmaErrorWidthKm: Double?   //new
}

//*** now superceded
struct Station: Codable
{
  var StationId: Int?
  var StationName: String?   //new
  var EventTimeUtc: String?
  var WeatherInfoAvailable: Bool?
  var CloudCover: Int?
  var Wind: Int?
  var TempDegC: Int?
  var HighCloud: Bool?
  var StationPos: Int?
  var ChordOffsetKm: Double?
  var OccultDistanceKm: Double?   //new
  var IsOwnStation: Bool?   //new
  var IsPrimaryStation: Bool?   //new
}

//*** now superceded
//EventDetail strings structure
struct EventDetailStrings: Codable
{
  var Id: String = ""
  var Object: String = ""
  var StarMag: String = ""
  var MagDrop: String = ""
  var MaxDurSec: String = ""
  var EventTimeUtc: String = ""
  var ErrorInTimeSec: String = ""
  var WeatherInfoAvailable: String = ""
  var CloudCover: String = ""
  var Wind: String = ""
  var TempDegC: String = ""
  var HighCloud: String = ""
  var BestStationPos: String = ""
  var StarColour: String = ""
 }

//*** now superceded
var eventDetailStrings = EventDetailStrings()
