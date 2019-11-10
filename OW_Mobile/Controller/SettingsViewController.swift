//
//  SettingsViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 11/8/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var settingsStackView: UIStackView!
  @IBOutlet weak var summaryTimeSeg: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var segmentFont =   UIFont.preferredFont(forTextStyle: .body)

//    summaryTimeSeg.setTitleTextAttributes([NSAttributedString.Key.font : segmentFont, NSAttributedString.Key.foregroundColor: UIColor.init(red: 87, green: 87, blue: 87, alpha: 1.0)], for: .normal)
//    summaryTimeSeg.setTitleTextAttributes([NSAttributedString.Key.font : segmentFont, NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
  }
  
  override func viewWillAppear(_ animated: Bool) {
  }
  
  override func viewDidAppear(_ animated: Bool) {
    scrollView.contentSize.height = settingsStackView.bounds.size.height
  }
    

}
