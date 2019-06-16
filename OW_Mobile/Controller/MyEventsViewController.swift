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
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var spinnerLbl: UILabel!
  @IBOutlet weak var spinnerView: UIView!
  
  let reuseIdentifier = "MyEventCell"
  var cellDataArray = [Event?]()
  var cellStringArray = [EventStrings]()
//  let OWWebAPI.shared = OWWebAPI.shared
  
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
//      print("UIScreen.main.bounds.width=",UIScreen.main.bounds.width)
//      print("myEventsCollection.bounds.width=",myEventsCollection.bounds.width)
      flowLayout.minimumLineSpacing = 5
      flowLayout.minimumInteritemSpacing = 3
      flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 7, right: 5)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
//      print("totalHInsets=",totalHInsets)      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
//      print("totalInteritemSpace=",totalInteritemSpace)
//      let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
//      let cellWidth = (myEventsCollection.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
       //      print("cellWidth=",cellWidth)
      //? is this the right way to do this ?
//      let cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width - totalHInsets
      //?does this work for all screen sizes and orientations?
      let cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width - totalHInsets
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    OWWebAPI.shared.delegate = self
    myEventsCollection.backgroundColor =  _ColorLiteralType(red: 0.03605184332, green: 0.2271486223, blue: 0.2422576547, alpha: 1)
    cellDataArray = OWWebAPI.shared.loadEvents()
    //test
//    cellDataArray = []
    
    self.spinnerView.layer.cornerRadius = 20
    
    DispatchQueue.main.async{self.myEventsCollection.reloadData()}
    if cellDataArray.count == 0
    {
      updateCellArray()
    }
    
   }
  
  override func viewWillAppear(_ animated: Bool)
  {
    //set cell size
//    let cellsInRow = 1
//    let cellHeight = 180
    //set layout attributes
//    if let flowLayout = self.myEventsCollection.collectionViewLayout as? UICollectionViewFlowLayout
//    {
//      print("UIScreen.main.bounds.width=",UIScreen.main.bounds.width)
//      print("myEventsCollection.bounds.width=",myEventsCollection.bounds.width)
//      flowLayout.minimumLineSpacing = 5
//      flowLayout.minimumInteritemSpacing = 3
//      flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 7, right: 5)
//      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
//      print("totalHInsets=",totalHInsets)
//      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
//      print("totalInteritemSpace=",totalInteritemSpace)
//      let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
////            let cellWidth = (myEventsCollection.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
//      //      print("cellWidth=",cellWidth)
//      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
//    }
    
    loadCredentailsFromKeyChain()
//    print("Credentials=",Credentials.username,"   ",Credentials.password)
    self.cellStringArray = self.assignMyEventStrings(myEvents: self.cellDataArray)

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
//    print("prepare(for seque")
    if segue.identifier == "DetailSegue"
    {
//      print("segue.identifier=",segue.identifier)
      if let dest = segue.destination as? DetailViewController,
        let index = myEventsCollection.indexPathsForSelectedItems?.first
      {
        dest.selection = cellDataArray[index.row]!.Object
        dest.detailData = cellDataArray[index.row]!
        dest.eventID = cellDataArray[index.row]!.Id!
//        print("dest.selection=",dest.selection)
//        print("dest.detailData=",dest.detailData)
//        print("detailData=",dest.detailData)
      }
    }
  }
  
  // MARK: - Event data functions
  //retrieve json, parse json, use closure to fill cells
  func updateCellArray()
  {
    DispatchQueue.main.async
      {
        self.spinnerView.isHidden = false
        self.activitySpinner.startAnimating()
      }

    //    let OWWebAPI.shared = OWWebAPI()
    DispatchQueue.main.async{self.spinnerLbl.text = "Fetching Event Data..."}
    usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
    OWWebAPI.shared.retrieveEventList(completion: { (myEvents, error) in
      //fill cells
      DispatchQueue.main.async{self.spinnerLbl.text = "download and parsing complete"}
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
//            for item in myEvents!
//            {
//              self.printEventInfo(eventItem: item)
//            }
      
      
      
      OWWebAPI.shared.saveEvents(myEvents!)
      self.cellDataArray = myEvents!
      self.cellStringArray = self.assignMyEventStrings(myEvents: self.cellDataArray)
//      print("cellStringArray = ",self.cellStringArray)
      
      
      
//      print("cell data array updated")
      DispatchQueue.main.async{self.spinnerLbl.text = "Updating Events..."}
      DispatchQueue.main.async{self.myEventsCollection.reloadData()}
      usleep(useconds_t(0.5 * 1000000)) //will sleep for 0.5 seconds)
      DispatchQueue.main.async
        {
        self.activitySpinner.stopAnimating()
        self.spinnerView.isHidden = true
        }
//      print("invalidate owSession")
//      OWWebAPI.owSession.invalidateAndCancel()
    })
  }
  
  @IBAction func refreshEventCells(_ sender: Any)
  {
    updateCellArray()
    
    //get cookie info
    OWWebAPI.shared.getCookieData()

  }
  
  // MARK: - Utility functions
  

}




extension MyEventsViewController
{
  // MARK: - Collection delegate functions
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
//    print("numberOfItemsInSection=",cellDataArray.count)
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
//  
//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//  {
//    guard let cell = collectionView.cellForItem(at: indexPath) else { return }
//
//    performSegue(withIdentifier: "DetailSegue", sender: cell)
//  }

  
  // MARK: - Collection cell data functions
  
//  func formatEventTime(timeString: String) -> String
//  {
//    let eventTimeFormatter = DateFormatter()
//    eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//    eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
//    if let formattedDate = eventTimeFormatter.date(from: timeString)
//    {
//      eventTimeFormatter.dateFormat = "dd MMM, HH:mm:ss 'UT'"
//      return eventTimeFormatter.string(from: formattedDate)
//    }
//    return timeString
//  }
//  
//  func leadTime(timeString: String) -> String
//  {
//    var leadTimeString = ""
//    let eventTimeFormatter = DateFormatter()
//    eventTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//    eventTimeFormatter.timeZone = TimeZone(abbreviation: "UTC")
//    if let eventDate = eventTimeFormatter.date(from: timeString)
//    {
//      let leadTimeSeconds = Int(eventDate.timeIntervalSinceNow)
//      if leadTimeSeconds <= 0 { return "completed" }
//      let leadTimeMinutes = leadTimeSeconds / 60
//     let leadTimeHours = leadTimeMinutes / 60
//      let leadTimeDays = leadTimeHours / 24
//      if leadTimeMinutes > 0
//      {
//        if leadTimeMinutes < 90
//        {
//          leadTimeString = String(format: "in \(leadTimeMinutes) min")
//        }
//        else if leadTimeHours < 48
//        {
//          leadTimeString = String(format: "in \(leadTimeHours) hours")
//        }
//        else
//        {
//          leadTimeString = String(format: "in \(leadTimeDays) days")
//        }
//      }
//      return leadTimeString
//    }
//    return leadTimeString
//  }
  
  func fillCellFields(cell: inout MyEventsCollectionViewCell, indexPath: IndexPath)
  {
    let calloutFont =   UIFont.preferredFont(forTextStyle: .callout)
    let captionFont =   UIFont.preferredFont(forTextStyle: .caption1)
//    let eventsStrings = self.assignMyEventStrings(myEvents: self.cellDataArray)
    //cell text
//    cell.objectText.text = cellDataArray[indexPath.row]!.Object
//    cell.objectText.text = myEventsStrings.Object
    cell.objectText.text = cellStringArray[indexPath.row].Object

    //create "m" superscript for star magnitude and magnitude drop
    let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,
                                                                       NSAttributedString.Key.baselineOffset: 5])
    let starMagStr = cellStringArray[indexPath.row].StarMag
    let starMagAttrStr = NSMutableAttributedString(string:starMagStr)
    starMagAttrStr.append(magAttrStr)
    cell.starMagText.attributedText = starMagAttrStr

//    if cellDataArray[indexPath.row]!.MagDrop! >= 0.2
//    {
////      let magDropStr = String(format: "%.01f",cellDataArray[indexPath.row]!.MagDrop)
//      let magDropStr = String(format: "%.01f",cellDataArray[indexPath.row]!.MagDrop)
      let magDropAttrStr = NSMutableAttributedString(string:cellStringArray[indexPath.row].MagDrop, attributes:[NSAttributedString.Key.font : calloutFont])
//      let magDropAttrStr = NSMutableAttributedString(string:magDropStr)
      magDropAttrStr.append(magAttrStr)
      cell.magDropText.attributedText = magDropAttrStr
//    }
//    else
//    {
//      let magDropStr = String(format: "%.02f",cellDataArray[indexPath.row]!.MagDrop)
//      let magDropAttrStr = NSMutableAttributedString(string:magDropStr, attributes:[NSAttributedString.Key.font : calloutFont])
//      magDropAttrStr.append(magAttrStr)
//      cell.magDropText.attributedText = magDropAttrStr
//    }
    cell.maxDurText.text = cellStringArray[indexPath.row].MaxDurSec
    cell.leadTime.text = leadTime(timeString: cellStringArray[indexPath.row].EventTimeUtc)
    cell.eventTime.text = formatEventTime(timeString: cellStringArray[indexPath.row].EventTimeUtc)
    //set time error field
    if cellDataArray[indexPath.row]!.ErrorInTimeSec != nil
    {
      let timeError = cellDataArray[indexPath.row]!.ErrorInTimeSec
      if timeError! > 90.0
      {
        let errorInMin = timeError! / 60.0
        cell.timeError.text = String(format: "+/- %.01f min",errorInMin)
      } else {
        if timeError == -1
        {
          cell.timeError.text = "N/A"
        } else {
          cell.timeError.text = String(format: "+/- %.f sec",timeError!)
        }
      }
    }
    //cell images
    cell.maxDurImg.image = #imageLiteral(resourceName: "max_sign")
    cell.magDropImg.image = #imageLiteral(resourceName: "drop_sign")
    
    if cellDataArray[indexPath.row]!.BestStationPos != nil
    {
      var sigmaIconValue = cellDataArray[indexPath.row]!.BestStationPos!
      cell.sigmaImg.image = stationSigmaIcon(sigmaIconValue)   //set station sigma icon
    }
    
    if cellDataArray[indexPath.row]!.StarColour != nil
    {
//      starColorIcon(indexPath, cell)   //set star color icon
      print("star color value = ",cellDataArray[indexPath.row]!.StarColour)
      cell.starMagImg.image = starColorIcon(cellDataArray[indexPath.row]!.StarColour)
    }
    

    if cellDataArray[indexPath.row]!.WeatherInfoAvailable != nil
    {
      //display weather info if forecast available, no display if no forecast
      if cellDataArray[indexPath.row]!.WeatherInfoAvailable!
      {
        if cellDataArray[indexPath.row]!.CloudCover != nil
        {
          var cloudIconValue = cellDataArray[indexPath.row]!.CloudCover
          cell.cloudImg.image = cloudIcon(cloudIconValue)   // set cloud % icon
          cell.cloudText.text = String(format: "%d%%",cellDataArray[indexPath.row]!.CloudCover!)
        }
        
        if cellDataArray[indexPath.row]!.Wind != nil
        {
          var windStrengthIconValue = cellDataArray[indexPath.row]!.Wind
//          windStrengthIconValue = 0
          cell.windStrengthImg.image = windStrengthIcon(windStrengthIconValue)   //set wind strength icon
          cell.windyImg.image = windSignIcon(windStrengthIconValue)   //set wind strength icon
        }

         if cellDataArray[indexPath.row]!.TempDegC != nil
        {
          var thermIconValue = cellDataArray[indexPath.row]?.TempDegC
          cell.tempImg.image = thermIcon(thermIconValue)
          //set weather text to appropriate text
          cell.tempText.text = String(format: "%d°",cellDataArray[indexPath.row]!.TempDegC!)
        }
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

  }

//  func cloudIcon(_ indexPath: IndexPath, _ cell: MyEventsCollectionViewCell)
//  {
//    //set appropriate cloud image
////      0% -  9%   cloud_0.png
////    10% - 19%    cloud_10.png
////    20% - 29%    cloud_20.png
////    30% - 39%    cloud_30.png
////    40% - 49%    cloud_40.png
////    50% - 59%    cloud_50.png
////    60% - 69%    cloud_60.png
////    70% - 79%    cloud_70.png
////    80% - 89%    cloud_80.png
////    90% - 100%   cloud_90.png
//    if cellDataArray[indexPath.row]!.CloudCover != nil
//    {
//      switch cellDataArray[indexPath.row]!.CloudCover!
//      {
//      case 0...9:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_0")
//      case 10...19:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_10")
//      case 20...29:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_20")
//      case 30...39:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_30")
//      case 40...49:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_40.png")
//      case 50...59:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_50.png")
//      case 60...69:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_60.png")
//      case 70...79:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_70.png")
//      case 80...89:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_80.png")
//      case 90...100:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_90.png")
//      default:
//        cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_100.png")
//      }
//    } else {
//      cell.cloudImg.image =  #imageLiteral(resourceName: "cloud_100.png")
//    }
//  }

//  func starColorIcon(_ indexPath: IndexPath, _ cell: MyEventsCollectionViewCell)
//  {
//    if cellDataArray[indexPath.row]!.StarColour != nil
//    {
//    
//      //    Unknown (0) = star_black.png,
//      //    Blue (1) = star_b.png,
//      //    White (2) = star_w.png,
//      //    Yellow (3) = star_y.png,
//      //    Orange (4) = star_o.png,
//      //    Red (5) = star_r.png
//      switch cellDataArray[indexPath.row]!.StarColour!
//      {
//      case 0:
//        cell.starMagImg.image =  #imageLiteral(resourceName: "star_black")
//      case 1:
//        cell.starMagImg.image =  #imageLiteral(resourceName: "star_b")
//      case 2:
//        cell.starMagImg.image =  #imageLiteral(resourceName: "star_w")
//      case 3:
//        cell.starMagImg.image =  #imageLiteral(resourceName: "star_y")
//      case 4:
//        cell.starMagImg.image =  #imageLiteral(resourceName: "star_o")
//      case 5:
//        cell.starMagImg.image =  #imageLiteral(resourceName: "star_r")
//      default:
//        cell.starMagImg.image =  #imageLiteral(resourceName: "star_black")
//      }
//    } else {
//      cell.starMagImg.image =  #imageLiteral(resourceName: "star_black")
//    }
//  }
//
//  func stationSigmaIcon(_ indexPath: IndexPath, _ cell: MyEventsCollectionViewCell)
//  {
//    //    Shadow (0) = spos_0.png,
//    //    OneSigma (1) = spos_1_2.png,
//    //    ThreeSigma (2) = spos_1_2.png,
//    //    Outside (3) = = spos_3.png
//    if cellDataArray[indexPath.row]!.BestStationPos != nil
//    {
//      switch cellDataArray[indexPath.row]!.BestStationPos!
//      {
//      case 0:
//        cell.sigmaImg.image =  #imageLiteral(resourceName: "spos_0")
//      case 1:
//        cell.sigmaImg.image =  #imageLiteral(resourceName: "spos_1_2")
//      case 2:
//        cell.sigmaImg.image =  #imageLiteral(resourceName: "spos_1_2")
//      case 3:
//        cell.sigmaImg.image =  #imageLiteral(resourceName: "spos_3")
//      default:
//        cell.sigmaImg.image =  #imageLiteral(resourceName: "spos_3")
//      }
//    } else {
//      cell.sigmaImg.image =  #imageLiteral(resourceName: "spos_3")
//    }
//  }
//
//  func windStrengthIcon(_ indexPath: IndexPath, _ cell: MyEventsCollectionViewCell)
//  {
////    0 = wind_0.png;
////    1 = wind_1.png;
////    2 = wind_2.png;
////    3 = wind_3.png;
////    4 = wind_4.png;
////    5, 6, 7 = wind_5_6_7.png;
//    if cellDataArray[indexPath.row]!.Wind != nil
//    {
//      switch cellDataArray[indexPath.row]!.Wind!
//      {
//      case 0:
//        cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_0")
//      case 1:
//        cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_1")
//      case 2:
//        cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_2")
//      case 3:
//        cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_3")
//      case 4:
//        cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_4")
//      case 5...7:
//        cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_5_6_7")
//      default:
//        cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_0")
//      }
//    } else {
//      cell.windStrengthImg.image =  #imageLiteral(resourceName: "wind_0")
//    }
//}
//
//  func windSignIcon(_ indexPath: IndexPath, _ cell: MyEventsCollectionViewCell)
//  {
//    //if there is wind use wind_sign.png, if no wind use wind_sign_gray.png
//    if cellDataArray[indexPath.row]!.Wind! > 0
//    {
//      cell.windyImg.image = #imageLiteral(resourceName: "wind_sign")
//    }
//    else
//    {
//      cell.windyImg.image = #imageLiteral(resourceName: "wind_sign_gray")
//    }
//  }
//
//  func thermIcon(_ indexPath: IndexPath, _ cell: MyEventsCollectionViewCell)
//  {
//    
//    // temp <= 0, blue
//    // temp 0...16, yellow
//    // temp 0...32, orange
//    // temp > 32, red
//    if cellDataArray[indexPath.row]!.TempDegC! <= 0
//    {
//      cell.tempImg.image = #imageLiteral(resourceName: "term_b")
//    }
//    else if cellDataArray[indexPath.row]!.TempDegC! < 16
//    {
//      cell.tempImg.image = #imageLiteral(resourceName: "term_y")
//    }
//    else if cellDataArray[indexPath.row]!.TempDegC! < 32
//    {
//      cell.tempImg.image = #imageLiteral(resourceName: "term_o")
//    }
//    else if cellDataArray[indexPath.row]!.TempDegC! >= 32
//    {
//      cell.tempImg.image = #imageLiteral(resourceName: "term_r")
//    }
//  }
//  
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

  
  func assignMyEventStrings(myEvents: [Event?]) -> [EventStrings]
  {
    let calloutFont =   UIFont.preferredFont(forTextStyle: .callout)
    let captionFont =   UIFont.preferredFont(forTextStyle: .caption1)
    var myEventStrings = [EventStrings]()
    for (index, evnt) in myEvents.enumerated()
    {
      var event = evnt
//      print("myEvents: index =",index,"   event=",event)
//      myEventStrings.append(EventStrings(Id: "", Object: "", StarMag: "", MagDrop: "", MaxDurSec: "", EventTimeUtc: "", ErrorInTimeSec: "", WeatherInfoAvailable: "", CloudCover: "", Wind: "", TempDegC: "", HighCloud: "", BestStationPos: "", StarColour: ""))
      var eventStrings = EventStrings()
//      print("myEventStrings=",myEventStrings)
      if event!.Id != nil { eventStrings.Id = event!.Id ?? "" }
      if event!.Object != nil { eventStrings.Object = event!.Object ?? "" }
      
      //*******check precision
      
       if event!.StarMag != nil
      {
//        let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,
//                                                                           NSAttributedString.Key.baselineOffset: 5])
//        let starMagStr = String(format: "%.01f",event!.StarMag!)
//        let starMagAttrStr = NSMutableAttributedString(string:starMagStr)
//        starMagAttrStr.append(magAttrStr)
//        cell.starMagText.attributedText = starMagAttrStr
        eventStrings.StarMag = String(format: "%.01f",event!.StarMag!)
      }

      if event!.MagDrop != nil
      {
        if event!.MagDrop! >= 0.2
        {
          //create "m" superscript for star magnitude and magnitude drop
//          let magAttrStr = NSMutableAttributedString(string:"m", attributes:[NSAttributedString.Key.font : captionFont,
//                                                                             NSAttributedString.Key.baselineOffset: 5])
//          let starMagStr = myEventsStrings.StarMag
//          let starMagAttrStr = NSMutableAttributedString(string:starMagStr)
//          starMagAttrStr.append(magAttrStr)
//          myEventStrings.StarMag.attributedText = starMagAttrStr

//          let magDropStr = String(format: "%.01f",event!.MagDrop!)
          //      let magDropAttrStr = NSMutableAttributedString(string:magDropStr, attributes:[NSAttributedString.Key.font : calloutFont])
//          let magDropAttrStr = NSMutableAttributedString(string:magDropStr)
//          magDropAttrStr.append(magAttrStr)
          eventStrings.MagDrop = String(format: "%.01f",event!.MagDrop!)
        }
        else
        {
//          let magDropStr = String(format: "%.02f",cellDataArray[indexPath.row]!.MagDrop)
//          let magDropAttrStr = NSMutableAttributedString(string:magDropStr, attributes:[NSAttributedString.Key.font : calloutFont])
//          magDropAttrStr.append(magAttrStr)
//          cell.magDropText.attributedText = magDropAttrStr
          eventStrings.MagDrop = String(format: "%.02f",event!.MagDrop!)
        }

      }
      if event!.MaxDurSec != nil
      {
        eventStrings.MaxDurSec = String(format: "%.01f",event!.MaxDurSec!)
      }
      if event!.EventTimeUtc != nil { eventStrings.EventTimeUtc = event!.EventTimeUtc! }
      //***test***
      event!.ErrorInTimeSec = nil
      //***test***
      if event!.ErrorInTimeSec != nil
      {
        eventStrings.ErrorInTimeSec = String(format: "%.01f",event!.ErrorInTimeSec!)
      }
       if event!.WeatherInfoAvailable != nil
      {
        eventStrings.WeatherInfoAvailable = String(format: "%@",event!.WeatherInfoAvailable!.description)
      }
      if event!.CloudCover != nil
      {
        eventStrings.CloudCover = String(format: "%d",event!.CloudCover!)
      }
      if event!.Wind != nil
      {
        eventStrings.Wind = String(format: "%d",event!.Wind!)
      }
      if event!.TempDegC != nil
      {
        eventStrings.TempDegC = String(format: "%d",event!.TempDegC!)
      }
      if event!.HighCloud != nil
      {
        eventStrings.HighCloud = String(format: "%@",event!.HighCloud!.description)
      }
      if event!.BestStationPos != nil
      {
        eventStrings.BestStationPos = String(format: "%d",event!.BestStationPos!)
      }
      if event!.StarColour != nil
      {
        eventStrings.StarColour = String(format: "%d",event!.StarColour!)
      }
//      print("eventStrings=",eventStrings)
      myEventStrings.append(eventStrings)
    }
//    print()
//    print("myEventStrings = ",myEventStrings)
    return myEventStrings
  }

}

extension MyEventsViewController: OWWebAPIDelegate
{
  func webLogTextDidChange(text: String)
  {
    DispatchQueue.main.async
      {
//        print("webLogTextDidChange>text to: ",text)
        self.spinnerLbl.text = text
    }
  }
}
