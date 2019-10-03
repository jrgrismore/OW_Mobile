//
//  OWWebAPI.swift
//  OW_Mobile
//
//  Created by John Grismore on 2/5/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import Foundation


//delegate protocol
protocol OWWebAPIDelegate: class
{
  func webLogTextDidChange(text: String)
}

class OWWebAPI: NSObject
{
  weak var delegate: OWWebAPIDelegate?
  static let owConfig = URLSessionConfiguration.default
  static var owSession = URLSession(configuration: owConfig)
  
  static let owDetailConfig = URLSessionConfiguration.default
  static var owDetailSession = URLSession(configuration: owDetailConfig)

  //create singleton for managing session during app lifetime
  static let shared = OWWebAPI()
 
//  private init() {}
  
  let host = "www.occultwatcher.net"
  let myEventsPath = "/api/v1/events/list"
  let eventDetailsPath = "/api/v1/events/"
  let eventWithDetailsPath = "/api/v1/events/details-list"
  let scheme = "https"
//  let user = "Alex Pratt"
//  let password = "qwerty123456"
//    let user = "JohnG"
//  let password = "qwerty123456"
//    let password = "dei77mos"
  
  var parsedJSON = [Event]()
  var parsedEventsWithDetails = [EventWithDetails]()
  var parsedDetails = EventDetails()
  let second: Double = 1000000

  // MARK: - OW Web Service Functions
    
    func createEventWithDetailsilURL(owSession: URLSession) -> URL
    {
      let user = Credentials.username
      let password = Credentials.password
      let credential = URLCredential(user: user, password: password, persistence: .permanent)
      //    let credential = URLCredential(user: user, password: password, persistence: .forSession)
      //create url
      let protectionSpace = URLProtectionSpace(host: host, port: 443, protocol: scheme, realm: "Restricted", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
      URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)

      var urlComponents = URLComponents()
      urlComponents.scheme = scheme
      urlComponents.host = host
      urlComponents.path = eventWithDetailsPath
      urlComponents.user = user
      urlComponents.password = password
  //    print("credential = ",credential.user,"   ",credential.password)
  //    print("urlComponents=",urlComponents)
      
      let eventWithDetailsURL = urlComponents.url!
  //   print("create > detailURL = ",detailURL)
      return eventWithDetailsURL
    }
  
    func retrieveEventsWithDetails( completion: @escaping ([EventWithDetails]?, Error?) -> Void)
    {
      delegate?.webLogTextDidChange(text: "Connecting to OW")
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
      let config = URLSessionConfiguration.default
      OWWebAPI.owSession = URLSession(configuration: config)
      let owURL = createEventWithDetailsilURL(owSession: OWWebAPI.owSession)
      let owTask = OWWebAPI.owSession.dataTask(with: owURL)
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
        self.delegate?.webLogTextDidChange(text: "Data Retrieved")
        usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
        let eventWithDetail = self.parseEventsWithDetails(jsonData: dataResponse)

        self.delegate?.webLogTextDidChange(text: "eventWithDetails List count = \(eventWithDetail.count)")
        usleep(useconds_t(1.0 * 1000000)) //will sleep for 1.0 seconds)
        completion(eventWithDetail,nil)
      }
      owTask.resume()
    }

  func createMyEventsURL(owSession: URLSession) -> URL
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
    urlComponents.path = myEventsPath
    urlComponents.user = user
    urlComponents.password = password
    
    let owURL = urlComponents.url!
    //    print("owURL = ",owURL)
    return owURL
  }
    
    func createEventDetailURL(owSession: URLSession, eventID: String) -> URL
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
      urlComponents.path = eventDetailsPath + eventID
      urlComponents.user = user
      urlComponents.password = password
  //    print("credential = ",credential.user,"   ",credential.password)
  //    print("urlComponents=",urlComponents)
      
      let detailURL = urlComponents.url!
  //   print("create > detailURL = ",detailURL)
      return detailURL
    }

  func retrieveEventList( completion: @escaping ([Event]?, Error?) -> Void)
  {
    delegate?.webLogTextDidChange(text: "Connecting to OW")
    let config = URLSessionConfiguration.default
//    let owSession = URLSession(configuration: config)
    OWWebAPI.owSession = URLSession(configuration: config)
    let owURL = createMyEventsURL(owSession: OWWebAPI.owSession)
//    print("owURL=",owURL)
//    delegate?.webLogTextDidChange(text: "Connecting to " + owURL.description)

//    delegate?.webLogTextDidChange(text: "Begin...")
 //   deleteCookie()  this was just here as a test
    let owTask = OWWebAPI.owSession.dataTask(with: owURL)
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
//      print("data retrieved")
//      self.delegate?.webLogTextDidChange(text: "Data Retrieved")
//      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
      let myEvents = self.parseEventData(jsonData: dataResponse)
//      print("myEvents count=", myEvents.count)
//      print("myEvents=",myEvents)

      self.delegate?.webLogTextDidChange(text: "Event List count = \(myEvents.count)")
      usleep(useconds_t(1.0 * 1000000)) //will sleep for 0.5 seconds)
      completion(myEvents,nil)
    }
//    print("...owTask.resume()")
    owTask.resume()
  }
  
  func parseEventsWithDetails(jsonData: Data) -> [EventWithDetails]
  {
    //create decoder instance
    let decoder = JSONDecoder()
    //use do try catch to trap any errors when decoding
    do {
      //set decoder to automatically convert from snake case to camel case
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      //apply decoder to json data to create entire array of To Do items
      parsedEventsWithDetails = try decoder.decode([EventWithDetails].self, from: jsonData)
      //sort by event data/time (earliest first)
      parsedJSON.sort(by: { $0.EventTimeUtc! < $1.EventTimeUtc! })
      //test
      //      testUserDefaults(parsedJSON)
      
    } catch let error {
      print(error as Any)
    }
    return parsedEventsWithDetails
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
      parsedJSON.sort(by: { $0.EventTimeUtc! < $1.EventTimeUtc! })
      //test
      //      testUserDefaults(parsedJSON)
      
    } catch let error {
      print(error as Any)
    }
    return parsedJSON
  }

  func parseDetailData(jsonData: Data) -> EventDetails
  {
    //create decoder instance
    let decoder = JSONDecoder()
    //use do try catch to trap any errors when decoding
    do {
      //set decoder to automatically convert from snake case to camel case
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      //apply decoder to json data to create entire array of To Do items
      parsedDetails = try decoder.decode(EventDetails.self, from: jsonData)
      //sort by event data/time (earliest first)
//      parsedJSON.sort(by: { $0.EventTimeUtc! < $1.EventTimeUtc! })
      //test
      //      testUserDefaults(parsedJSON)
      
    } catch let error {
      print(error as Any)
    }
    return parsedDetails
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
  
  
  func loadDetails() -> [EventDetails]
  {
    guard let encodedData = UserDefaults.standard.array(forKey: UDKeys.myEventDetails) as? [Data] else {
      return []
    }
    return encodedData.map { try! JSONDecoder().decode(EventDetails.self, from: $0) }
  }

  func saveDetails(_ eventListDetails: [EventDetails])
  {
    let data = eventListDetails.map { try? JSONEncoder().encode($0) }
    UserDefaults.standard.set(data, forKey: UDKeys.myEventDetails)
  }
 
  
  func getCookieData()
  {
    let cookieStorage = HTTPCookieStorage.shared
    let cookies = cookieStorage.cookies
//    print("cookies.count=",cookies?.count)
    for cookie in cookies as! [HTTPCookie]
    {
//      print("cookie.name=",cookie.name)
//      print("cookie.description=",cookie.description)
    }
  }
  
  func deleteCookies()
  {
    let cookieStorage = HTTPCookieStorage.shared
    let cookies = cookieStorage.cookies
//    print("cookies.count=",cookies?.count)
    for cookie in cookies as! [HTTPCookie]
    {
//      print("cookie.name=",cookie.name)
//      print("cookie.description=",cookie.description)
      HTTPCookieStorage.shared.deleteCookie(cookie)
//      print("cookie deleted")
    }
  }
 
  
  
  func retrieveEventDetails(eventID: String,  completion: @escaping (EventDetails?, Error?) -> Void)
  {
    delegate?.webLogTextDidChange(text: "Connecting to OW")
     let config = URLSessionConfiguration.default
    //    let owSession = URLSession(configuration: config)
    let owDetailURL = createEventDetailURL(owSession: OWWebAPI.owSession, eventID: eventID)
//    OWWebAPI.owSession = URLSession(configuration: config)
//     print("owDetailURL=",owDetailURL)
    
    let owDetailTask = OWWebAPI.owSession.dataTask(with: owDetailURL)
    {
      (data,response,error) in
//      print("data =",data)
      guard let dataResponse = data, error == nil
        else
      {
        print("\n*******Error:", error as Any)
        self.delegate?.webLogTextDidChange(text: "\n*******Error:" + error!.localizedDescription)
        usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
        return
      }
//      print("data retrieved")
//      self.delegate?.webLogTextDidChange(text: "Data Retrieved")
//      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
      
//      print("dataResponse=",String(decoding: dataResponse, as: UTF8.self))
      
      let detailEvents = self.parseDetailData(jsonData: dataResponse)
//      print("detailEvents=", detailEvents)
//      self.delegate?.webLogTextDidChange(text: "detailEvents count= \(detailEvents.count)")
//      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
      completion(detailEvents,nil)
    }
//    print("...owDetailTask.resume()")
    owDetailTask.resume()
  }
}

extension OWWebAPI: URLSessionDelegate, URLSessionTaskDelegate
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
