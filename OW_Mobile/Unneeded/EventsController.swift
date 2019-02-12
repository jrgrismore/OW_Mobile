//
//  EventsController.swift
//  OW_Mobile
//
//  Created by John Grismore on 1/28/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class EventsController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
  @IBOutlet weak var eventsCollection: UICollectionView!
   
  let reuseIdentifier = "OWEventCell"
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
     return 60
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OWCollectionViewCell
    let remainder = indexPath.row % 3
    cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    if remainder == 0
    {
      cell.owCellImg.image = UIImage(named: "2004FD30")
    }
    else if remainder == 1
    {
      cell.owCellImg.image = UIImage(named: "Chikatosh8")
    }
    else if remainder == 2
    {
      cell.owCellImg.image = UIImage(named: "Schwassmann")
    }
    return cell
  }
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
     eventsCollection.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    eventsCollection.contentSize = CGSize(width: 10_000, height: 10_000)

    let cellsInRow = 1
    let cellHeight = 100
    
    if let flowLayout = self.eventsCollection.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.minimumLineSpacing = 5
      flowLayout.minimumInteritemSpacing = 5
      flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
       let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)

//      let cellWidth = (self.eventsCollection.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      let cellWidth = (self.eventsCollection.bounds.size.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
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
