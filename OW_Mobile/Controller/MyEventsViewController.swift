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
  let parsedJSON = WebService()
  
  @IBAction func switchToLogin(_ sender: Any)
  {
    tabBarController?.selectedIndex = 1
  }
  
  // MARK: - View functions
  override func viewWillLayoutSubviews()
  {
   super.viewWillLayoutSubviews()
    myEventsCollection.collectionViewLayout.invalidateLayout()
    //set cell size
    let cellsInRow = 1
    let cellHeight = 180
    //set layout attributes
    if let flowLayout = self.myEventsCollection.collectionViewLayout as? UICollectionViewFlowLayout
    {
      print("UIScreen.main.bounds.width=",UIScreen.main.bounds.width)
      print("myEventsCollection.bounds.width=",myEventsCollection.bounds.width)
      flowLayout.minimumLineSpacing = 5
      flowLayout.minimumInteritemSpacing = 3
      flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 7, right: 5)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      print("totalHInsets=",totalHInsets)
      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
      print("totalInteritemSpace=",totalInteritemSpace)
//      let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
//      let cellWidth = (myEventsCollection.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
       //      print("cellWidth=",cellWidth)
      //? is this the right way to do this ?
      let cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    myEventsCollection.backgroundColor =  _ColorLiteralType(red: 0.03605184332, green: 0.2271486223, blue: 0.2422576547, alpha: 1)
    cellDataArray = self.parsedJSON.load()
    //test
//    cellDataArray = []
    
    DispatchQueue.main.async{self.myEventsCollection.reloadData()}
    if cellDataArray.count == 0
    {
      updateCellArray()
    }
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    //set cell size
    let cellsInRow = 1
    let cellHeight = 180
    //set layout attributes
    if let flowLayout = self.myEventsCollection.collectionViewLayout as? UICollectionViewFlowLayout
    {
      print("UIScreen.main.bounds.width=",UIScreen.main.bounds.width)
      print("myEventsCollection.bounds.width=",myEventsCollection.bounds.width)
      flowLayout.minimumLineSpacing = 5
      flowLayout.minimumInteritemSpacing = 3
      flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 7, right: 5)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      print("totalHInsets=",totalHInsets)
      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
      print("totalInteritemSpace=",totalInteritemSpace)
      let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
//            let cellWidth = (myEventsCollection.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      //      print("cellWidth=",cellWidth)
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }

  }
  
  // MARK: - Event data functions
  //retrieve json, parse json, use closure to fill cells
  func updateCellArray()
  {
    //    let parsedJSON = WebService()
    parsedJSON.retrieveEventList(completion: { (myEvents, error) in
      //fill cells
      print("download and parsing complete")
//            for item in myEvents!
//            {
//              self.printEventInfo(eventItem: item)
//            }
      self.parsedJSON.save(myEvents!)
      self.cellDataArray = myEvents!
      print("cell data array updated")
      print("\nreloading collection view")
      DispatchQueue.main.async{self.myEventsCollection.reloadData()}
    })
  }
  
  func fillCellFields(cell: inout MyEventsCollectionViewCell, indexPath: IndexPath)
  {
    //cell text
    cell.objectText.text = cellDataArray[indexPath.row]!.Object
    let calloutFont =   UIFont.preferredFont(forTextStyle: .callout)
    let captionFont =   UIFont.preferredFont(forTextStyle: .caption1)
    //create "m" superscript for star magnitude and magnitude drop
    let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,
                                                                       NSAttributedString.Key.baselineOffset: 5])
    let starMagStr = String(format: "%.01f",cellDataArray[indexPath.row]!.StarMag)
    let starMagAttrStr = NSMutableAttributedString(string:starMagStr, attributes:[NSAttributedString.Key.font : calloutFont])
    starMagAttrStr.append(magAttrStr)
    cell.starMagText.attributedText = starMagAttrStr
    if cellDataArray[indexPath.row]!.MagDrop >= 0.2
    {
      let magDropStr = String(format: "%.01f",cellDataArray[indexPath.row]!.MagDrop)
      let magDropAttrStr = NSMutableAttributedString(string:magDropStr, attributes:[NSAttributedString.Key.font : calloutFont])
      magDropAttrStr.append(magAttrStr)
      cell.magDropText.attributedText = magDropAttrStr
    }
    else
    {
      let magDropStr = String(format: "%.02f",cellDataArray[indexPath.row]!.MagDrop)
      let magDropAttrStr = NSMutableAttributedString(string:magDropStr, attributes:[NSAttributedString.Key.font : calloutFont])
      magDropAttrStr.append(magAttrStr)
      cell.magDropText.attributedText = magDropAttrStr
    }
    cell.maxDurText.text = String(format: "%.01f sec",cellDataArray[indexPath.row]!.MaxDurSec)
    cell.leadTime.text = leadTime(timeString: cellDataArray[indexPath.row]!.EventTimeUtc)
    cell.eventTime.text = formatEventTime(timeString: cellDataArray[indexPath.row]!.EventTimeUtc)
    //set time error field
    let timeError = cellDataArray[indexPath.row]!.ErrorInTimeSec
    if timeError > 90
    {
      let errorInMin = timeError / 60
      cell.timeError.text = String(format: "+/- %.01f min",errorInMin)
    } else {
      if timeError == -1
      {
        cell.timeError.text = "N/A"
      } else {
        cell.timeError.text = String(format: "+/- %.f sec",timeError)
      }
    }
    //cell images
    cell.sigmaImg.image =  #imageLiteral(resourceName: "spos_0")
    cell.starMagImg.image = #imageLiteral(resourceName: "star_y")
    cell.maxDurImg.image = #imageLiteral(resourceName: "max_sign")
    cell.magDropImg.image = #imageLiteral(resourceName: "drop_sign")
    //display weather info if forecast available, no display if no forecast
    if cellDataArray[indexPath.row]!.WeatherInfoAvailable
    {
      //set weather images to appropriate image
      switch cellDataArray[indexPath.row]!.CloudCover
      {
      case 0...9:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_0")
      case 10...19:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_10")
      case 20...29:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_20")
      case 30...39:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_30")
      case 40...49:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_40.png")
      case 50...59:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_50.png")
      case 60...69:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_60.png")
      case 70...79:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_70.png")
      case 80...89:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_80.png")
      case 90...100:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_90.png")
      default:
        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_100.png")
      }
      cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_2a")
      cell.windyImg.image =  #imageLiteral(resourceName: "wind_sign")
      cell.tempImg.image =  #imageLiteral(resourceName: "term_b")
      //set weather text to appropriate text
      cell.cloudText.text = String(format: "%d%%",cellDataArray[indexPath.row]!.CloudCover)
      cell.tempText.text = String(format: "%d°",cellDataArray[indexPath.row]!.TempDegC)
    } else {
      //set weather images and text empty because no forecast info is available
      cell.cloudImg.image =  nil
      cell.windStrengthImg.image =  nil
      cell.windyImg.image =  nil
      cell.tempImg.image =  nil
      cell.cloudText.text = ""
      cell.tempText.text = ""
    }
    
    
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
      eventTimeFormatter.dateFormat = "dd MMM, HH:mm:ss 'UT'"
      return eventTimeFormatter.string(from: formattedDate)
    }
    return timeString
  }
  
  func leadTime(timeString: String) -> String
  {
    var leadTimeString = ""
    let eventTimeFormatter = DateFormatter()
    eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
    if let eventDate = eventTimeFormatter.date(from: timeString)
    {
      let leadTimeSeconds = Int(eventDate.timeIntervalSinceNow)
      let leadTimeMinutes = leadTimeSeconds / 60
      let leadTimeHours = leadTimeMinutes / 60
      let leadTimeDays = leadTimeHours / 24
      
      if leadTimeMinutes > 0
      {
        if leadTimeMinutes < 90
        {
          leadTimeString = String(format: "in \(leadTimeMinutes) min")
        }
        else if leadTimeHours < 48
        {
          leadTimeString = String(format: "in \(leadTimeHours) hours")
        }
        else
        {
          leadTimeString = String(format: "in \(leadTimeDays) days")
        }
      }
      return leadTimeString
    }
    return leadTimeString
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
    print("WeatherInfoAvailable =", item.WeatherInfoAvailable)
    print("CloudCover =", item.CloudCover)
    print("Wind =", item.Wind)
    print("TempDegC =", item.TempDegC)
    print("HighCloud =", item.HighCloud)
    print("BestStationPos =", item.BestStationPos)
    print("StarColour =",item.StarColour)
  }
  
}

extension MyEventsViewController
{
  // MARK: - Collection delegate functions
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    print("numberOfItemsInSection=",cellDataArray.count)
    return cellDataArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyEventsCollectionViewCell
    //set permanent cell background color to 235_255_235_67
    cell.backgroundColor = #colorLiteral(red: 0.9215686275, green: 1, blue: 0.9215686275, alpha: 0.67)
    fillCellFields(cell: &cell, indexPath: indexPath)
    return cell
  }
  
}
