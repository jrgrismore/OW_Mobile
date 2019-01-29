import Foundation
import PlaygroundSupport

let host = "www.occultwatcher.net"
let path = "/api/v1/stations/list"
let scheme = "https"
let user = "a"
let password = "a"
struct Event: Codable
{
  var Id: Int
  var EventId: String
  var Name: String?
  var Home: String?
  var CloudCover: Int
}

var parsedJSON = [Event]()

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
  print("data=", String(data: data!, encoding: .utf8)!)
  let owEvents = parseJSONData(jsonData: dataResponse)
  print("owEvents=",owEvents)
  for item in owEvents
  {
    print()
    print("Id =", item.Id)
    print("EventId =", item.EventId)
    print("Name =", item.Name)
    print("Home =", item.Home)
    print("CloudCover =", item.CloudCover)
  }
}
owTask.resume()
