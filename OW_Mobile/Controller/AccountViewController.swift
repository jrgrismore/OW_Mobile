//
//  AccountViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 1/30/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit
import Foundation

class AccountViewController: UIViewController {
  
  @IBOutlet weak var loginView: UIView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.loginView.layer.cornerRadius = 10
    let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)]
    UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
  }
  
  @IBAction func testJsonParser(_ sender: Any)
  {
    print("test JSON parser")
    let parsedJSON = JsonHandler()
    parsedJSON.downloadJSON(completion: { (owEvents, error) in
      print("AccountViewController")
      print("error=",error)
      print("owEvents=",owEvents)
      for item in owEvents!
      {
        self.printFullEventJSON(eventItem: item)
      }
    })
  }
  
  func printFullEventJSON(eventItem item: Event)
  {
    print()
    print("Id =", item.Id)
    print("Object =", item.Object)
    print("StarMag =", item.StarMag)
    print("MagDrop =", item.MagDrop)
    print("MaxDurSec =", item.MaxDurSec)
    print("EventTimeUtc =", item.EventTimeUtc)
    print("ErrorInTimeSec =", item.ErrorInTimeSec)
    print("WhetherInfoAvailable =", item.WhetherInfoAvailable)
    print("CloudCover =", item.CloudCover)
    print("Wind =", item.Wind)
    print("TempDegC =", item.TempDegC)
    print("HighCloud =", item.HighCloud)
    print("BestStationPos =", item.BestStationPos)
  }
  
}
