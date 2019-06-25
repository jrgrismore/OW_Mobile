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

  
  // MARK: - event detail update functions
  func updateObjectFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var objectStr = "—"
    var objectAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.StarName != nil
    {
      objectAttrStr = self.formatLabelandField(label:"", field: item.StarName!, units:"")
      //      objectStr = "occults " + item.StarName!
    }
    return objectAttrStr
  }

  func updateRankFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var rankStr = "Rank: —"
    var rankAttrStr: NSAttributedString = NSMutableAttributedString(string: "Rank: —")
    if item.Rank != nil
    {
      rankAttrStr = self.formatLabelandField(label:"Rank: ", field: String(format: "%d",item.Rank!), units:"")
      
      //      rankStr = String(format: "Rank: %d",item.Rank!)
    }
    return rankAttrStr
  }
  
  func updateFeedFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var feedStr = "—"
    var feedAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.Feed != nil
    {
      feedAttrStr = self.formatLabelandField(label:"", field: item.Feed!, units:"")
      //      feedStr = item.Feed!
    }
    return feedAttrStr
    
  }
  
  func updateRAFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var raStr = "RA   —"
    var raAttrStr: NSAttributedString = NSMutableAttributedString(string: "RA   —")
    if item.RAHours != nil
    {
      //******convert decimal hours to hh:mm:ss
      let raTuple = floatRAtoHMS(floatRA: item.RAHours!)
      //      raStr = String(format: "RA %0.2f",item.RAHours!)
      let raFldStr = String(format: "%02dh %02dm %04.1fs",raTuple.hours,raTuple.minutes,raTuple.seconds)
      raAttrStr = self.formatLabelandField(label:"RA ", field: raFldStr, units:"")
      //      raStr = String(format: "RA  %02dh %02dm %04.1fs",raTuple.hours,raTuple.minutes,raTuple.seconds)
    }
    return raAttrStr
  }
  
  func updateDecFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var decStr = "DE   —"
    var decAttrStr: NSAttributedString = NSMutableAttributedString(string: "DE   —")
    if item.DEDeg != nil
    {
      //******convert decimal degrees to dd:mm:ss
      let decTuple = floatDecToDMS(floatDegrees: item.DEDeg!)
      //      decStr = String(format: "DE %0.2f",item.DEDeg!)
      let decFldStr = String(format: "%+03d° %02d' %04.1f\"",decTuple.degrees,labs(decTuple.minutes),fabs(decTuple.seconds))
      decAttrStr = self.formatLabelandField(label:"DE ", field: decFldStr, units:"")
      //     decStr = String(format: "DE  %+03d° %02d' %04.1f\"",decTuple.degrees,labs(decTuple.minutes),fabs(decTuple.seconds))
    }
    return decAttrStr
  }
  
  func updateBVFld(_ item: EventDetails) -> NSAttributedString
  {
    //      var bvStr = "B-V   —"
    var bvAttrStr: NSAttributedString = NSMutableAttributedString(string: "B-V   —")
    if item.BV != nil
    {
      //        bvStr = String(format: "B-V %0.3f",item.BV!)
      bvAttrStr = self.formatLabelandField(label:"B-V ", field: String(format: "%0.3f",item.BV!), units:"")
    }
    DispatchQueue.main.async{}
    return bvAttrStr
  }
  
  func updateStarDiamFld(_ item: EventDetails) -> NSAttributedString
  {
    //      var stellarDiamStr = "Stellar Dia.          —"
    var starDiamAttrStr: NSAttributedString = NSMutableAttributedString(string: "Stellar Dia.          —")
    if item.StellarDia != nil
    {
      
      //        stellarDiamStr = String(format: "Stellar Dia. %0.1f mas",item.StellarDia!)
      starDiamAttrStr = self.formatLabelandField(label:"Stellar Dia. ", field: String(format: "%0.1f",item.StellarDia!), units:" mas")
    }
    DispatchQueue.main.async{}
    return starDiamAttrStr
  }
  
  func updateAsteroidClassFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var asteroidClassStr = "—"
    var asteroidClassAttrStr: NSAttributedString = NSMutableAttributedString(string: "—")
    if item.AstClass != nil
    {
      //      asteroidClassStr = item.AstClass!
      asteroidClassAttrStr = self.formatLabelandField(label:"", field: item.AstClass!, units:"")
    }
    return asteroidClassAttrStr
  }
  
  func updateAsteroidDiamKM(_ item: EventDetails) -> NSAttributedString
  {
    var asteroidDiamAttrStr: NSAttributedString = NSMutableAttributedString(string: "Diam        —")
    if item.AstDiaKm != nil
    {
      asteroidDiamAttrStr = self.formatLabelandField(label:"Diam ", field: String(format: "%0.1f",item.AstDiaKm!), units:" km")
    }
    return asteroidDiamAttrStr
  }

  func updateStarMagFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var starMagStr = "Star Mag     —"
    var starMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Star Mag     —")
    if item.StarMag != nil
    {
      //      starMagStr = String(format: "Star Mag %0.2f",item.StarMag!)
      starMagAttrStr = self.formatLabelandField(label:"Star Mag ", field: String(format: "%0.2f",item.StarMag!), units:"")
    }
    return starMagAttrStr
  }
  
  func updateAsteroidMagFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var asterMagStr = "Aster. Mag     —"
    var asterMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Aster. Mag     —")
    if item.AstMag != nil
    {
      //      asterMagStr = String(format: "Aster. Mag %0.2f",item.AstMag!)
      asterMagAttrStr = self.formatLabelandField(label:"Aster. Mag ", field: String(format: "%0.2f",item.AstMag!), units:"")
    }
    return asterMagAttrStr
  }
  
  func updateCombinedMagFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var combMagStr = "Comb. Mag       —"
    var combMagAttrStr: NSAttributedString = NSMutableAttributedString(string: "Comb. Mag       —")
    if item.CombMag != nil
    {
      //      combMagStr = String(format: "Comb. Mag %0.2f",item.CombMag!)
      combMagAttrStr = self.formatLabelandField(label:"Comb. Mag  ", field: String(format: "%0.2f",item.CombMag!), units:"")
    }
    return combMagAttrStr
  }
  
  func updateMagDropFld(_ item: EventDetails) -> NSAttributedString
  {
    //    var magDropStr = "Mag Drop       —"
    var magDropAttrStr: NSAttributedString = NSMutableAttributedString(string: "Mag Drop       —")
    if item.MagDrop != nil
    {
      //      magDropStr = String(format: "Mag Drop %0.2f",item.MagDrop!)
      magDropAttrStr = self.formatLabelandField(label:"Mag Drop ", field: String(format: "%0.2f",item.MagDrop!), units:"")
    }
    DispatchQueue.main.async{}
    return magDropAttrStr
  }
  
  func updateAsteroidRotationFld(_ item: EventDetails) -> NSAttributedString
  {
    //      var asterRotationStr = "Rotation       —"
    var asterRotationAttrStr: NSAttributedString = NSMutableAttributedString(string: "Rotation       —")
    if item.AstRotationHrs != nil
    {
      //        asterRotationStr = String(format: "Rotation %0.3fh",item.AstRotationHrs!)
      asterRotationAttrStr = self.formatLabelandField(label:"Rotation ", field: String(format: "%0.3fh",item.AstRotationHrs!), units:"")
    }
    return asterRotationAttrStr
  }
  
  func updateAsteroidRotationAmpFld(_ item: EventDetails) -> NSAttributedString
  {
    //      var asterAmpStr = "Amplitude       —"
    var asterAmpAttrStr: NSAttributedString = NSMutableAttributedString(string: "Amplitude       —")
    if item.AstRotationAmplitude != nil
    {
      //        asterAmpStr = String(format: "Amplitude %0.2fm",item.AstRotationAmplitude!)
      asterAmpAttrStr = self.formatLabelandField(label:"Amplitude ", field: String(format: "%0.2fm",item.AstRotationAmplitude!), units:"")
    }
    return asterAmpAttrStr
  }

  func hideBVStarDiamView(_ item: EventDetails) -> Bool
  {
    if item.BV == nil && item.StellarDia == nil
    {
      return true
    }
    else
    {
      return false
    }
  }

  func hideAsterRotAmpView(_ item: EventDetails) -> Bool
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
  func updateShadowBarView(_ item: EventDetails,stationsExistPastSigma1: Bool) -> (shadowFactor:Double,sig1Factor:Double,sig2Factor:Double,sig3Factor:Double)
  {
    let shadowWidth = item.AstDiaKm!
    let sig1Width = item.OneSigmaErrorWidthKm!
    
    var plotBarsTuple = shadowSigmaBarScales(astDiam: item.AstDiaKm!, sigma1Width: sig1Width , stationsExistPastSigma1: stationsExistPastSigma1)
    let totalBarsWidthKm = pathBarsTotalWidth(astDiamKm: item.AstDiaKm!, sigma1WidthKm: sig1Width, stationsExistPastSigma1: stationsExistPastSigma1)

    let shadowFactor = shadowWidth / totalBarsWidthKm
    let sigma1Factor = (shadowWidth + (2 * sig1Width)) / totalBarsWidthKm
    let sigma2Factor = (shadowWidth + (4 * sig1Width)) / totalBarsWidthKm
    let sigma3Factor = (shadowWidth + (6 * sig1Width)) / totalBarsWidthKm

    return (shadowFactor,sigma1Factor,sigma2Factor,sigma3Factor)
  }
  
  // MARK: - attributed text functions
  func formatLabelandField(label: String, field: String, units: String) -> NSAttributedString
  {
    let labelFont =   UIFont.preferredFont(forTextStyle: .callout)
    let fieldFont =   UIFont.preferredFont(forTextStyle: .headline)
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
  func barPlotToSigma3(_ item: EventDetails) -> Bool
  {
    //implement station distance beyond sigma1 later
    return false
  }
  
}
