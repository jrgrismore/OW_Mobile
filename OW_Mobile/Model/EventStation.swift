//
//  Station.swift
//  OW_Mobile
//
//  Created by John Grismore on 6/23/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import Foundation

class EventStation: NSObject
{
  var station: Station
  init(station: Station)
  {
    self.station = station
  }
  
  func prettyPrint()
  {
    print()
    print("StationId:",station.StationId)
    print("StationName:", station.StationName)
    print("EventTimeUtc:",station.EventTimeUtc)
    print("WeatherInfoAvailable:",station.WeatherInfoAvailable)
    print("CloudCover:",station.CloudCover)
    print("Wind:", station.Wind)
    print("TempDegC:",station.TempDegC)
    print("HighCloud:",station.HighCloud)
    print("StationPos:",station.StationPos)
    print("ChordOffsetKm:",station.ChordOffsetKm)
    print("OccultDistanceKm:",station.OccultDistanceKm)
    print("IsOwnStation:",station.IsOwnStation)
    print("IsPrimaryStation:",station.IsPrimaryStation)
  }
}
