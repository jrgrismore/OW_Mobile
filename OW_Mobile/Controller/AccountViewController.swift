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
  static var username = ""
  static var password = ""
}

var userHasChanged: Bool = false

func saveCredentailsToKeyChain()
{
  let server = "www.occultwatcher.net"
  let username = Credentials.username
  let password = Credentials.password.data(using: .utf8)
  let attributes: [String : Any] =
    [
      (kSecClass as String): kSecClassInternetPassword,
      (kSecAttrServer as String): server,
      (kSecAttrAccount as String): username,
      (kSecValueData as String): password as Any
  ]
  //delete preexisting item
  let itemDeleteStatus = SecItemDelete(attributes as CFDictionary)
  //add item to keychain
  let itemAddStatus = SecItemAdd(attributes as CFDictionary, nil)
}

func deleteCredentailsFromKeyChain()
{
  let server = "www.occultwatcher.net"
  //  let username = Credentials.username
  //  let password = Credentials.password.data(using: .utf8)
  let attributes: [String : Any] =
    [
      (kSecClass as String): kSecClassInternetPassword,
      (kSecAttrServer as String): server
  ]
  //delete preexisting item
  let itemDeleteStatus = SecItemDelete(attributes as CFDictionary)
}

func updateCredentailsOnKeyChain()
{
  print("updateCredentailsOnKeyChain")
  let server = "www.occultwatcher.net"
  let username = Credentials.username
  let password = Credentials.password.data(using: .utf8)
  let query: [String : Any] =
    [
      (kSecClass as String): kSecClassInternetPassword,
      (kSecAttrServer as String): server
  ]
  
  let updateAttributes: [String: Any] =
    [
      kSecAttrAccount as String: username,
      kSecValueData as String: password as Any
  ]
  
  //update existingbitem on keychain
  let itemUpdateStatus = SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
  
}

func loadCredentailsFromKeyChain()
{
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
  
  
  if let existingItem = item as? [String: Any],
    let username = existingItem[kSecAttrAccount as String] as? String,
    let passwordData = existingItem[kSecValueData as String] as? Data,
    let password = String(data: passwordData, encoding: .utf8)
  {
    Credentials.username = username
    Credentials.password = password
  }
}

func deleteAllSecItemsFromKeychain()
{
  let secItemClasses =  [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
  for itemClass in secItemClasses
  {
    let itemKeyVal: NSDictionary = [kSecClass : itemClass]
    SecItemDelete(itemKeyVal)
  }
}

class AccountViewController: UIViewController, UITextFieldDelegate
{
  
  @IBOutlet weak var emailView: UIView!
  @IBOutlet weak var passwordView: UIView!
  @IBOutlet weak var emailFld: UITextField!
  @IBOutlet weak var passwordFld: UITextField!
  @IBOutlet weak var versionLbl: UILabel!
  
  var initialUserName: String = ""
  var finalUserName: String = ""
  
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
    super.viewWillAppear(true)
    versionLbl.text = versionBuild()
    loadCredentailsFromKeyChain()
    emailFld.text = Credentials.username
    initialUserName = Credentials.username
    passwordFld.text = Credentials.password
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    if emailFld.text != Credentials.username || passwordFld.text != Credentials.password
    {
      Credentials.username = emailFld.text!
      Credentials.password = passwordFld.text!
      finalUserName = Credentials.username
      deleteAllSecItemsFromKeychain()
      saveCredentailsToKeyChain()
      OWWebAPI.shared.deleteCookies()
    }
    finalUserName = Credentials.username
    if finalUserName != initialUserName
    {
      userHasChanged = true
    }
  }
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason)
  {
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
  }
  
  @IBAction func updateUserandPassword(_ sender: Any)
  {
    deleteCredentailsFromKeyChain()
    saveCredentailsToKeyChain()
    loadCredentailsFromKeyChain()
    userHasChanged = true
  }
  
  func versionBuild() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "v\(version)b\(build)"
  }
  
}
