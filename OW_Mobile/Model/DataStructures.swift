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
  static let settings = "settings"
}

struct NotificationKeys
{
  static let dataRefreshIsDone = "dataRefreshIsDone"
}

var eventUpdateTimer: Timer?
var eventUpdateIntervalSeconds: TimeInterval = 3 * 60  //in seconds
var timeSinceUpdateTimer: Timer?
var eventRefreshFailed: Bool = true

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
  var RAJ2000Hours: Double?
  var DEJ2000Deg: Double?
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
  var StarColour: Int?
  var Report: Int?
  var ReportedDuration: Double?
  var ReportComment: String?
  var CountryCode: String?
  var StateCode: String?
  var Longitude: Double?
  var Latitude: Double?
}

var eventsWithDetails = [EventWithDetails]()  //event array of unified data
var currentEvent = OccultationEvent()   //event

public struct ObservationReport: Codable   //OWObservationReport ???
{
  public var Outcome: Int?
  public var Duration: Double?
  public var Comment: String?
}

struct Settings: Codable
{
  var autoUpdateIsOn = true
  var autoUpdateValue = 3
  var tempIsCelsius = true
  var azimuthIsDegrees = true
  var summaryTimeIsLocal = true
  var detailTimeIsLocal = true
  var starEpochIsJ2000 = true
  var latlonFormatIsDMS = true
  var eventDayFormat = 0
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

var eventDetailStrings = EventDetailStrings()
