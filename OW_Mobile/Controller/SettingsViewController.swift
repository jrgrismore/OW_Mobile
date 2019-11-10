//
//  SettingsViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 11/8/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

var appSettings = Settings()

class SettingsViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var settingsStackView: UIStackView!
  
  @IBOutlet weak var tempSeg: UISegmentedControl!
  @IBOutlet weak var azimuthSeg: UISegmentedControl!
  @IBOutlet weak var summaryTimeSeg: UISegmentedControl!
  @IBOutlet weak var detailTimeSeg: UISegmentedControl!
  @IBOutlet weak var starEpochSeg: UISegmentedControl!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    var segmentFont =   UIFont.preferredFont(forTextStyle: .body)

//    summaryTimeSeg.setTitleTextAttributes([NSAttributedString.Key.font : segmentFont, NSAttributedString.Key.foregroundColor: UIColor.init(red: 87, green: 87, blue: 87, alpha: 1.0)], for: .normal)
//    summaryTimeSeg.setTitleTextAttributes([NSAttributedString.Key.font : segmentFont, NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
  }
  
  override func viewWillAppear(_ animated: Bool) {
//    print("viewWillAppear")
    //temporarily remove settings from user defaults
//    UserDefaults.standard.removeObject(forKey: UDKeys.settings)
    
//    print("appSettings=",appSettings)
    appSettings = loadSettings()
//    print("appSettings=",appSettings)
    tempSeg.selectedSegmentIndex = appSettings.tempIsCelsius ? 0 : 1
    azimuthSeg.selectedSegmentIndex = appSettings.azimuthIsDegrees ? 0 : 1
    summaryTimeSeg.selectedSegmentIndex = appSettings.summaryTimeIsLocal ? 0 : 1
    detailTimeSeg.selectedSegmentIndex = appSettings.detailTimeIsLocal ? 0 : 1
    starEpochSeg.selectedSegmentIndex = appSettings.starEpochIsJ2000 ? 0 : 1
  }
  
  override func viewDidAppear(_ animated: Bool) {
    scrollView.contentSize.height = settingsStackView.bounds.size.height
  }
  
  override func viewWillDisappear(_ animated: Bool) {
//    print("viewWillDisappear")
//    appSettings.tempIsCelsius = tempSeg.selectedSegmentIndex == 0 ? true : false
//    appSettings.azimuthIsDegrees = azimuthSeg.selectedSegmentIndex == 0 ? true : false
//    appSettings.summaryTimeIsLocal = summaryTimeSeg.selectedSegmentIndex == 0 ? true : false
//    appSettings.detailTimeIsLocal = detailTimeSeg.selectedSegmentIndex == 0 ? true : false
//    appSettings.starEpochIsJ2000 = starEpochSeg.selectedSegmentIndex == 0 ? true : false
//    print("appSettings=",appSettings)
    saveSettings(appSettings)
//    print("reloaded Settings=",loadSettings())
  }
    
  @IBAction func toggleTemp(_ sender: Any) {
    switch tempSeg.selectedSegmentIndex
    {
    case 0:
      print("show temperature in Celsius")
      appSettings.tempIsCelsius = true
    case 1:
      print("show temperature in Fahrenheit")
      appSettings.tempIsCelsius = false
    default:
      print("default temperature is Fahrenheit")
      appSettings.tempIsCelsius = false
    }
    saveSettings(appSettings)
  }
  
  @IBAction func toggleAzimuth(_ sender: Any) {
    switch azimuthSeg.selectedSegmentIndex
    {
    case 0:
      print("show azimuth as Degrees")
      appSettings.azimuthIsDegrees = true
    case 1:
      print("show azimuth as Compass directions")
      appSettings.azimuthIsDegrees = false
    default:
      print("default azimuth is Degrees")
      appSettings.azimuthIsDegrees = true
    }
    saveSettings(appSettings)
  }
  
  @IBAction func toggleSummaryTime(_ sender: Any) {
    switch summaryTimeSeg.selectedSegmentIndex
    {
    case 0:
      print("show summary time as Local")
      appSettings.summaryTimeIsLocal = true
    case 1:
      print("show summary time as UT")
      appSettings.summaryTimeIsLocal = false
    default:
      print("default summary time is Local")
      appSettings.summaryTimeIsLocal = true
    }
    saveSettings(appSettings)
  }
 
  @IBAction func toggleDetailTime(_ sender: Any) {
    switch detailTimeSeg.selectedSegmentIndex
    {
    case 0:
      print("show detail time as Local")
      appSettings.detailTimeIsLocal = true
    case 1:
      print("show detail time as UT")
      appSettings.detailTimeIsLocal = false
    default:
      print("default detail time is Local")
      appSettings.detailTimeIsLocal = true
    }
    saveSettings(appSettings)
  }
  
  @IBAction func toggleStarEpoch(_ sender: Any) {
    switch starEpochSeg.selectedSegmentIndex
    {
    case 0:
      print("show star epoch as J2000")
      appSettings.starEpochIsJ2000 = true
    case 1:
      print("show star epoch as JNow")
      appSettings.starEpochIsJ2000 = false
    default:
      print("show star epoch as J2000")
      appSettings.starEpochIsJ2000 = true
    }
    saveSettings(appSettings)
  }
  


}