//
//  AccountViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 1/30/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit
import Foundation

class AccountViewController: UIViewController
{
  
  @IBOutlet weak var loginView: UIView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.loginView.layer.cornerRadius = 10
  }
}
