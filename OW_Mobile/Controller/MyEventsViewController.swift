//
//  MyEventsViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 2/3/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class MyEventsViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
  
  @IBOutlet weak var myEventsCollection: UICollectionView!
  
  let reuseIdentifier = "MyEventCell"
  var cellDataArray = [FullEvent?]()
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    print("numberOfItemsInSection=",cellDataArray.count)
    print("cellDataArray=",cellDataArray )
    return cellDataArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyEventsCollectionViewCell
    let remainder = indexPath.row % 10

   fillCellFields(cell: &cell, indexPath: indexPath)
    
    switch remainder {
    case 0:
      cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.673458497)
    case 1:
      cell.backgroundColor = #colorLiteral(red: 1, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
    case 2:
      cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.673458497)
    case 3:
      cell.backgroundColor = #colorLiteral(red: 1, green: 0.8392156863, blue: 0.8392156863, alpha: 1)
    case 4:
      cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.673458497)
    case 5:
      cell.backgroundColor = #colorLiteral(red: 1, green: 0.7529411765, blue: 0.7529411765, alpha: 1)
    case 6:
      cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.673458497)
    case 7:
      cell.backgroundColor = #colorLiteral(red: 1, green: 0.662745098, blue: 0.662745098, alpha: 1)
    case 8:
      cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.673458497)
    case 9:
      cell.backgroundColor = #colorLiteral(red: 1, green: 0.5725490196, blue: 0.5725490196, alpha: 1)
    default:
      cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.673458497)
    }
    //test permanent cell background color
    cell.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
    
    
//    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
//    cell.backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
//    print("red: \(Int(r*255)), green: \(Int(g*255)), blue: \(Int(b*255))")
//    cell.eventTime.text = "\(Int(r*255)), \(Int(g*255)), \(Int(b*255))"

//    switch remainder {
//    case 0:
//      cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.673458497)
//    case 1:
//      cell.backgroundColor = #colorLiteral(red: 0.9781141877, green: 0.9266665578, blue: 0.610206306, alpha: 1)
//    case 2:
//      cell.backgroundColor = #colorLiteral(red: 0.6820191145, green: 1, blue: 0.7397634387, alpha: 1)
//    case 3:
//      cell.backgroundColor = #colorLiteral(red: 0.4048807621, green: 0.6710730195, blue: 0.6450495124, alpha: 1)
//    case 4:
//      cell.backgroundColor = #colorLiteral(red: 0.6820191145, green: 1, blue: 0.7397634387, alpha: 1)
//    case 5:
//      cell.backgroundColor = #colorLiteral(red: 0.435174942, green: 1, blue: 0.8257846236, alpha: 1)
//    case 6:
//      cell.backgroundColor = #colorLiteral(red: 0.5253279805, green: 0.6064991355, blue: 1, alpha: 1)
//    case 7:
//      cell.backgroundColor = #colorLiteral(red: 0.7084195018, green: 0.598293364, blue: 1, alpha: 1)
//    case 8:
//      cell.backgroundColor = #colorLiteral(red: 0.9716592431, green: 0.797021687, blue: 1, alpha: 1)
//    case 9:
//      cell.backgroundColor = #colorLiteral(red: 1, green: 0.7660988569, blue: 0.7564550042, alpha: 1)
//    default:
//      cell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
//
//    }
    //    if remainder == 0
//    {
//      cell.owCellImg.image = UIImage(named: "2004FD30")
//    }
//    else if remainder == 1
//    {
//      cell.owCellImg.image = UIImage(named: "Chikatosh8")
//    }
//    else if remainder == 2
//    {
//      cell.owCellImg.image = UIImage(named: "Schwassmann")
//    }
    
    //populate cell fields
    return cell
  }
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.

    myEventsCollection.backgroundColor = #colorLiteral(red: 0.03605184332, green: 0.2271486223, blue: 0.2422576547, alpha: 1)
//    myEventsCollection.contentSize = CGSize(width: 10_000, height: 10_000)
        
    let cellsInRow = 1
    let cellHeight = 180
    
    if let flowLayout = self.myEventsCollection.collectionViewLayout as? UICollectionViewFlowLayout
    {
      flowLayout.minimumLineSpacing = 15
      flowLayout.minimumInteritemSpacing = 5
      flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
      
      //      let cellWidth = (self.eventsCollection.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
//      var cellWidth = (self.myEventsCollection.bounds.size.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  //retrieve json, parse json, use closure to fill cells
  func updateCellArray()
  {
//    retrieveEventList()
//    cell.objectText =
    let parsedJSON = JsonHandler()
    parsedJSON.retrieveEventList(completion: { (owEvents, error) in
//      for event in owEvents!
//      {
//        self.printFullEventJSON(eventItem: event)
//      }
      //fill the cells
      print("download and parsing complete")
      print("now update cell data array")
      self.cellDataArray = owEvents!
      print("\nreload collection view")
      DispatchQueue.main.async{self.myEventsCollection.reloadData()}
    })
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
  
  func formatEventTime(timeString: String) -> String
  {
    print("timeString=",timeString)
    let eventTimeFormatter = DateFormatter()
    eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
    if let formattedDate = eventTimeFormatter.date(from: timeString)
    {
//      print("formattedDate set")
      eventTimeFormatter.dateFormat = "HH:mm:ss 'UT'"
      return eventTimeFormatter.string(from: formattedDate)
    }
    return timeString
  }
  
  func leadTime(timeString: String) -> String
  {
    let eventTimeFormatter = DateFormatter()
    eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
    if let eventDate = eventTimeFormatter.date(from: timeString)
    {
      print("formattedDate=",eventDate)
      let leadTimeSeconds = Int(eventDate.timeIntervalSinceNow)
      print("leadTimeSeconds=",leadTimeSeconds)
      let leadTimeMinutes = leadTimeSeconds / 60
      print("leadTimeMinutes=",leadTimeMinutes)
      let leadTimeHours = leadTimeMinutes / 60
      print("leadTimeHous=",leadTimeHours)
      let leadTimeDays = leadTimeHours / 24
      print("leadTimeDays=",leadTimeDays)
      return String(format: "in \(leadTimeHours) hrs")
    }
    return timeString
  }
  
  func fillCellFields(cell: inout MyEventsCollectionViewCell, indexPath: IndexPath)
  {
    
    cell.objectText.text = cellDataArray[indexPath.row]!.Object
    cell.starMagText.text = String(format: "%.02f",cellDataArray[indexPath.row]!.StarMag)
    cell.magDropText.text = String(format: "%.02f",cellDataArray[indexPath.row]!.MagDrop)
    cell.maxDurText.text = String(format: "%.02f",cellDataArray[indexPath.row]!.MaxDurSec)
    cell.leadTime.text = leadTime(timeString: cellDataArray[indexPath.row]!.EventTimeUtc)
    cell.eventTime.text = formatEventTime(timeString: cellDataArray[indexPath.row]!.EventTimeUtc)
    cell.timeError.text = String(format: "+/- %.02f",cellDataArray[indexPath.row]!.ErrorInTimeSec)
    cell.cloudText.text = String(format: "%d",cellDataArray[indexPath.row]!.CloudCover)
    cell.tempText.text = String(format: "%d",cellDataArray[indexPath.row]!.TempDegC)
    
    cell.sigmaImg.image =  #imageLiteral(resourceName: "spos_0")
    cell.cloudImg.image = #imageLiteral(resourceName: "cloud_100")
    cell.windStrengthImg.image = #imageLiteral(resourceName: "wind_2a")
    cell.windyImg.image = #imageLiteral(resourceName: "wind_sign")
    cell.tempImg.image = #imageLiteral(resourceName: "term_b")
    cell.starMagImg.image = #imageLiteral(resourceName: "star_y")
    cell.maxDurImg.image = #imageLiteral(resourceName: "max_sign")
    cell.magDropImg.image = #imageLiteral(resourceName: "drop_sign")
   }
  
  @IBAction func refreshEventCells(_ sender: Any)
  {
    updateCellArray()
  }
}
