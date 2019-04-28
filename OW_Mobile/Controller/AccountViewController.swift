//
//  AccountViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 1/30/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit
import Foundation



enum KeychainError: Error
{
  case noPassword
  case unexpectedPasswordData
  case unhandledError(status: OSStatus)
}

struct Credentials
{
  static var username = "Alex Pratt"
  static var password = "qwerty123456"
}

func saveCredentailsToKeyChain()
{
  print("saveCredentailsToKeyChain")
  let server = "www.occultwatcher.net"
  print("Credentials=",Credentials.username,"   ",Credentials.password)
  let username = Credentials.username
  print("save username=",username)
  let password = Credentials.password.data(using: .utf8)
  print("save password=",password)
  let attributes: [String : Any] =
    [
      (kSecClass as String): kSecClassInternetPassword,
      (kSecAttrServer as String): server,
      (kSecAttrAccount as String): username,
      (kSecValueData as String): password
  ]
  
  //delete preexisting item
  let itemDeleteStatus = SecItemDelete(attributes as CFDictionary)
  //    print("itemDeleteStatus=",itemDeleteStatus.description)
  
  //add item to keychain
  let itemAddStatus = SecItemAdd(attributes as CFDictionary, nil)
  //    print("itam add status=",itemAddStatus.description)
  //    let errorMsg = SecCopyErrorMessageString(itemAddStatus, nil)!
}

func deleteCredentailsFromKeyChain()
{
  print("deleteCredentailsFromKeyChain")
  let server = "www.occultwatcher.net"
  print("Credentials=",Credentials.username,"   ",Credentials.password)
  let username = Credentials.username
  print("delete username=",username)
  let password = Credentials.password.data(using: .utf8)
  print("delete password=",password)
  let attributes: [String : Any] =
    [
      (kSecClass as String): kSecClassInternetPassword,
      (kSecAttrServer as String): server
      //        (kSecAttrAccount as String): username,
      //        (kSecValueData as String): password
  ]
  //delete preexisting item
  let itemDeleteStatus = SecItemDelete(attributes as CFDictionary)
  //    print("itemDeleteStatus=",itemDeleteStatus.description)
}

func updateCredentailsOnKeyChain()
{
  print("updateCredentailsOnKeyChain")
  let server = "www.occultwatcher.net"
  print("Credentials=",Credentials.username,"   ",Credentials.password)
  let username = Credentials.username
  print("update username=",username)
  let password = Credentials.password.data(using: .utf8)
  print("update password=",password)
  let query: [String : Any] =
    [
      (kSecClass as String): kSecClassInternetPassword,
      (kSecAttrServer as String): server
  ]
  
  let updateAttributes: [String: Any] =
    [
      kSecAttrAccount as String: username,
      kSecValueData as String: password
  ]
  
  //update existingbitem on keychain
  let itemUpdateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
  print("itam update status=",itemUpdateStatus.description)
  
}

func loadCredentailsFromKeyChain()
{
  print("loadCredentailsFromKeyChain")
  let server = "www.occultwatcher.net"
  //query for item in keychain
  let query: [String: Any] =
    [
      (kSecClass as String): kSecClassInternetPassword,
      (kSecAttrServer as String): server,
      (kSecMatchLimit as String): kSecMatchLimitOne,
      (kSecReturnAttributes as String): true,
      (kSecReturnData as String): true
  ]
  var item: CFTypeRef?
  
  let itemCopyMatchingStatus = SecItemCopyMatching(query as CFDictionary, &item )
  print("itemCopyMatchingStatus=",itemCopyMatchingStatus)
  
  if let existingItem = item as? [String: Any],
    let username = existingItem[kSecAttrAccount as String] as? String,
    let passwordData = existingItem[kSecValueData as String] as? Data,
    let password = String(data: passwordData, encoding: .utf8)
  {
    print("from keychain:")
    print("username=",username,"   password=",password)
    Credentials.username = username
    Credentials.password = password
  }
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
    emailFld.delegate = self
    passwordFld.delegate = self
    emailView.layer.cornerRadius = 10
    passwordView.layer.cornerRadius = 10
    emailFld.textContentType = .username
    passwordFld.textContentType = .password
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    print("viewWillAppear")
    super.viewWillAppear(true)
    versionLbl.text = versionBuild()
    loadCredentailsFromKeyChain()
    print("loaded Credentials=",Credentials.username,"   ",Credentials.password)
    emailFld.text = Credentials.username
    passwordFld.text = Credentials.password
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    print("viewWillDisappear")
    print("email= \(emailFld.text)   Credentials.username=\(Credentials.username)")
    if emailFld.text != Credentials.username || passwordFld.text != Credentials.password
    {
      Credentials.username = emailFld.text!
      Credentials.password = passwordFld.text!
//      saveCredentailsToKeyChain()
      updateCredentailsOnKeyChain()
//      deleteCredentailsFromKeyChain()
      OWWebAPI.shared.deleteCookie()
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    //set username and password
//    Credentials.username = emailFld.text!
//    Credentials.password = passwordFld.text!
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason)
  {
    print("textFieldDidEndEditing")
    if textField == emailFld
    {
//      print("set username")
//      Credentials.username = emailFld.text!
    }
    else if textField == passwordFld
    {
//      print("set password")
//      Credentials.password = passwordFld.text!
    }
//    print("Credentials=",Credentials.username,"   ",Credentials.password)
  }
  
  @IBAction func updateUserandPassword(_ sender: Any)
  {
    print("updateUserandPassword")
    deleteCredentailsFromKeyChain()
    saveCredentailsToKeyChain()
//    updateCredentailsOnKeyChain()
    loadCredentailsFromKeyChain()
  }
  
  func versionBuild() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "v\(version)b\(build)"
  }

}
