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
  
  static var owmSession = URLSession(configuration: .default)
  
  //create singleton for managing session during app lifetime
  static let shared = OWWebAPI()
  
  let host = "www.occultwatcher.net"
  let myEventsPath = "/api/v1/events/list"
  let eventDetailsPath = "/api/v1/events/"
  let eventWithDetailsPath = "/api/v1/events/details-list"
  let postReportPath = "/api/v1/events/EVENT-ID/STATION-ID/report-observation"
  let scheme = "https"
  
  var parsedJSON = [Event]()
  var parsedEventsWithDetails = [EventWithDetails]()
  var parsedDetails = EventDetails()
  let second: Double = 1000000
  
  // MARK: - OW Web Service Functions
  // MARK: - URL Functions
  func createEventWithDetailsilURL(owSession: URLSession) -> URL
  {
    let user = Credentials.username
    let password = Credentials.password
    let credential = URLCredential(user: user, password: password, persistence: .permanent)
    //create url
    let protectionSpace = URLProtectionSpace(host: host, port: 443, protocol: scheme, realm: "Restricted", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
    URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
    
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.path = eventWithDetailsPath
    urlComponents.user = user
    urlComponents.password = password
    let eventWithDetailsURL = urlComponents.url!
    return eventWithDetailsURL
  }
  
  func createPostReportURL(eventId: String, stationId: Int, owSession: URLSession) -> URL
  {
    let user = Credentials.username
    let password = Credentials.password
    let credential = URLCredential(user: user, password: password, persistence: .permanent)
    //create url
    let protectionSpace = URLProtectionSpace(host: host, port: 443, protocol: scheme, realm: "Restricted", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
    URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
    
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.path = "/api/v1/events/" + eventId + "/" + String(stationId) + "/report-observation"
    urlComponents.user = user
    urlComponents.password = password
    
    let postReportURL = urlComponents.url!
    return postReportURL
  }
  
  func createMyEventsURL(owSession: URLSession) -> URL
  {
    let user = Credentials.username
    let password = Credentials.password
    let credential = URLCredential(user: user, password: password, persistence: .permanent)
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
    return owURL
  }
  
  func createEventDetailURL(owSession: URLSession, eventID: String) -> URL
  {
    let user = Credentials.username
    let password = Credentials.password
    let credential = URLCredential(user: user, password: password, persistence: .permanent)
    //create url
    let protectionSpace = URLProtectionSpace(host: host, port: 443, protocol: scheme, realm: "Restricted", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
    URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
    
    var urlComponents = URLComponents()
    urlComponents.scheme = scheme
    urlComponents.host = host
    urlComponents.path = eventDetailsPath + eventID
    urlComponents.user = user
    urlComponents.password = password
    let detailURL = urlComponents.url!
    return detailURL
  }
  
  // MARK: - Retrieval Functions
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
        //        print("\n*******Error:", error as Any)
        self.delegate?.webLogTextDidChange(text: "Error Trying to Access OW Server!")
        usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
        completion(nil,error)
        return
      }
      print("Data Retrieved")
      self.delegate?.webLogTextDidChange(text: "Data Retrieved")
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
      let eventWithDetail = self.parseEventsWithDetails(jsonData: dataResponse)
      
      //      print("eventWithDetails.count=",eventWithDetail.count)
      self.delegate?.webLogTextDidChange(text: "Event List count = \(eventWithDetail.count)")
      usleep(useconds_t(1.0 * 1000000)) //will sleep for 1.0 seconds)
      completion(eventWithDetail,nil)
    }
    owTask.resume()
  }
  
  func retrieveEventList( completion: @escaping ([Event]?, Error?) -> Void)
  {
    delegate?.webLogTextDidChange(text: "Connecting to OW")
    let config = URLSessionConfiguration.default
    OWWebAPI.owSession = URLSession(configuration: config)
    let owURL = createMyEventsURL(owSession: OWWebAPI.owSession)
    let owTask = OWWebAPI.owSession.dataTask(with: owURL)
    {
      (data,response,error) in
      guard let dataResponse = data, error == nil
        else
      {
        //        print("\n*******Error:", error as Any)
        self.delegate?.webLogTextDidChange(text: "\n*******Error:" + error!.localizedDescription)
        usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
        return
      }
      let myEvents = self.parseEventData(jsonData: dataResponse)
      self.delegate?.webLogTextDidChange(text: "Event List count = \(myEvents.count)")
      usleep(useconds_t(1.0 * 1000000)) //will sleep for 0.5 seconds)
      completion(myEvents,nil)
    }
    owTask.resume()
  }
  
  func retrieveEventDetails(eventID: String,  completion: @escaping (EventDetails?, Error?) -> Void)
  {
    delegate?.webLogTextDidChange(text: "Connecting to OW")
    let config = URLSessionConfiguration.default
    let owDetailURL = createEventDetailURL(owSession: OWWebAPI.owSession, eventID: eventID)
    let owDetailTask = OWWebAPI.owSession.dataTask(with: owDetailURL)
    {
      (data,response,error) in
      guard let dataResponse = data, error == nil
        else
      {
        //        print("\n*******Error:", error as Any)
        self.delegate?.webLogTextDidChange(text: "\n*******Error:" + error!.localizedDescription)
        usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
        return
      }
      let detailEvents = self.parseDetailData(jsonData: dataResponse)
      completion(detailEvents,nil)
    }
    owDetailTask.resume()
  }
  
  // MARK: - JSON Parsing Functions
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
    } catch let error {
      //      print(error as Any)
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
    } catch let error {
      //      print(error as Any)
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
    } catch let error {
      //      print(error as Any)
    }
    return parsedDetails
  }
  
  // MARK: - Data Save and Load Functions
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
  
  func saveEventsWithDetails(_ eventsWithDetails: [EventWithDetails])
  {
    let data = eventsWithDetails.map { try? JSONEncoder().encode($0) }
    UserDefaults.standard.set(data, forKey: UDKeys.eventsWithDetails)
  }
  
  func loadEventsWithDetails() -> [EventWithDetails]
  {
    guard let encodedData = UserDefaults.standard.array(forKey: UDKeys.eventsWithDetails) as? [Data] else {
      return []
    }
    
    return encodedData.map { try! JSONDecoder().decode(EventWithDetails.self, from: $0) }
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
  
  // MARK: - Report Posting Functions
  func postReport(eventId: String, stationId: Int, reportData: ObservationReport, completion: @escaping (Data?, Error?) -> () )
  {
    let postReportURL = createPostReportURL(eventId: eventId, stationId: stationId, owSession: OWWebAPI.owmSession)
    var request = URLRequest(url: postReportURL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")   //added on advice from Hristo
    
    //json encode data
    let jsonPostData = try! JSONEncoder().encode(reportData)
    let jsonPostString = String(data: jsonPostData, encoding: .utf8)
    
    let owmTask = OWWebAPI.owmSession.uploadTask(with: request, from: jsonPostData)
    {
      (data,response,error) in
      if let error = error {
        //        print("error: \(error)")
      } else {
        if let response = response as? HTTPURLResponse {
          //          print("statusCode: \(response.statusCode)")
        }
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
          //          print("data: \(dataString)")
        }
      }
      completion(data,error)
    }
    owmTask.resume()
  }
  
  // MARK: - Cookie Functions
  func getCookieData()
  {
    let cookieStorage = HTTPCookieStorage.shared
    let cookies = cookieStorage.cookies
    for cookie in cookies as! [HTTPCookie]
    {
    }
  }
  
  func deleteCookies()
  {
    let cookieStorage = HTTPCookieStorage.shared
    let cookies = cookieStorage.cookies
    for cookie in cookies as! [HTTPCookie]
    {
      HTTPCookieStorage.shared.deleteCookie(cookie)
    }
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
