//
//  WebService.swift
//  OW_Mobile
//
//  Created by John Grismore on 2/5/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import Foundation

//UserDefaults Keys Enum
struct UDKeys
{
  static let myEventList = "myEventList"
}

//delegate protocol
protocol webServiceDelegate: class
{
  func webLogTextDidChange(text: String)
}

//Event structure matching JSON keys
struct Event: Codable
{
  var Id: String
  var Object: String
  var StarMag: Double
  var MagDrop: Double
  var MaxDurSec: Double
  var EventTimeUtc: String
  var ErrorInTimeSec: Double
  var WeatherInfoAvailable: Bool   //weather info available
  var CloudCover: Int
  var Wind: Int
  var TempDegC: Int
  var HighCloud: Bool
  var BestStationPos: Int
  var StarColour: Int
}

struct MyEvents: Codable
{
  var events: [Event]
}

let config = URLSessionConfiguration.default
var owSession = URLSession(configuration: config)

class WebService: NSObject
{
  weak var delegate: webServiceDelegate?
  
  let host = "www.occultwatcher.net"
  let path = "/api/v1/events/list"
  let scheme = "https"
//  let user = "Alex Pratt"
//  let password = "qwerty123456"
//    let user = "JohnG"
//  let password = "qwerty123456"
//    let password = "dei77mos"
  
  var parsedJSON = [Event]()
  let second: Double = 1000000

  // MARK: - OW Web Service Functions
  func creatURL(owSession: URLSession) -> URL
  {
     let user = Credentials.username
    let password = Credentials.password
   //let credential = URLCredential(user: user, password: password, persistence: .synchronizable)  for use with iCloud across devices
    let credential = URLCredential(user: user, password: password, persistence: .permanent)
//    let credential = URLCredential(user: user, password: password, persistence: .forSession)
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
//    print("owURL = ",owURL)
    return owURL
  }
  
  func retrieveEventList(completion: @escaping ([Event]?, Error?) -> Void)
  {
    delegate?.webLogTextDidChange(text: "Connecting to OW")
    let config = URLSessionConfiguration.default
//    let owSession = URLSession(configuration: config)
    owSession = URLSession(configuration: config)
    let owURL = creatURL(owSession: owSession)
    print("owURL=",owURL)
//    delegate?.webLogTextDidChange(text: "Connecting to " + owURL.description)

//    delegate?.webLogTextDidChange(text: "Begin...")
 //   deleteCookie()  this was just here as a test
    let owTask = owSession.dataTask(with: owURL)
    {
      (data,response,error) in
      guard let dataResponse = data, error == nil
        else
      {
        print("\n*******Error:", error as Any)
        self.delegate?.webLogTextDidChange(text: "\n*******Error:" + error!.localizedDescription)
        usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
        return
      }
      print("data retrieved")
      self.delegate?.webLogTextDidChange(text: "Data Retrieved")
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
      let myEvents = self.parseEventData(jsonData: dataResponse)
      print("myEvents count=", myEvents.count)
      self.delegate?.webLogTextDidChange(text: "myEvents count= \(myEvents.count)")
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
      completion(myEvents,nil)
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
      //      testUserDefaults(parsedJSON)
      
    } catch let error {
      print(error as Any)
    }
    return parsedJSON
  }
  
  func loadEvents() -> [Event]
  {
    guard let encodedData = UserDefaults.standard.array(forKey: UDKeys.myEventList) as? [Data] else {
      return []
    }
    
    return encodedData.map { try! JSONDecoder().decode(Event.self, from: $0) }
  }
  
  func saveEvents(_ events: [Event])
  {
    let data = events.map { try? JSONEncoder().encode($0) }
    UserDefaults.standard.set(data, forKey: UDKeys.myEventList)
  }
  
  func getCookieData()
  {
    let cookieStorage = HTTPCookieStorage.shared
    let cookies = cookieStorage.cookies
    print("cookies.count=",cookies?.count)
    for cookie in cookies as! [HTTPCookie]
    {
      print("cookie.name=",cookie.name)
      print("cookie.description=",cookie.description)
    }
  }
  
  func deleteCookie()
  {
    let cookieStorage = HTTPCookieStorage.shared
    let cookies = cookieStorage.cookies
    print("cookies.count=",cookies?.count)
    for cookie in cookies as! [HTTPCookie]
    {
      print("cookie.name=",cookie.name)
      print("cookie.description=",cookie.description)
      HTTPCookieStorage.shared.deleteCookie(cookie)
      print("cookie deleted")
    }
  }

}

extension WebService: URLSessionDelegate, URLSessionTaskDelegate
{
  //URLSession delegates
  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didSendBodyData bytesSent: Int64,
    totalBytesSent: Int64,
    totalBytesExpectedToSend: Int64)
  {
    print("didSendBodyData")
    //    print("bytesSent=",bytesSent)
    //    print("totalBytesSent=",totalBytesSent)
    //    print("totalBytesExpectedToSend=",totalBytesExpectedToSend)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
  {
    print("didCompleteWithError")
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
  {
    print("didReceive data")
  }
  
  
}
