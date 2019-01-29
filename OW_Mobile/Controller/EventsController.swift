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
    print("numberOfItemsInSection")
    return 6
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//    print("return reuse cell")
    return cell
  }
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    eventsCollection.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    let cellsInRow = 3
    if let flowLayout = self.eventsCollection.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.minimumLineSpacing = 5
      flowLayout.minimumInteritemSpacing = 5
      flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      print("totalHInsets=",totalHInsets)
      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
      print("totalInteritemSpace=",totalInteritemSpace)
      let cellWidth = (self.eventsCollection.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      print("cellWidth=",cellWidth)
      print("self.eventsCollection.bounds.width=",self.eventsCollection.bounds.width)
      flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
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
