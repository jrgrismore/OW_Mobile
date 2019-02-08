//
//  JsonHandler.swift
//  OW_Mobile
//
//  Created by John Grismore on 2/5/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import Foundation

struct TestEvent: Codable
{
  var Id: Int
  var EventId: String
  var Name: String?
  var Home: String?
  var CloudCover: Int
}

struct FullEvent: Codable
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
typealias Event = FullEvent

class JsonHandler: NSObject
{
  let host = "www.occultwatcher.net"
  let path = "/api/v1/events/list"
  let scheme = "https"
//  let user = "Alex Pratt"
  let user = "JohnG"
  let password = "qwerty123456"
  
  var parsedJSON = [Event]()
  
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
  
  func downloadJSON(completion: @escaping ([Event]?, Error?) -> Void )
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
      let owEvents = self.parseJSONData(jsonData: dataResponse)
      completion(owEvents,nil)
    }
    print("...owTask.resume()")
    owTask.resume()
  }
  
  //parse json data passed into function
  func parseJSONData(jsonData: Data) -> [Event]
  {
    //create decoder instance
    let decoder = JSONDecoder()
    //use do try catch to trap any errors when decoding
    do {
      //set decoder to automatically convert from snake case to camel case
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      //apply decoder to json data to create entire array of To Do items
      parsedJSON = try decoder.decode([Event].self, from: jsonData)
    } catch let error {
      print(error as Any)
    }
    return parsedJSON
  }
  
  func printFullEventJSON(eventItem item: Event)
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
