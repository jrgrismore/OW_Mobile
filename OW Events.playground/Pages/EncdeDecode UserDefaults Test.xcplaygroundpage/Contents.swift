import Foundation
import PlaygroundSupport

struct Event: Codable
{
  var Id: String
  var Object: String
  var StarMag: Double
  var MagDrop: Double
  var MaxDurSec: Double
  var EventTimeUtc: String
  var ErrorInTimeSec: Double
  var WhetherInfoAvailable: Bool   //weather info available
  var CloudCover: Int
  var Wind: Int
  var TempDegC: Int
  var HighCloud: Bool
  var BestStationPos: Int
}

struct Events: Codable
{
  var events: [Event]
}

class WebService: NSObject
{
  let host = "www.occultwatcher.net"
  let path = "/api/v1/events/list"
  let scheme = "https"
  let user = "Alex Pratt"
  //  let user = "JohnG"
  let password = "qwerty123456"
  
  var parsedJSON = [Event]()
  
  // MARK: - OW Web Service Functions
  func creatURL(owSession: URLSession) -> URL
  {
    let credential = URLCredential(user: user, password: password, persistence: .forSession)
    //create url
    let protectionSpace = URLProtectionSpace(host: host, port: 443, protocol: scheme, realm: "Restricted", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
    URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.path = path
    urlComponents.user = user
    urlComponents.password = password
    
    let owURL = urlComponents.url!
    print("owURL = ",owURL)
    return owURL
  }
  
  func retrieveEventList(completion: @escaping ([Event]?, Error?) -> Void)
  {
    let config = URLSessionConfiguration.default
    let owSession = URLSession(configuration: config)
    let owURL = creatURL(owSession: owSession)
    print("owURL=",owURL)
    let owTask = owSession.dataTask(with: owURL)
    {
      (data,response,error) in
      guard let dataResponse = data, error == nil
        else
      {
        print("\n*******Error:", error as Any)
        return
      }
      print("data retrieved")
      let owEvents = self.parseEventData(jsonData: dataResponse)
      completion(owEvents,nil)
    }
    print("...owTask.resume()")
    owTask.resume()
  }
  
  func parseEventData(jsonData: Data) -> [Event]
  {
    //create decoder instance
    let decoder = JSONDecoder()
    //use do try catch to trap any errors when decoding
    do {
      //set decoder to automatically convert from snake case to camel case
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      //apply decoder to json data to create entire array of To Do items
      parsedJSON = try decoder.decode([Event].self, from: jsonData)
      //sort by event data/time (earliest first)
      parsedJSON.sort(by: { $0.EventTimeUtc < $1.EventTimeUtc })
      //test
//      saveEventData(owEvents: parsedJSON)
      
    } catch let error {
      print(error as Any)
    }
    return parsedJSON
  }
  
//  //save events to UserDefaults
//  func saveEventData(owEvents: [Event])
//  {
//    //encode then assign to user defaults
//    let jsonEncoder = JSONEncoder()
//    do
//    {
//      let jsonData = try jsonEncoder.encode(owEvents)
//      let jsonString = String(data: jsonData, encoding: .utf8)!
//      print("\nJSON encoding")
//      print(jsonString)
//    }
//    catch let error
//    {
//      print(error as Any)
//    }
//  }
  
  //restore events from UserDefaults
//  func restoreEventData() -> [Event]
//  {
//    let decoder = JSONDecoder()
//    decoder
//    //use do try catch to trap any errors when decoding
//    do {
//      //set decoder to automatically convert from snake case to camel case
//      decoder.keyDecodingStrategy = .convertFromSnakeCase
//      //apply decoder to json data to create entire array of To Do items
//      parsedJSON = try decoder.decode([Event].self, from: savedJson)
//    } catch {
//      print("decode error")
//    }
//    return []
//  }
  
  func printEventInfo(eventItem item: Event)
  {
    print()
    print("Id =", item.Id)
    print("Object =", item.Object)
    print("StarMag =", item.StarMag)
    print("MagDrop =", item.MagDrop)
    print("MaxDurSec =", item.MaxDurSec)
    print("EventTimeUtc =", item.EventTimeUtc)
    print("ErrorInTimeSec =", item.ErrorInTimeSec)
    print("WhetherInfoAvailable =", item.WhetherInfoAvailable)
    print("CloudCover =", item.CloudCover)
    print("Wind =", item.Wind)
    print("TempDegC =", item.TempDegC)
    print("HighCloud =", item.HighCloud)
    print("BestStationPos =", item.BestStationPos)
  }

}

let owWebClient = WebService()
func getEventList()
{
  owWebClient.retrieveEventList(completion: { (owEvents, error) in
    //fill cells
    print("download and parsing complete")
//    print("owEvents=",owEvents!)
    //encode oWEvents as json
    
    let encodedString = encodeEventData(owEvents: owEvents!)
    print("encodedString=",encodedString)
    let decodedData = decodeEventData(encodedString)
//    print("decodedData=",decodedData)
    let restoredData: [Event] = decodedData
    print("restoredData=",restoredData)
    
    
//    for item in owEvents!
//    {
//      owWebClient.printEventInfo(eventItem: item)
//    }
    //  self.cellDataArray = owEvents!
    //  print("cell data array updated")
    //  print("\nreloading collection view")
    //  DispatchQueue.main.async{self.myEventsCollection.reloadData()}
  })
}

func encodeEventData(owEvents: [Event]) -> String
{
  //encode then assign to user defaults
  let jsonEncoder = JSONEncoder()
  jsonEncoder.outputFormatting = .prettyPrinted
  do
  {
    let jsonData = try jsonEncoder.encode(owEvents)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    print("\nJSON encoding done")
//    print(jsonString)
    
    //jsonString can now be stored in UserDefaults
    return jsonString
  }
  catch let error
  {
    print(error as Any)
  }
  return "dummy string"
}

func decodeEventData(_ encodedEvents: String) -> [Event]
{
  let decoder = JSONDecoder()
  //use do try catch to trap any errors when decoding
  do {
    //set decoder to automatically convert from snake case to camel case
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    //apply decoder to json data to create entire array of To Do items
    let parsedJSON = try decoder.decode([Event].self, from: encodedEvents.data(using: .utf8)!)
//    print(parsedJSON)
    return parsedJSON
  } catch {
    print("decode error")
  }
  return []
}





getEventList()

