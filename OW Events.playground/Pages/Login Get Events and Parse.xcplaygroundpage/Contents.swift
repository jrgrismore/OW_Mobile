import Foundation
import PlaygroundSupport

let host = "www.occultwatcher.net"
let path = "/api/v1/events/details-list"
let scheme = "https"
let user = "dunham@starpower.net"
let password = "qwerty123456"

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
  var StellarDiaMas: Double?
  var StarName: String?
  var OtherStarNames: String?
  var AstClass: String?
  var AstRotationHrs: Double?
  var AstRotationAmplitude: Double?
  var PredictionUpdated: String?
  var OneSigmaErrorWidthKm: Double?   //new
}

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
  
  var ErrorInTimeSec: Double?
  var StarAlt: Double?
  var StarAz: Double?
  var SunAlt: Double?
  var MoonAlt: Double?
  var MoonAz: Double?
  var StellarDiaMas: Double?
  var MoonDist: Double?
  var MoonPhase: Double?
  var CombMag: Double?
  var StarColour: Double?
}

var parsedJSON = [EventWithDetails]()

//parse json data passed into function
func parseJSONData(jsonData: Data) -> [EventWithDetails]
{
  //create decoder instance
  let decoder = JSONDecoder()
  //use do try catch to trap any errors when decoding
  do {
    //set decoder to automatically convert from snake case to camel case
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    //apply decoder to json data to create entire array of To Do items
    parsedJSON = try decoder.decode([EventWithDetails].self, from: jsonData)
  } catch let error {
    print(error as Any)
  }
  return parsedJSON
}

//create url
let credential = URLCredential(user: user, password: password, persistence: .forSession)
let protectionSpace = URLProtectionSpace(host: host, port: 443, protocol: scheme, realm: "Restricted", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
//URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace, task: <#T##URLSessionTask#>)

let config = URLSessionConfiguration.default
let owSession = URLSession(configuration: config)

var urlComponents = URLComponents()
urlComponents.scheme = scheme
urlComponents.host = host
urlComponents.path = path
urlComponents.user = user
urlComponents.password = password

let owURL = urlComponents.url
print("owURL = ",owURL!)
let owTask = owSession.dataTask(with: owURL!)
{
  (data,response,error) in
  guard let dataResponse = data, error == nil
    else
  {
    print("Error:", error as Any)
    return
  }
//  print("data=", String(data: data!, encoding: .utf8)!)
  let owEvents = parseJSONData(jsonData: dataResponse)
//  print("owEvents=",owEvents)
  for item in owEvents
  {
    print()
    print("Id =", item.Id!)
    print("Object =", item.Object!)
    print("StarMag =", item.StarMag!)
    print("MagDrop =", item.MagDrop!)
    print("MaxDurSec =", item.MaxDurSec!)
    print("EventTimeUtc =", item.EventTimeUtc!)
    print("ErrorInTimeSec =", item.ErrorInTimeSec!)
    print("WeatherInfoAvailable =", item.WeatherInfoAvailable!)
    print("CloudCover =", item.CloudCover!)
    print("Wind =", item.Wind!)
    print("TempDegC =", item.TempDegC!)
    print("HighCloud =", item.HighCloud!)
    print("BestStationPos =", item.BestStationPos!)
    print("StarColour =", item.StarColour!)
    for station in item.Stations!
    {
      print(" StationID =",station.StationId!)
      print("   StationName =",station.StationName!)
      print("   EventTimeUtc =",station.EventTimeUtc!)
      print("   WeatherInfoAvailable =",station.WeatherInfoAvailable!)
      print("   CloudCover =",station.CloudCover!)
      print("   Wind =",station.Wind!)
      print("   TempDegC =",station.TempDegC!)
      print("   HighCloud =",station.HighCloud!)
      print("   StationPos =",station.StationPos!)
      print("   ChordOffsetKm =",station.ChordOffsetKm!)
      print("   OccultDistanceKm =",station.OccultDistanceKm!)
      print("   IsOwnStation =",station.IsOwnStation!)
      print("   IsPrimaryStation =",station.IsPrimaryStation!)
      print("   ErrorInTimeSec =",station.ErrorInTimeSec!)
      print("   StarAlt =",station.StarAlt!)
      print("   StarAz =",station.StarAz!)
      print("   SunAlt =",station.SunAlt!)
      print("   MoonAlt =",station.MoonAlt!)
      print("   MoonAz =",station.MoonAz!)
      print("   MoonDist =",station.MoonDist!)
      print("   MoonPhase =",station.MoonPhase!)
      print("   CombMag =",station.CombMag!)
      print("   StarColour =",station.StarColour!)
    }
    print("Feed =",item.Feed!)
    print("Rank =",item.Rank!)
    print("BV =",item.BV)
    print("CombMag =",item.CombMag!)
    print("AstMag =",item.AstMag!)
    print("MoonDist =",item.MoonDist!)
    print("MoonPhase =",item.MoonPhase!)
    print("AstDiaKm =",item.AstDiaKm!)
    print("AstDistUA =",item.AstDistUA!)
    print("RAHours =",item.RAHours!)
    print("DEDeg =",item.DEDeg!)
    print("StarAlt =",item.StarAlt!)
    print("StarAz =",item.StarAz!)
    print("SunAlt =",item.SunAlt!)
    print("MoonAlt =",item.MoonAlt!)
    print("MoonAz =",item.MoonAz!)
    print("StellarDiaMas =",item.StellarDiaMas)
    print("StarName =",item.StarName!)
    print("OtherStarNames =",item.OtherStarNames!)
    print("AstClass =",item.AstClass!)
    print("AstRotationHrs =",item.AstRotationHrs)
    print("AstRotationAmplitude =",item.AstRotationAmplitude)
    print("PredictionUpdated =",item.PredictionUpdated!)
    print("OneSigmaErrorWidthKm =",item.OneSigmaErrorWidthKm!)
  }
  print()
}
owTask.resume()
