import Foundation
import PlaygroundSupport

let user = "a"
let password = "a"
let loginString = String(format: "%@:%@", user,password)
print("loginString=",loginString)
let loginData = loginString.data(using: String.Encoding.utf8)!
let base64LoginString = loginData.base64EncodedString()
print("base64LoginString =",base64LoginString)

//create url
var urlComponents = URLComponents()
urlComponents.scheme = "https"
urlComponents.host = "www.occultwatcher.net"
urlComponents.path = "/api/v1/stations/list"
print(urlComponents.url!)
//? is this the newest way ? urlSesssion ?
var owRequest = URLRequest(url: urlComponents.url!)
owRequest.httpMethod = "POST"
owRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
let urlCommecction = NSURLConnection(request:owRequest, delegate:self)
