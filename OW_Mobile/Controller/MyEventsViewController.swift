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
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return 60
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyEventsCollectionViewCell
    let remainder = indexPath.row % 10
//    outlet tests
//    cell.sigmaImg.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//    cell.objectText.text = "Test Object Text"
//    cell.cloudImg.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//    cell.cloudText.text = "101%"
//    cell.windStrengthImg.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//    cell.windyImg.backgroundColor =  colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//    cell.tempText.text = "99°"
//      cell.tempImg.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//    cell.leadTime.text = "61 min"
//    cell.eventTime.text = "25:61:61"
//    cell.timeError.text = "+/- 4 days😊"
//    cell.starMagImg.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//    cell.starMagText.text = "25.3"
//    cell.maxDurImg.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//    cell.maxDurText.text = "3.14 hours"
//    cell.magDropImg.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
//    cell.magDropText.text = "67.8"
    switch remainder {
    case 0:
      cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.673458497)
    case 1:
      cell.backgroundColor = #colorLiteral(red: 0.9781141877, green: 0.9266665578, blue: 0.610206306, alpha: 1)
    case 2:
      cell.backgroundColor = #colorLiteral(red: 0.6820191145, green: 1, blue: 0.7397634387, alpha: 1)
    case 3:
      cell.backgroundColor = #colorLiteral(red: 0.4048807621, green: 0.6710730195, blue: 0.6450495124, alpha: 1)
    case 4:
      cell.backgroundColor = #colorLiteral(red: 0.6820191145, green: 1, blue: 0.7397634387, alpha: 1)
    case 5:
      cell.backgroundColor = #colorLiteral(red: 0.435174942, green: 1, blue: 0.8257846236, alpha: 1)
    case 6:
      cell.backgroundColor = #colorLiteral(red: 0.5253279805, green: 0.6064991355, blue: 1, alpha: 1)
    case 7:
      cell.backgroundColor = #colorLiteral(red: 0.7084195018, green: 0.598293364, blue: 1, alpha: 1)
    case 8:
      cell.backgroundColor = #colorLiteral(red: 0.9716592431, green: 0.797021687, blue: 1, alpha: 1)
    case 9:
      cell.backgroundColor = #colorLiteral(red: 1, green: 0.7660988569, blue: 0.7564550042, alpha: 1)
    default:
      cell.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

    }
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
      let cellWidth = (self.myEventsCollection.bounds.size.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
  }
  
}
