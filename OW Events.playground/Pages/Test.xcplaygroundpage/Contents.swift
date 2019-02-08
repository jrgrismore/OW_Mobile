
import Foundation
import PlaygroundSupport

//let host = "www.occultwatcher.net"
//let path = "/api/v1/stations/list"
//let scheme = "https"
//let user = "a"
//let password = "a"
let host = "www.occultwatcher.net"
let path = "/api/v1/events/list"
let scheme = "https"
let user = "Alex Pratt"
let password = "qwerty123456"

let credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
let protectionSpace = URLProtectionSpace(host: host, port: 443, protocol: scheme, realm: "Restricted", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)

//    owSession = URLSession(configuration: config)
let config = URLSessionConfiguration.default
print("config=",config)
let owSession = URLSession(configuration: config)
print("owSession=",owSession)

var urlComponents = URLComponents()
urlComponents.scheme = scheme
urlComponents.host = host
urlComponents.path = path
urlComponents.user = user
urlComponents.password = password

let owURL = urlComponents.url!
print("owURL = ",owURL)

print("...owTask")
let owTask = owSession.dataTask(with: owURL) {
  (data,response,error) in
  guard  error == nil
    else
  {
    print("\n*******Error:", error as Any)
    return
  }
  print("data=", String(data: data!, encoding: .utf8)!)
  //      let owEvents = self.parseJSONData(jsonData: data!)
  //      print("owEvents=",owEvents)
  //      for item in owEvents
  //      {
  //        print()
  //        print("Id =", item.Id)
  //        print("EventId =", item.EventId)
  //        print("Name =", item.Name)
  //        print("Home =", item.Home)
  //        print("CloudCover =", item.CloudCover)
  
  //        print()
  //        print("Id =", item.Id)
  //        print("Object =", item.Object)
  //        print("StarMag =", item.StarMag)
  //        print("MagDrop =", item.MagDrop)
  //        print("MaxDurSec =", item.MaxDurSec)
  //        print("EventTimeUtc =", item.EventTimeUtc)
  //        print("ErrorInTimeSec =", item.ErrorInTimeSec)
  //        print("WhetherInfoAvailable =", item.WhetherInfoAvailable)
  //        print("CloudCover =", item.CloudCover)
  //        print("Wind =", item.Wind)
  //        print("TempDegC =", item.TempDegC)
  //        print("HighCloud =", item.HighCloud)
  //        print("BestStationPos =", item.BestStationPos)
  //      }
}
print("...owTask.resume()")
owTask.resume()
