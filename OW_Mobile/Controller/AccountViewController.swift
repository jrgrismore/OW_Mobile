//
//  AccountViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 1/30/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit
import Foundation

struct Credentials
{
  static var username = "Alex Pratt"
  static var password = "qwerty123456"
}

class AccountViewController: UIViewController, UITextFieldDelegate
{
  
  @IBOutlet weak var emailView: UIView!
  @IBOutlet weak var passwordView: UIView!
  @IBOutlet weak var emailFld: UITextField!
  @IBOutlet weak var passwordFld: UITextField!
  @IBOutlet weak var versionLbl: UILabel!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.emailFld.delegate = self
    self.passwordFld.delegate = self
    self.emailView.layer.cornerRadius = 10
    self.passwordView.layer.cornerRadius = 10
    emailFld.textContentType = .username
    passwordFld.textContentType = .password
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(true)
    versionLbl.text = versionBuild()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    //set username and password
    Credentials.username = emailFld.text!
    Credentials.password = passwordFld.text!
    print("Credentials=",Credentials.username,"   ",Credentials.password)
    return true
  }
  
  func versionBuild() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "v\(version)b\(build)"
  }

}
