//
//  TestViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 6/26/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class TestViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
   let reuseIdentifier = "StationCell"
  @IBOutlet weak var stationCollectionView: UICollectionView!
  @IBOutlet weak var stationCollectionCell: UICollectionViewCell!

  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StationCell
    cell.backgroundColor = #colorLiteral(red: 0.2043271959, green: 0.620110333, blue: 0.6497597098, alpha: 1)
//    fillCellFields(cell: &cell, indexPath: indexPath)
    return cell
  }
  
  
  
  // MARK: - View functions
  override func viewWillLayoutSubviews()
  {
    print("viewWillLayoutSubviews")
    super.viewWillLayoutSubviews()
    stationCollectionView.collectionViewLayout.invalidateLayout()
    //set cell size
    let cellsInRow = 5
//    var cellHeight = 180
    var cellHeight = stationCollectionView.bounds.height-6
    //set layout attributes
    if let flowLayout = self.stationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
    {
      //      print("UIScreen.main.bounds.width=",UIScreen.main.bounds.width)
      //      print("myEventsCollection.bounds.width=",myEventsCollection.bounds.width)
      flowLayout.minimumLineSpacing = 3
      flowLayout.minimumInteritemSpacing = 0
      flowLayout.sectionInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
      let totalHInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
      //      print("totalHInsets=",totalHInsets)
//      let totalInteritemSpace = flowLayout.minimumInteritemSpacing * CGFloat(cellsInRow - 1)
      //      print("totalInteritemSpace=",totalInteritemSpace)
//            let cellWidth = (UIScreen.main.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
//            let cellWidth = (stationCollectionView.bounds.width - totalInteritemSpace - totalHInsets)/CGFloat(cellsInRow)
      //      print("cellWidth=",cellWidth)
      //? is this the right way to do this ?
//            let cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width - totalHInsets
      //?does this work for all screen sizes and orientations?
      var cellWidth = view.safeAreaLayoutGuide.layoutFrame.size.width - flowLayout.minimumLineSpacing
//      var cellWidth = self.stationCollectionView.bounds.width - totalHInsets
//      var cellWidth = self.stationCollectionView.bounds.width - flowLayout.minimumInteritemSpacing
//      cellHeight = 100
//      cellWidth = 100
      print("cell height=",cellHeight,"   cell width=",cellWidth)
      flowLayout.itemSize = CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
  }


  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
