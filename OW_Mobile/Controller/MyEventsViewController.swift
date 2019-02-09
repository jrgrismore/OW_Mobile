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
  var cellDataArray = [Event?]()
  
  
  // MARK: - View functions
  override func viewDidLoad()
  {
    super.viewDidLoad()
    myEventsCollection.backgroundColor =  _ColorLiteralType(red: 0.03605184332, green: 0.2271486223, blue: 0.2422576547, alpha: 1)
    //set cell size
    let cellsInRow = 1
    let cellHeight = 180
    //set layout attributes
    if let flowLayout = self.myEventsCollection.collectionViewLayout as? UICollectionViewFlowLayout
    {
      flowLayout.minimumLineSpacing = 15
      flowLayout.minimumInteritemSpacing = 5
      flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
      let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  // MARK: - Collection delegate functions
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    print("numberOfItemsInSection=",cellDataArray.count)
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
    return cell
  }
  
  // MARK: - Event data functions
  //retrieve json, parse json, use closure to fill cells
  func updateCellArray()
  {
    let parsedJSON = WebService()
    parsedJSON.retrieveEventList(completion: { (owEvents, error) in
      //fill cells
      print("download and parsing complete")
      //      for item in owEvents!
      //      {
      //        self.printEventInfo(eventItem: item)
      //      }
      self.cellDataArray = owEvents!
      print("cell data array updated")
      print("\nreloading collection view")
      DispatchQueue.main.async{self.myEventsCollection.reloadData()}
    })
  }
  
  func fillCellFields(cell: inout MyEventsCollectionViewCell, indexPath: IndexPath)
  {
    //cell text
    cell.objectText.text = cellDataArray[indexPath.row]!.Object
    cell.starMagText.text = String(format: "%.02f",cellDataArray[indexPath.row]!.StarMag)
    cell.magDropText.text = String(format: "%.02f",cellDataArray[indexPath.row]!.MagDrop)
    cell.maxDurText.text = String(format: "%.02f",cellDataArray[indexPath.row]!.MaxDurSec)
    cell.leadTime.text = leadTime(timeString: cellDataArray[indexPath.row]!.EventTimeUtc)
    cell.eventTime.text = formatEventTime(timeString: cellDataArray[indexPath.row]!.EventTimeUtc)
    cell.timeError.text = String(format: "+/- %.02f",cellDataArray[indexPath.row]!.ErrorInTimeSec)
    cell.cloudText.text = String(format: "%d",cellDataArray[indexPath.row]!.CloudCover)
    cell.tempText.text = String(format: "%d",cellDataArray[indexPath.row]!.TempDegC)
    
    //cell images
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
  
  func formatEventTime(timeString: String) -> String
  {
    let eventTimeFormatter = DateFormatter()
    eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
    if let formattedDate = eventTimeFormatter.date(from: timeString)
    {
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
      let leadTimeSeconds = Int(eventDate.timeIntervalSinceNow)
      let leadTimeMinutes = leadTimeSeconds / 60
      let leadTimeHours = leadTimeMinutes / 60
      let leadTimeDays = leadTimeHours / 24
      return String(format: "in \(leadTimeHours) hrs")
    }
    return timeString
  }
  
  func printEventInfo(eventItem item: Event)
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
