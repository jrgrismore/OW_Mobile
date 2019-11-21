//
//  UtilityFunctions.swift
//  OW_Mobile
//
//  Created by John Grismore on 5/24/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import Foundation
import UIKit

func formatUTCEventTime(timeString: String) -> String
{
  let eventTimeFormatter = DateFormatter()
  eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
  if let formattedDate = eventTimeFormatter.date(from: timeString)
  {
    eventTimeFormatter.dateFormat = "dd MMM, HH:mm:ss 'UT'"
    return eventTimeFormatter.string(from: formattedDate)
  }
  return timeString
}

func formatLocalEventTime(timeString: String) -> String
{
  let eventTimeFormatter = DateFormatter()
  eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
  let utcTimeDate = eventTimeFormatter.date(from: timeString)!
//  print("utcTimeDate=",utcTimeDate)
  switch appSettings.eventDayFormat
  {
  case 0:   //Thursday (Evening/Night/Morning, dd mmm, HH:mm)
//    print("day format is: Thursday (Evening/Night/Morning), dd mmm, HH:mm")
    eventTimeFormatter.timeZone = TimeZone.current
    let localTimeStr = eventTimeFormatter.string(from: utcTimeDate)
//    print("localTimeStr=",localTimeStr)
    let eveNightMorn = eveningNightMorning(localDateStr: localTimeStr)
    if let formattedDate = eventTimeFormatter.date(from: localTimeStr)
    {
      let dayStr = eveNightMorn.dayName + " " + eveNightMorn.eveNight
//      print("dayStr=",dayStr)
      eventTimeFormatter.dateFormat = "dd MMM, HH:mm"
      return dayStr +  ", " + eventTimeFormatter.string(from: formattedDate)
    }
  case 1:   //Thursday (Evening/Night), dd mmm, HH:mm
//    print("day format is: Thursday (Evening/Night), dd mmm, HH:mm")
    eventTimeFormatter.timeZone = TimeZone.current
    let localTimeStr = eventTimeFormatter.string(from: utcTimeDate)
//    print("localTimeStr=",localTimeStr)
    let eveNight = eveningNight(localDateStr: localTimeStr)
    if let formattedDate = eventTimeFormatter.date(from: localTimeStr)
    {
      let dayStr = eveNight.dayName + " " + eveNight.eveNight
//      print("dayStr=",dayStr)
      eventTimeFormatter.dateFormat = "dd MMM, HH:mm"
      return dayStr +  ", " + eventTimeFormatter.string(from: formattedDate)
    }
  case 2:   //07 November 2019, HH:mm:ss
//    print("day format is: 07 November 2019, HH:mm:ss")
    if let formattedDate = eventTimeFormatter.date(from: timeString)
    {
      eventTimeFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
      eventTimeFormatter.timeZone = TimeZone.current
      return eventTimeFormatter.string(from: formattedDate)
    }
  default:   //07 November, HH:mm:ss
//    print("day format is: 07 November, HH:mm:ss")
    if let formattedDate = eventTimeFormatter.date(from: timeString)
    {
      eventTimeFormatter.dateFormat = "dd MMM, HH:mm"
      eventTimeFormatter.timeZone = TimeZone.current
      return eventTimeFormatter.string(from: formattedDate)
    }
  }
  return timeString
}

func leadTime(timeString: String) -> String
{
  var leadTimeString = ""
  let eventTimeFormatter = DateFormatter()
  eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
  if let eventDate = eventTimeFormatter.date(from: timeString)
  {
    let leadTimeSeconds = Int(eventDate.timeIntervalSinceNow)
    if leadTimeSeconds <= 0 { return "completed" }
    let leadTimeMinutes = leadTimeSeconds / 60
    let leadTimeHours = leadTimeMinutes / 60
    let leadTimeDays = Double(leadTimeHours) / 24.0
//    print("leadTimeDays=",leadTimeDays)
    if leadTimeMinutes > 0
    {
      if leadTimeMinutes < 90
      {
        leadTimeString = String(format: "in \(leadTimeMinutes) min")
      }
      else if leadTimeHours < 48
      {
        leadTimeString = String(format: "in \(leadTimeHours) hours")
      }
      else
      {
        if leadTimeDays < 7.0
        {
          leadTimeString = String(format: "in %0.1f days",leadTimeDays)
        } else {
          leadTimeString = String(format: "in %0.0f days",leadTimeDays)
        }
      }
    }
    return leadTimeString
  }
  return leadTimeString
}

func utcStrToUTCDate(eventTimeStr: String) -> Date?
{
  let eventTimeFormatter = DateFormatter()
  eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
  if let formattedDate = eventTimeFormatter.date(from: eventTimeStr)
  {
    return formattedDate
  }
  return nil
}

func utcStrToLocalDate(eventTimeStr: String) -> Date?
{
  let eventTimeFormatter = DateFormatter()
  eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  eventTimeFormatter.timeZone = TimeZone.current
  if let formattedDate = eventTimeFormatter.date(from: eventTimeStr)
  {
    return formattedDate
  }
  return nil
}

func utcStrToLocalDayOfMonth(eventTimeStr: String) -> String?
{
  //  print("utcStrToLocalDayOfMonth")
  //  print("eventTimeStr=",eventTimeStr)
  let eventTimeFormatter = DateFormatter()
  eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
  let originalDate = eventTimeFormatter.date(from: eventTimeStr)!
  //  print("original date =",originalDate)
  eventTimeFormatter.timeZone = TimeZone.current
  eventTimeFormatter.dateFormat = "dd MMM"
  let localDateStr = eventTimeFormatter.string(from: originalDate)
  //  print("localDateStr=",localDateStr)
  return localDateStr
}

func eveningNightMorning(localDateStr: String) -> (eveNight: String, dayName: String)
{
  var eveOrNightOrMorn = "Eve"
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  dateFormatter.timeZone = .current
  let localDate = dateFormatter.date(from: localDateStr)
  let dateComp = Calendar.current.dateComponents([.hour], from: localDate ?? Date())
  let hour = dateComp.hour!
  let hourValue = hour
  dateFormatter.dateFormat = "EEE"
  var dayOfWeek = dateFormatter.string(from: localDate!)
  switch hourValue
  {
  case 0..<5:
    eveOrNightOrMorn = "Night"
    let toDate = Calendar.current.date(byAdding: .day, value: -1, to: localDate!)
    dateFormatter.dateFormat = "EEE"
    dayOfWeek = dateFormatter.string(from: toDate!)
  case 5..<12:
    eveOrNightOrMorn = "Morn"
  case 12...24:
    eveOrNightOrMorn = "Eve"
  default:
    eveOrNightOrMorn = "Eve"
  }
  return (eveOrNightOrMorn, dayOfWeek)
}


func eveningNight(localDateStr: String) -> (eveNight: String, dayName: String)
{
  var eveOrNight = "Eve"
  var dayOfWeek = ""
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
  dateFormatter.timeZone = .current
  let localDate = dateFormatter.date(from: localDateStr)
  let dateComp = Calendar.current.dateComponents([.hour], from: localDate ?? Date())
  let hour = dateComp.hour!
  let hourValue = hour
  switch hourValue
  {
  case 0..<12:
    eveOrNight = "Night"
    let toDate = Calendar.current.date(byAdding: .day, value: -1, to: localDate!)
    dateFormatter.dateFormat = "EEE"
    dayOfWeek = dateFormatter.string(from: toDate!)
  case 12...24:
    eveOrNight = "Eve"
    dateFormatter.dateFormat = "EEE"
    dayOfWeek = dateFormatter.string(from: localDate!)
  default:
    eveOrNight = "Eve"
  }
  return (eveOrNight,dayOfWeek)
}


func starColorIcon(_ starColorIconVal: Int?) -> UIImage
{
  var starColorImage: UIImage
  if starColorIconVal != nil
  {
    switch starColorIconVal
    {
    case 0:
      starColorImage =  #imageLiteral(resourceName: "star_black")
    case 1:
      starColorImage =  #imageLiteral(resourceName: "star_b")
    case 2:
      starColorImage =  #imageLiteral(resourceName: "star_w")
    case 3:
      starColorImage =  #imageLiteral(resourceName: "star_y")
    case 4:
      starColorImage =  #imageLiteral(resourceName: "star_o")
    case 5:
      starColorImage =  #imageLiteral(resourceName: "star_r")
    default:
      starColorImage =  #imageLiteral(resourceName: "star_black")
    }
  } else {
    starColorImage =  #imageLiteral(resourceName: "star_black")
  }
  return starColorImage
}


func cloudIcon(_ cloudIconVal: Int?) -> UIImage
{
  //set appropriate cloud image
  //      0% -  9%   cloud_0.png
  //    10% - 19%    cloud_10.png
  //    20% - 29%    cloud_20.png
  //    30% - 39%    cloud_30.png
  //    40% - 49%    cloud_40.png
  //    50% - 59%    cloud_50.png
  //    60% - 69%    cloud_60.png
  //    70% - 79%    cloud_70.png
  //    80% - 89%    cloud_80.png
  //    90% - 100%   cloud_90.png
  var cloudImage: UIImage
  if cloudIconVal != nil
  {
    switch cloudIconVal!
    {
    case 0...9:
      cloudImage =  #imageLiteral(resourceName: "cloud_0")
    case 10...19:
      cloudImage =  #imageLiteral(resourceName: "cloud_10")
    case 20...29:
      cloudImage =  #imageLiteral(resourceName: "cloud_20")
    case 30...39:
      cloudImage =  #imageLiteral(resourceName: "cloud_30")
    case 40...49:
      cloudImage =  #imageLiteral(resourceName: "cloud_40.png")
    case 50...59:
      cloudImage =  #imageLiteral(resourceName: "cloud_50.png")
    case 60...69:
      cloudImage =  #imageLiteral(resourceName: "cloud_60.png")
    case 70...79:
      cloudImage =  #imageLiteral(resourceName: "cloud_70.png")
    case 80...89:
      cloudImage =  #imageLiteral(resourceName: "cloud_80.png")
    case 90...100:
      cloudImage =  #imageLiteral(resourceName: "cloud_90.png")
    default:
      cloudImage =  #imageLiteral(resourceName: "cloud_100.png")
    }
  } else {
    cloudImage =  #imageLiteral(resourceName: "cloud_100.png")
  }
  return cloudImage
}

func cloudColor(_ cloudIconVal: Int?) -> UIColor
{
  //set appropriate cloud image
  //      0% -  9%   cloud_0.png
  //    10% - 19%    cloud_10.png
  //    20% - 29%    cloud_20.png
  //    30% - 39%    cloud_30.png
  //    40% - 49%    cloud_40.png
  //    50% - 59%    cloud_50.png
  //    60% - 69%    cloud_60.png
  //    70% - 79%    cloud_70.png
  //    80% - 89%    cloud_80.png
  //    90% - 100%   cloud_90.png
  var cloudColor: UIColor
  switch cloudIconVal!
  {
  case 0...9:
    cloudColor =  #colorLiteral(red: 0.001137823565, green: 0.2069600523, blue: 0.4554731846, alpha: 1)
  case 10...19:
    cloudColor =  #colorLiteral(red: 0.06971666962, green: 0.3020606041, blue: 0.5551496744, alpha: 1)
  case 20...29:
    cloudColor =  #colorLiteral(red: 0.1543450356, green: 0.3969052434, blue: 0.6628355384, alpha: 1)
  case 30...39:
    cloudColor =  #colorLiteral(red: 0.2456468344, green: 0.503529191, blue: 0.7697986364, alpha: 1)
  case 40...49:
    cloudColor =  #colorLiteral(red: 0.342204392, green: 0.6059697866, blue: 0.8767475486, alpha: 1)
  case 50...59:
    cloudColor =  #colorLiteral(red: 0.4613946676, green: 0.7284020185, blue: 0.7289966345, alpha: 1)
  case 60...69:
    cloudColor =  #colorLiteral(red: 0.5686532259, green: 0.8384991288, blue: 0.8389254212, alpha: 1)
  case 70...79:
    cloudColor =  #colorLiteral(red: 0.6698740125, green: 0.9486840367, blue: 0.9488958716, alpha: 1)
  case 80...89:
    cloudColor =  #colorLiteral(red: 0.7646406293, green: 0.7647491693, blue: 0.7646064162, alpha: 1)
  case 90...100:
    cloudColor =  #colorLiteral(red: 0.8861995339, green: 0.8863242269, blue: 0.8861603141, alpha: 1)
  default:
    cloudColor =  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
  }
  return cloudColor
}

func windStrengthIcon(_ windStrengthIconValue: Int?) -> UIImage
{
  //    0 = wind_0.png;
  //    1 = wind_1.png;
  //    2 = wind_2.png;
  //    3 = wind_3.png;
  //    4 = wind_4.png;
  //    5, 6, 7 = wind_5_6_7.png;
  var windStrengthImage: UIImage
  if windStrengthIconValue != nil
  {
    switch windStrengthIconValue!
    {
    case 0:
      windStrengthImage =  #imageLiteral(resourceName: "wind_0")
    case 1:
      windStrengthImage =  #imageLiteral(resourceName: "wind_1")
    case 2:
      windStrengthImage =  #imageLiteral(resourceName: "wind_2")
    case 3:
      windStrengthImage =  #imageLiteral(resourceName: "wind_3")
    case 4:
      windStrengthImage =  #imageLiteral(resourceName: "wind_4")
    case 5...7:
      windStrengthImage =  #imageLiteral(resourceName: "wind_5_6_7")
    default:
      windStrengthImage =  #imageLiteral(resourceName: "wind_0")
    }
  } else {
    windStrengthImage =  #imageLiteral(resourceName: "wind_0")
  }
  return windStrengthImage
}

func windSignIcon(_ windSignIconValue: Int?) -> UIImage
{
  var windSignIconImage: UIImage
  //if there is wind use wind_sign.png, if no wind use wind_sign_gray.png
  if windSignIconValue != nil
  {
    if windSignIconValue! > 0
    {
      windSignIconImage = #imageLiteral(resourceName: "wind_sign")
    }
    else
    {
      windSignIconImage = #imageLiteral(resourceName: "wind_sign_gray")
    }
  } else {
    windSignIconImage = #imageLiteral(resourceName: "wind_sign_gray")
  }
  return windSignIconImage
}

func thermIcon(_ thermIconValue: Int?) -> UIImage
{
  // temp <= 0, blue
  // temp 0...16, yellow
  // temp 17...32, orange
  // temp > 32, red
  var thermometerIconImg: UIImage
  //need blank image for this
  thermometerIconImg = #imageLiteral(resourceName: "term_b")
  if thermIconValue != nil
  {
    if thermIconValue! <= 0
    {
      thermometerIconImg = #imageLiteral(resourceName: "term_b")
    }
    else if thermIconValue! < 16
    {
      thermometerIconImg = #imageLiteral(resourceName: "term_y")
    }
    else if thermIconValue! < 32
    {
      thermometerIconImg = #imageLiteral(resourceName: "term_o")
    }
    else if thermIconValue! >= 32
    {
      thermometerIconImg = #imageLiteral(resourceName: "term_r")
    }
  }
  return thermometerIconImg
}

func stationSigmaIcon(_ sigmaIconValue: Int?) -> UIImage
{
  //    Shadow (0) = spos_0.png,
  //    OneSigma (1) = spos_1_2.png,
  //    ThreeSigma (2) = spos_1_2.png,
  //    Outside (3) = = spos_3.png
  var sigmaIconImage: UIImage
  if sigmaIconValue != nil
  {
    switch sigmaIconValue!
    {
    case 0:
      sigmaIconImage =  #imageLiteral(resourceName: "spos_0")
    case 1:
      sigmaIconImage =  #imageLiteral(resourceName: "spos_1_2")
    case 2:
      sigmaIconImage =  #imageLiteral(resourceName: "spos_1_2")
    case 3:
      sigmaIconImage =  #imageLiteral(resourceName: "spos_3")
    default:
      sigmaIconImage =  #imageLiteral(resourceName: "spos_3")
    }
  } else {
    sigmaIconImage =  #imageLiteral(resourceName: "spos_3")
  }
  return sigmaIconImage
}

func moonAltIcon(_ moonAltIconValue: Double?) -> UIImage
{
  var moonAltIconImage: UIImage
  if moonAltIconValue != nil
  {
    switch moonAltIconValue
    {
    case 0:
      moonAltIconImage = #imageLiteral(resourceName: "moon_0.png")
    case 1:
      moonAltIconImage = #imageLiteral(resourceName: "moon_1.png")
    case 2:
      moonAltIconImage = #imageLiteral(resourceName: "moon_2.png")
    case 3:
      moonAltIconImage = #imageLiteral(resourceName: "moon_3.png")
    case 4:
      moonAltIconImage = #imageLiteral(resourceName: "moon_4.png")
    case 5:
      moonAltIconImage = #imageLiteral(resourceName: "moon_5.png")
    case 6:
      moonAltIconImage = #imageLiteral(resourceName: "moon_6.png")
    case 7:
      moonAltIconImage = #imageLiteral(resourceName: "moon_7.png")
    case 8:
      moonAltIconImage = #imageLiteral(resourceName: "moon_8.png")
    case 9:
      moonAltIconImage =  #imageLiteral(resourceName: "moon_9.png")
    case 10:
      moonAltIconImage = #imageLiteral(resourceName: "moon_10.png")
    case 11:
      moonAltIconImage = #imageLiteral(resourceName: "moon_11.png")
    case 12:
      moonAltIconImage = #imageLiteral(resourceName: "moon_12.png")
    case 13:
      moonAltIconImage = #imageLiteral(resourceName: "moon_13.png")
    case 14:
      moonAltIconImage = #imageLiteral(resourceName: "moon_14.png")
    case 15:
      moonAltIconImage = #imageLiteral(resourceName: "moon_15.png")
    case 16:
      moonAltIconImage = #imageLiteral(resourceName: "moon_16.png")
    case 17:
      moonAltIconImage = #imageLiteral(resourceName: "moon_17.png")
    case 18:
      moonAltIconImage = #imageLiteral(resourceName: "moon_18.png")
    case 19:
      moonAltIconImage = #imageLiteral(resourceName: "moon_19.png")
    default:
      moonAltIconImage = #imageLiteral(resourceName: "moon_0.png")
    }
  } else {
    moonAltIconImage = #imageLiteral(resourceName: "moon_0.png")
  }
  return moonAltIconImage
}

//********************************************
// RA HH.hhh -> HH MM SS
//********************************************
func floatRAtoHMS(floatRA: Double) -> (hours: Int, minutes: Int, seconds: Double)
{
  let restrictedRA = limitTo24Hours(floatHrs: floatRA)
  let hms = floatHoursToHMS(floatHrs: restrictedRA)
  return hms
}

//********************************************
//Dec DDD.ddd -> DD MM SS
//********************************************
func floatDecToDMS(floatDegrees: Double) -> (degrees: Int, minutes: Int, seconds: Double)
{
  let dms = floatDegreesToDMS(floatDeg: floatDegrees)
  return dms
}

//********************************************
// Limit time, 0 ≥ HH.hhh ≤ 24
//********************************************
func limitTo24Hours(floatHrs: Double) -> Double
{
  let moduloTuple = remainderCycles(dividend: floatHrs, divisor: 24.0)
  var remainderHrs = moduloTuple.remainder
  if remainderHrs > 24.0
  {
    remainderHrs = remainderHrs - 24.0
  }
  if remainderHrs < 0.0
  {
    remainderHrs = remainderHrs + 24.0
  }
  return remainderHrs
}

//********************************************
// Time HH.hhh -> HH MM SS
//********************************************
func floatHoursToHMS(floatHrs: Double) -> (hours: Int, minutes: Int, seconds: Double)
{
  var hours = Int(floatHrs)
  let floatMinutes = (floatHrs - Double(hours)) * 60.0
  var minutes = Int(floatMinutes)
  var seconds = (floatMinutes - Double(minutes)) * 60.0
  let secondsRoundOff = fabs(seconds - 60.0)
  if secondsRoundOff > 0.0 && secondsRoundOff < 0.0000000001
  {
    minutes = minutes + 1
    seconds = 0.0
  }
  if minutes == 60
  {
    hours = hours + 1
    minutes = 0
  }
  seconds = trunc(seconds * 1e9) / 1e9
  return (hours, minutes, seconds)
}

//********************************************
// Degrees DDD.ddd -> DDD MM SS
//********************************************
func floatDegreesToDMS(floatDeg: Double) -> (degrees: Int, minutes: Int, seconds: Double)
{
  var degrees = Int(floatDeg)
  let floatMinutes = (floatDeg - Double(degrees)) * 60.0
  var minutes = Int(floatMinutes)
  var seconds = (floatMinutes - Double(minutes)) * 60
  let secondsRoundOff = fabs(seconds - 60.0)
  if secondsRoundOff > 0.0 && secondsRoundOff < 0.0000000001
  {
    minutes = minutes + 1
    seconds = 0.0
  }
  if minutes == 60
  {
    degrees = degrees + 1
    minutes = 0
  }
  seconds = trunc(seconds * 1e9) / 1e9
  return (degrees, minutes, seconds)
}

//********************************************
// Remainder (modulo) and # of cycles from
// dividend and divisor
//********************************************
func remainderCycles(dividend: Double, divisor: Double) -> (remainder: Double, cycles: Int)
{
  let remainder = dividend.truncatingRemainder(dividingBy: divisor)
  let cycles = Int(dividend / divisor)
  return (remainder, cycles)
}


//calculate shadow and sigma bar width scales
func shadowSigmaBarScales(astDiam: Double, sigma1Width: Double, stationsExistPastSigma1: Bool) -> (shadowBarWidthFactor: Double, sigma1BarWidthFactor: Double, sigma2BarWidthFactor: Double, totalWidthKm: Double)
{
  var sigma1BarWidth =  astDiam + (2 * sigma1Width)
  var sigma2BarWidth = sigma1BarWidth + (2 * sigma1Width)
  var totalWidth = sigma1BarWidth
  if stationsExistPastSigma1
  {
    totalWidth = sigma1BarWidth + (4 * sigma1Width)
  }
  let shadowBarFactor = astDiam / totalWidth
  let sigma1BarFactor = sigma1BarWidth / totalWidth
  let sigma2BarFactor = sigma2BarWidth / totalWidth
  return (shadowBarFactor,sigma1BarFactor,sigma2BarFactor,totalWidth)
}

//calculate total width of path bars
func pathBarsTotalWidth(astDiamKm: Double, sigma1WidthKm: Double, stationsExistPastSigma1: Bool) -> Double
{
  let sigma1BarWidth =  astDiamKm + (2 * sigma1WidthKm)
  var totalWidth = sigma1BarWidth
  if stationsExistPastSigma1
  {
    //    print("total plot width includes sigma2 and sigma3")
    totalWidth = sigma1BarWidth + (4 * sigma1WidthKm)
  }
  return totalWidth
}

//scale plot
enum PlotScale: String
{
  case shadowEdge
  case sigma1Edge
  case sigma2Edge
  case sigma3Edge
  case farthestChord
}

func shadowWidthKm(_ item: EventWithDetails) -> Double
{
  return item.AstDiaKm!
}

func sigma1WidthKm(_ item: EventWithDetails) -> Double
{
  let shadowWidth = shadowWidthKm(item)
  let sigma1ErrorWidth = item.OneSigmaErrorWidthKm!   //shadow edge to sigma1 edge
  let sigma1TotalWidth = shadowWidth + sigma1ErrorWidth * 2
  return sigma1TotalWidth
}


func sigma2WidthKm(_ item: EventWithDetails) -> Double
{
  let sigma2ErrorWidth = item.OneSigmaErrorWidthKm!   //shadow edge to sigma1 edge
  let sigma2TotalWidth = sigma1WidthKm(item) + sigma2ErrorWidth * 2
  return sigma2TotalWidth
}

func sigma3WidthKm(_ item: EventWithDetails) -> Double
{
  let sigma3ErrorWidth = item.OneSigmaErrorWidthKm!   //shadow edge to sigma1 edge
  let sigma3TotalWidth = sigma2WidthKm(item)  + sigma3ErrorWidth * 2
  return sigma3TotalWidth
}

func farthestChordWidth(_ item: EventWithDetails) -> Double
{
  var farthestChordKm = 0.0
  for station in item.Stations!
  {
    if fabs(station.ChordOffsetKm!) > farthestChordKm
    {
      farthestChordKm = fabs(station.ChordOffsetKm!)
    }
  }
  let farthestTotalWidth = farthestChordKm * 2 + farthestChordKm * 0.05
  return farthestTotalWidth
}

func totalPlotWidthKm(_ item: EventWithDetails, scale: PlotScale) -> Double
{
  let shadowWidth = item.AstDiaKm!
  let sigma1TotalWidth = sigma1WidthKm(item)
  let sigma2TotalWidth = sigma2WidthKm(item)
  let sigma3TotalWidth = sigma3WidthKm(item)
  var farthestTotalWidth = farthestChordWidth(item)
  //  print("shadowWidth=",shadowWidth)
  //  print("OneSigmaErrorWidthKm=",item.OneSigmaErrorWidthKm)
  //  print("sigma1TotalWidth=",sigma1TotalWidth)
  //  print("sigma2TotalWidth=",sigma2TotalWidth)
  //  print("sigma3TotalWidth=",sigma3TotalWidth)
  //  print("farthestTotalWidth=",farthestTotalWidth)
  //  print("PlotScale=",scale)
  switch scale
  {
  case .shadowEdge:
    return shadowWidth
  case .sigma1Edge:
    return sigma1TotalWidth
  case .sigma2Edge:
    return sigma2TotalWidth
  case .sigma3Edge:
    return sigma3TotalWidth
  case .farthestChord:
    return farthestTotalWidth
  default:
    return sigma3TotalWidth
  }
}

func plotBarsWidthFactors(_ item: EventWithDetails, totalPlotWidthKm: Double) -> (shadowBarFactor:Double,sigma1BarFactor:Double,sigma2BarFactor:Double,sigma3BarFactor:Double)
{
  //  print("plotBarsWidthFactors")
  //  print("totalPlotWidthKm=",totalPlotWidthKm)
  let shadowWidth = item.AstDiaKm!
  let sigma1ErrorWidth = item.OneSigmaErrorWidthKm!   //shadow edge to sigma1 edge
  let sigma1TotalWidth = shadowWidth + sigma1ErrorWidth * 2
  let sigma2TotalWidth = sigma1TotalWidth + sigma1ErrorWidth * 2
  let sigma3TotalWidth = sigma2TotalWidth + sigma1ErrorWidth * 2
  //  print("shadowWidth=",shadowWidth)
  //  print("sigma1TotalWidth=",sigma1TotalWidth)
  //  print("sigma2TotalWidth=",sigma2TotalWidth)
  //  print("sigma3TotalWidth=",sigma3TotalWidth)
  
  
  let shadowBarWidthFactor = shadowWidth / totalPlotWidthKm
  let sigma1BarWidthFactor = sigma1TotalWidth / totalPlotWidthKm
  let sigma2BarWidthFactor = sigma2TotalWidth / totalPlotWidthKm
  let sigma3BarWidthFactor = sigma3TotalWidth / totalPlotWidthKm
  //  print("shadowBarWidthFactor=",shadowBarWidthFactor)
  //  print("sigma1BarWidthFactor=",sigma1BarWidthFactor)
  //  print("sigma2BarWidthFactor=",sigma2BarWidthFactor)
  //  print("sigma3BarWidthFactor=",sigma3BarWidthFactor)
  
  return (shadowBarWidthFactor, sigma1BarWidthFactor, sigma2BarWidthFactor, sigma3BarWidthFactor)
}

func plotStationBarFactor(station: ObserverStation, totalPlotWidthKm: Double) -> Double
{
  let stationBarFactor = station.ChordOffsetKm! / (totalPlotWidthKm / 2)
  return stationBarFactor
}


func loadSettings() -> Settings
{
  guard let encodedSettings = UserDefaults.standard.data(forKey: UDKeys.settings) else {
    return Settings()
  }
  let decodedSettings = try! JSONDecoder().decode(Settings.self, from: encodedSettings)
  return decodedSettings
}

func saveSettings(_ settings: Settings)
{
  let data = try? JSONEncoder().encode(settings)
  UserDefaults.standard.set(data, forKey: UDKeys.settings)
  //    print("saved and reloaded settings = ",loadSettings())
}


func assignAzIndicatorStr(azimuth: Double, azFormat: Bool) -> String
{
  var azStr = ""
  if (azFormat)
  {
    azStr = String(format: "@%d°", Int(azimuth))
    return azStr
  }
  if (azimuth <= 0 + 22.5 || azimuth > 360 - 22.5)
  {
    azStr = "N"
  }
  else if (azimuth <= 45 * 1 + 22.5 && azimuth > 45 * 1 - 22.5)
  {
    azStr = "NE"
  }
  else if (azimuth <= 45 * 2 + 22.5 && azimuth > 45 * 2 - 22.5)
  {
    azStr = "E"
  }
  else if (azimuth <= 45 * 3 + 22.5 && azimuth > 45 * 3 - 22.5)
  {
    azStr  = "SE"
  }
  else if (azimuth <= 45 * 4 + 22.5 && azimuth > 45 * 4 - 22.5)
  {
    azStr = "S"
  }
  else if (azimuth <= 45 * 5 + 22.5 && azimuth > 45 * 5 - 22.5)
  {
    azStr = "SW"
  }
  else if (azimuth <= 45 * 6 + 22.5 && azimuth > 45 * 6 - 22.5)
  {
    azStr = "W"
  }
  else if (azimuth <= 45 * 7 + 22.5 && azimuth > 45 * 7 - 22.5)
  {
    azStr = "NW"
  }
  return azStr
}

func celsiusToFahrenheit(degreesC: Double) -> Double
{
  return (9 / 5) * degreesC + 32
}

func fahrenheitToCelsius(degreesF: Double) -> Double
{
  return (degreesF - 32) * 5 / 9
}





func refreshEventsWithDetails(completionHandler: @escaping () ->())
{
  print("refreshEventsWithDetails")
  //  DispatchQueue.main.async {self.startSpinner()}
  OWWebAPI.shared.retrieveEventsWithDetails(completion: { (eventsWithDetailsData, error) in
    DispatchQueue.main.async
      {
        print("begin completion")
        if error != nil
        {
          print("error=",error)
           //need to show alert about no connection
          //or trigger notification about no connection
          NotificationCenter.default.post(name: Notification.Name(NotificationKeys.dataRefreshed), object: nil)
          
          print("\n\n\n\n\n")
          return
        } else {
          print("eventsWithDetailData.count=",eventsWithDetailsData!.count)
          print("\n\n\n\n\n")
//          print("refreshEventsWithDetails > eventsWithDetails=",eventsWithDetailsData!)
          // no errors
          eventsWithDetails = eventsWithDetailsData!
          if eventsWithDetailsData!.count < 1
          {
            DispatchQueue.main.async
              {
                //save empty array to userdefaults
                OWWebAPI.shared.saveEventsWithDetails([])
            }
            return
          }
        }
        //store update date in userDefaults
        UserDefaults.standard.set(Date(), forKey: UDKeys.lastEventListUpdate)
        OWWebAPI.shared.saveEventsWithDetails(eventsWithDetailsData!)
        completionHandler()
        //      let loadedEventDetailData = OWWebAPI.shared.loadEventsWithDetails()
    } //end of no errors block
  })
}

