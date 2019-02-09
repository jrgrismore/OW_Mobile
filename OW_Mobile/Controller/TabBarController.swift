//
//  TabBarController.swift
//  OW_Mobile
//
//  Created by John Grismore on 2/8/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

var someURLSession: URLSession = URLSession()

class TabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)]
    UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
    print("TabBarController > viewDidLoad")
  }
  
}
