//
//  MyEventsCollectionViewCell.swift
//  OW_Mobile
//
//  Created by John Grismore on 2/3/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class MyEventsCollectionViewCell: UICollectionViewCell
{
  // MARK: - Cell field outlets
  
  //top view text
  @IBOutlet weak var objectText: UILabel!
  @IBOutlet weak var cloudText: UILabel!
  @IBOutlet weak var tempText: UILabel!
  
  //top view images
  @IBOutlet weak var sigmaImg: UIImageView!
  @IBOutlet weak var cloudImg: UIImageView!
  @IBOutlet weak var windStrengthImg: UIImageView!
  @IBOutlet weak var windyImg: UIImageView!
  @IBOutlet weak var tempImg: UIImageView!
  
  //middle view text
  @IBOutlet weak var leadTime: UILabel!
  @IBOutlet weak var eventTime: UILabel!
  @IBOutlet weak var timeError: UILabel!
  
  //bottom view text
  @IBOutlet weak var starMagText: UILabel!
  @IBOutlet weak var maxDurText: UILabel!
  @IBOutlet weak var magDropText: UILabel!
  
  //bottom view images
  @IBOutlet weak var starMagImg: UIImageView!
  @IBOutlet weak var maxDurImg: UIImageView!
  @IBOutlet weak var magDropImg: UIImageView!
  
}
