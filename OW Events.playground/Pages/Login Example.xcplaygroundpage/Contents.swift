import Foundation
import PlaygroundSupport

import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let credential = URLCredential(user: "username@gmail.com", password: "password", persistence: URLCredential.Persistence.forSession)
print("credential=",credential)
let protectionSpace = URLProtectionSpace(host: "example.com", port: 443, protocol: "https", realm: "Restricted", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
print("protectionSpace=",protectionSpace)
URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)

let config = URLSessionConfiguration.default
print("config=",config)
let session = URLSession(configuration: config)
print("session=",session)

let url = URL(string: "https://example.com/api/v1/records.json")!

let task = session.dataTask(with: url) { (data, response, error) in
  guard error == nil else {
    print(error?.localizedDescription ?? "")
    return
  }
  
  print("\n\n",String(data: data!, encoding: .utf8))
}

task.resume()
