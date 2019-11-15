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
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    loadCredentailsFromKeyChain()
    print("Credentials.username=",Credentials.username,"   Credentials.password=",Credentials.password)
    if Credentials.username == "" || Credentials.password == ""
    {
      self.selectedIndex = 1
    } else {
      self.selectedIndex = 0
    }
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

}
