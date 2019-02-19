import Foundation

struct Event: Codable
{
  var Id: String
  var Title: String
  var Star: String
  var Mag: Double
}

var parsedJSON = [Event]()
var urlComponents = URLComponents()
urlComponents.scheme = "https"
urlComponents.host = "www.occultwatcher.net"
urlComponents.path = "/api/v1/events/list"
print(urlComponents.url!)
var owWebSession = URLSession.shared

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


let owTask = owWebSession.dataTask(with: urlComponents.url!)
{
  (data,response,error) in
  guard let dataResponse = data, error == nil
    else
  {
    print("Error:", error as Any)
    return
  }
  print("data=",String(data: data!, encoding: .utf8) )
  print("\n\nin task trailing closure after parse function")
  let owEvents = parseJSONData(jsonData: dataResponse)
  print("owEvents=",owEvents)
  for item in owEvents
  {
    print()
    print("Id =", item.Id)
    print("Title =", item.Title)
    print("Star =", item.Star)
    print("Mag =", item.Mag)
  }
}
owTask.resume()
