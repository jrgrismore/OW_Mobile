//
//  Event.swift
//  OW_Mobile
//
//  Created by John Grismore on 6/23/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import Foundation
import UIKit


class OccultationEvent: NSObject
{
  
  var details = EventDetails()
  var stations = [Station]()
  
  var eventData = EventWithDetails()
  
  
  // MARK: - event detail update functions
  func updateObjectFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var objectAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.StarName != nil
    {
      objectAttrStr = formatLabelandField(label:"", field: item.StarName!, units:"")
    }
    return objectAttrStr
  }
  
  func updateRankFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var rankAttrStr: NSAttributedString = NSMutableAttributedString(string: "Rank: —")
    if item.Rank != nil
    {
      rankAttrStr = formatLabelandField(label:"Rank: ", field: String(format: "%d",item.Rank!), units:"")
    }
    return rankAttrStr
  }
  
  func updateFeedFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var feedAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.Feed != nil
    {
      feedAttrStr = self.formatLabelandField(label:"", field: item.Feed!, units:"")
    }
    return feedAttrStr
    
  }
  
  func updateRAFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var raAttrStr: NSAttributedString = NSMutableAttributedString(string: "RA   —")
    if item.RAHours != nil
    {
      //******convert decimal hours to hh:mm:ss
      let raTuple = floatRAtoHMS(floatRA: item.RAHours!)
      let raFldStr = String(format: "%02dh %02dm %04.1fs",raTuple.hours,raTuple.minutes,raTuple.seconds)
      raAttrStr = self.formatLabelandField(label:"RA: ", field: raFldStr, units:"")
    }
    return raAttrStr
  }
  
  func updateDecFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var decAttrStr: NSAttributedString = NSMutableAttributedString(string: "DE   —")
    if item.DEDeg != nil
    {
      //******convert decimal degrees to dd:mm:ss
      let decTuple = floatDecToDMS(floatDegrees: item.DEDeg!)
      let decFldStr = String(format: "%+03d° %02d' %04.1f\"",decTuple.degrees,labs(decTuple.minutes),fabs(decTuple.seconds))
      decAttrStr = self.formatLabelandField(label:"DE: ", field: decFldStr, units:"")
    }
    return decAttrStr
  }
  
  func updateBVFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var bvAttrStr: NSAttributedString = NSMutableAttributedString(string: "B-V   —")
    if item.BV != nil
    {
      bvAttrStr = self.formatLabelandField(label:"B-V: ", field: String(format: "%0.3f",item.BV!), units:"")
    }
    DispatchQueue.main.async{}
    return bvAttrStr
  }
  
  func updateStarDiamFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var starDiamAttrStr: NSAttributedString = NSMutableAttributedString(string: "Stellar Dia.          —")
    if item.StellarDiaMas != nil
    {
      starDiamAttrStr = self.formatLabelandField(label:"Stellar Dia: ", field: String(format: "%0.1f",item.StellarDiaMas!), units:" mas")
    }
    DispatchQueue.main.async{}
    return starDiamAttrStr
  }
  
  func updateAsteroidClassFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var asteroidClassAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.AstClass != nil
    {
      asteroidClassAttrStr = self.formatLabelandField(label:"", field: item.AstClass!, units:"")
    }
    return asteroidClassAttrStr
  }
  
  func updateAsteroidDiamKM(_ item: EventWithDetails) -> NSAttributedString
  {
    var asteroidDiamAttrStr: NSAttributedString = NSMutableAttributedString(string: "Diam        —")
    if item.AstDiaKm != nil
    {
      asteroidDiamAttrStr = self.formatLabelandField(label:"Diam: ", field: String(format: "%0.1f",item.AstDiaKm!), units:" km")
    }
    return asteroidDiamAttrStr
  }
  
  func updateStarMagFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var starMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Star Mag     —")
    if item.StarMag != nil
    {
      starMagAttrStr = self.formatLabelandField(label:"Star Mag: ", field: String(format: "%0.2f",item.StarMag!), units:"")
    }
    return starMagAttrStr
  }
  
  func updateAsteroidMagFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var asterMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Aster. Mag     —")
    if item.AstMag != nil
    {
      asterMagAttrStr = self.formatLabelandField(label:"Aster. Mag: ", field: String(format: "%0.2f",item.AstMag!), units:"")
    }
    return asterMagAttrStr
  }
  
  func updateCombinedMagFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var combMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Comb. Mag       —")
    if item.CombMag != nil
    {
      combMagAttrStr = self.formatLabelandField(label:"Comb. Mag:  ", field: String(format: "%0.2f",item.CombMag!), units:"")
    }
    return combMagAttrStr
  }
  
  func updateMagDropFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var magDropAttrStr: NSAttributedString = NSMutableAttributedString(string: "Mag Drop       —")
    if item.MagDrop != nil
    {
      magDropAttrStr = self.formatLabelandField(label:"Mag Drop: ", field: String(format: "%0.2f",item.MagDrop!), units:"")
    }
    DispatchQueue.main.async{}
    return magDropAttrStr
  }
  
  func updateAsteroidRotationFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var asterRotationAttrStr: NSAttributedString = NSMutableAttributedString(string: "Rotation       —")
    if item.AstRotationHrs != nil
    {
      asterRotationAttrStr = self.formatLabelandField(label:"Rotation: ", field: String(format: "%0.3fh",item.AstRotationHrs!), units:"")
    }
    return asterRotationAttrStr
  }
  
  func updateAsteroidRotationAmpFld(_ item: EventWithDetails) -> NSAttributedString
  {
    var asterAmpAttrStr: NSAttributedString = NSMutableAttributedString(string: "Amplitude       —")
    if item.AstRotationAmplitude != nil
    {
      asterAmpAttrStr = self.formatLabelandField(label:"Amplitude: ", field: String(format: "%0.2fm",item.AstRotationAmplitude!), units:"")
    }
    return asterAmpAttrStr
  }
  
  func hideBVStarDiamView(_ item: EventWithDetails) -> Bool
  {
    if item.BV == nil && item.StellarDiaMas == nil
    {
      return true
    }
    else
    {
      return false
    }
  }
  
  func hideAsterRotAmpView(_ item: EventWithDetails) -> Bool
  {
    if item.AstRotationHrs == nil && item.AstRotationAmplitude == nil
    {
      return true
    }
    else
    {
      return false
    }
  }
  
  // MARK: - shadow bar plot functions
  func updateShadowBarView(_ item: EventWithDetails,stationsExistPastSigma1: Bool) -> (shadowFactor:Double,sig1Factor:Double,sig2Factor:Double,sig3Factor:Double)
  {
    print()
    print(">updateShadowBarView")
    let shadowWidth = item.AstDiaKm!
    let sig1Width = item.OneSigmaErrorWidthKm!
    let totalBarsWidthKm = pathBarsTotalWidth(astDiamKm: item.AstDiaKm!, sigma1WidthKm: sig1Width, stationsExistPastSigma1: stationsExistPastSigma1)
    
    let shadowFactor = shadowWidth / totalBarsWidthKm
    let sigma1Factor = (shadowWidth + (2 * sig1Width)) / totalBarsWidthKm
    let sigma2Factor = (shadowWidth + (4 * sig1Width)) / totalBarsWidthKm
    let sigma3Factor = (shadowWidth + (6 * sig1Width)) / totalBarsWidthKm
    
    print("<updateShadowBarView")
    print()
    return (shadowFactor,sigma1Factor,sigma2Factor,sigma3Factor)
  }
  
  func assignStationFactor(_ item: EventWithDetails, station: Station, stationsExistPastSigma1: Bool) -> Double
  {
    let stationChordOffset = station.ChordOffsetKm!
    let barPlotTotalWidth = pathBarsTotalWidth(astDiamKm: item.AstDiaKm!, sigma1WidthKm: item.OneSigmaErrorWidthKm!, stationsExistPastSigma1: stationsExistPastSigma1)
    var stationFactor = stationChordOffset / (barPlotTotalWidth / 2)
    print()
    print("#######")
    print("station.ChordOffsetKm=",station.ChordOffsetKm!)
    print("barPlotTotalWidth=",barPlotTotalWidth)
    print("stationFactor=",stationFactor)
    
    return stationFactor
  }
  
  // MARK: - attributed text functions
  func formatLabelandField(label: String, field: String, units: String) -> NSAttributedString
  {
    var labelFont =   UIFont.preferredFont(forTextStyle: .callout)
    var fieldFont =   UIFont.preferredFont(forTextStyle: .headline)
    if sizeClassIsRR
    {
      labelFont =   UIFont.preferredFont(forTextStyle: .title2)
      fieldFont =   UIFont.preferredFont(forTextStyle: .title1)
    }
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
  
  // MARK: - stations functions
  static func barPlotToSigma3(_ item: EventWithDetails) -> Bool
  {
    //implement station distance beyond sigma1 later
    for station in item.Stations!
    {
      if fabs(station.ChordOffsetKm!) >= item.OneSigmaErrorWidthKm!
      {
        return true
      }
    }
    return false
  }
  
  func printStations(_ item: EventDetails)
  {
    for station in item.Stations!
    {
      print()
      print("station = ",station)
    }
  }
  
  static func primaryStation(_ item: EventWithDetails) -> ObserverStation?
  {
    for station in item.Stations!
    {
      if station.IsPrimaryStation! {return station}
    }
    return nil
  }
  
  func myStations(_ item: EventWithDetails) -> [ObserverStation]?
  {
    var myStations: [ObserverStation] = []
    for station in item.Stations!
    {
      if station.IsOwnStation! {myStations.append(station)}
    }
    return myStations
  }
  
  func otherStations(_ item: EventWithDetails) -> [ObserverStation]?
  {
    var otherStations: [ObserverStation] = []
    for station in item.Stations!
    {
      if !station.IsOwnStation! {otherStations.append(station)}
    }
    return otherStations
  }
  
  static func primaryStationIndex(_ item: EventWithDetails) -> Int?
  {
    if let index = item.Stations?.firstIndex(where: {$0.IsPrimaryStation!} )
    {
      return  index
    }
    return nil
  }
  
  static func primaryStationIndex(_ stations: [ObserverStation]) -> Int?
  {
    if let index = stations.firstIndex(where: {$0.IsPrimaryStation!} )
    {
      return  index
    }
    return nil
  }
  
  func stationAtIndex(index: Int, _ item: EventDetails) -> Station
  {
    return item.Stations![index]
  }
  
  func stationAtIndex(index: Int, _ stations: [Station]) -> Station
  {
    return stations[index]
  }
  
  enum SortOrder: String
  {
    case ascending
    case descending
  }
  
  static func stationsSortedByChordOffset(_ item: EventWithDetails, order: SortOrder) -> [ObserverStation]
  {
    let stations: [ObserverStation] = item.Stations!
    let sortOrder: SortOrder = order
    switch sortOrder
    {
    case .ascending:
      return stations.sorted(by: {$0.ChordOffsetKm! < $1.ChordOffsetKm!} )
    case .descending:
      return stations.sorted(by: {$0.ChordOffsetKm! > $1.ChordOffsetKm!} )
    }
  }
  
  static func stationsSortedByChordOffset(_ stations: [ObserverStation], order: SortOrder) -> [ObserverStation]
  {
    let sortOrder: SortOrder = order
    switch sortOrder
    {
    case .ascending:
      return stations.sorted(by: {$0.ChordOffsetKm! < $1.ChordOffsetKm!} )
    case .descending:
      return stations.sorted(by: {$0.ChordOffsetKm! > $1.ChordOffsetKm!} )
    }
  }
  
  func stationsSortedByCloudCover(_ item: EventDetails, order: SortOrder) -> [Station]
  {
    let stations: [Station] = item.Stations!
    let sortOrder: SortOrder = order
    switch sortOrder
    {
    case .ascending:
      return stations.sorted(by: {$0.CloudCover! < $1.CloudCover!} )
    case .descending:
      return stations.sorted(by: {$0.CloudCover! > $1.CloudCover!} )
    }
  }
  
  func prettyPrintStation(_ item: EventDetails, index: Int)
  {
    let stationToPrint = EventStation(station: item.Stations![index])
    stationToPrint.prettyPrint()    
  }
  
  // MARK: - Field Update Functiosn
  func updateEventTimeFlds(_ item: inout EventWithDetails) -> (eventTime:String, remainingTime:NSAttributedString)
  {
    var eventUtcStr = "—"
    var leadTimeStr = "—"
    var leadTimeAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    var completionDateStr = "—"
    if item.Stations![0].EventTimeUtc != nil
    {
      eventUtcStr = formatEventTime(timeString: item.Stations![0].EventTimeUtc!)
      leadTimeStr = leadTime(timeString: item.Stations![0].EventTimeUtc!)
      leadTimeAttrStr = self.formatLabelandField(label:"", field: leadTimeStr, units:"")
      let eventDateFormatter = DateFormatter()
      eventDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
      eventDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
      let completionDate = eventDateFormatter.date(from: item.Stations![0].EventTimeUtc!)!
      eventDateFormatter.dateFormat = "dd MMM, HH:mm:ss' UT'"
      completionDateStr = eventDateFormatter.string(from: completionDate )
    }
    return (completionDateStr,leadTimeAttrStr)
  }
}

