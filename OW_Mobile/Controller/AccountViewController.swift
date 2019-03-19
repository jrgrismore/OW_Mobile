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
  
  @IBOutlet weak var emailView: UIView!
  @IBOutlet weak var passwordView: UIView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.emailView.layer.cornerRadius = 10
    self.passwordView.layer.cornerRadius = 10
  }
}
