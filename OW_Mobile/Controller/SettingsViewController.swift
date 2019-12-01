//
//  SettingsViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 11/8/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

var appSettings = Settings()

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
  var pickerData: [String] = []

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var settingsStackView: UIStackView!
  
  @IBOutlet weak var autoUpdateSwitch: UISwitch!
  @IBOutlet weak var autoUpdateSeg: UISegmentedControl!
  @IBOutlet weak var tempSeg: UISegmentedControl!
  @IBOutlet weak var azimuthSeg: UISegmentedControl!
  @IBOutlet weak var summaryTimeSeg: UISegmentedControl!
  @IBOutlet weak var detailTimeSeg: UISegmentedControl!
  @IBOutlet weak var starEpochSeg: UISegmentedControl!
  @IBOutlet weak var latlonFormatSeg: UISegmentedControl!
  
  @IBOutlet weak var eventDayFormatPicker: UIPickerView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
    UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)

    eventDayFormatPicker.delegate = self
    eventDayFormatPicker.dataSource = self
    eventDayFormatPicker.backgroundColor = .lightGray

    
    pickerData = ["Thursday (Evening/Night/Morning)","Thursday (Evening/Night)","07 November 2019"]
    NotificationCenter.default.addObserver(self, selector: #selector(handleEventTimer), name: NSNotification.Name(rawValue: NotificationKeys.dataRefreshIsDone), object: nil)
  }
  
  @objc func handleEventTimer()
  {
    print("AccountViewController > handleEventTimer")
    print("AccountViewController > eventRefreshFailed=",eventRefreshFailed)
    if eventRefreshFailed
    {
      //terminate automatic update activities and show alert
      var autoUpdateAlert = UIAlertController(title: "Automatic Events Update Failed!  No Internet Connection.", message: "Cancel Automatic Updating, or Retry?\n(You can re-enable automatic updates in Settings)", preferredStyle: .alert)
      //retry
      var retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
        print("retry")
        refreshEventsWithDetails(completionHandler: {() -> () in
          print("Account > refreshEventsWithDetails > completionHandler")
          print("start refresh timer")
          //start data refresh timer
          startEventUpdateTimer()
        })
      }
      autoUpdateAlert.addAction(retryAction)
      //cancel
      var cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        appSettings.autoUpdateIsOn = false
        saveSettings(appSettings)
      }
      autoUpdateAlert.addAction(cancelAction)
      //show alert
      self.present(autoUpdateAlert, animated: true, completion: nil)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    //temporarily remove settings from user defaults
//    UserDefaults.standard.removeObject(forKey: UDKeys.settings)
    
//    print("appSettings=",appSettings)
    appSettings = loadSettings()
//    print("appSettings=",appSettings)
    autoUpdateSwitch.isOn = appSettings.autoUpdateIsOn
    print("appSettings.autoUpdateValue=",appSettings.autoUpdateValue)
    if autoUpdateSwitch.isOn
    {
      autoUpdateSeg.isUserInteractionEnabled = true
      autoUpdateSeg.alpha = 1.0
    } else {
      autoUpdateSeg.isUserInteractionEnabled = false
      autoUpdateSeg.alpha = 0.5
    }
    autoUpdateSeg.selectedSegmentIndex = appSettings.autoUpdateValue
    
 
    tempSeg.selectedSegmentIndex = appSettings.tempIsCelsius ? 0 : 1
    azimuthSeg.selectedSegmentIndex = appSettings.azimuthIsDegrees ? 0 : 1
    eventDayFormatPicker.selectRow(appSettings.eventDayFormat, inComponent: 0, animated: true)
    summaryTimeSeg.selectedSegmentIndex = appSettings.summaryTimeIsLocal ? 0 : 1
    detailTimeSeg.selectedSegmentIndex = appSettings.detailTimeIsLocal ? 0 : 1
    starEpochSeg.selectedSegmentIndex = appSettings.starEpochIsJ2000 ? 0 : 1
    latlonFormatSeg.selectedSegmentIndex = appSettings.latlonFormatIsDMS ? 0 : 1
  }
  
  override func viewDidAppear(_ animated: Bool) {
    scrollView.contentSize.height = settingsStackView.bounds.size.height
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    saveSettings(appSettings)
  }

  @objc func deviceRotated()
  {
  }

  @IBAction func toggleAutoUpdateSwitch(_ sender: Any)
  {
    switch autoUpdateSwitch.isOn
    {
    case false:
      print("autoUpdate is off")
      appSettings.autoUpdateIsOn = false
      autoUpdateSeg.isUserInteractionEnabled = false
      autoUpdateSeg.alpha = 0.5
      stopEventUpdateTimer()
    case true:
      print("autoUpdate is on")
      appSettings.autoUpdateIsOn = true
      autoUpdateSeg.isUserInteractionEnabled = true
      autoUpdateSeg.alpha = 1.0
      startEventUpdateTimer()
    default:
      print("default autoUpdate is on")
      appSettings.autoUpdateIsOn = true
      autoUpdateSeg.isUserInteractionEnabled = true
      autoUpdateSeg.alpha = 1.0
      startEventUpdateTimer()
    }
    saveSettings(appSettings)
  }
  
  @IBAction func assignAutoUpdateSeg(_ sender: Any)
  {
    appSettings.autoUpdateValue = autoUpdateSeg.selectedSegmentIndex
    saveSettings(appSettings)
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
      eventDayFormatPicker.isUserInteractionEnabled = true
      eventDayFormatPicker.alpha = 1.0
    case 1:
      print("show summary time as UT")
      appSettings.summaryTimeIsLocal = false
      eventDayFormatPicker.isUserInteractionEnabled = false
      eventDayFormatPicker.selectRow(2, inComponent: 0, animated: true)
      eventDayFormatPicker.alpha = 0.5
    default:
      print("default summary time is Local")
      appSettings.summaryTimeIsLocal = true
      eventDayFormatPicker.isUserInteractionEnabled = true
      eventDayFormatPicker.alpha = 1.0
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
  
  @IBAction func toggleLatLonFormat(_ sender: Any) {
   switch latlonFormatSeg.selectedSegmentIndex
   {
   case 0:
     print("show lat/lon format as DMS")
     appSettings.latlonFormatIsDMS = true
   case 1:
     print("show lat/lon format as decimal")
     appSettings.latlonFormatIsDMS = false
   default:
     print("show lat/lon format as DMS")
     appSettings.latlonFormatIsDMS = true
   }
   saveSettings(appSettings)
      let pointXY:CGPoint = (self.latlonFormatSeg.superview?.convert(self.latlonFormatSeg.frame.origin, to: nil))!
      self.scrollView.contentOffset = CGPoint(x:0, y:pointXY.y)
 }
  
  
  
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    return pickerData.count
  }
  
//  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
//  {
//       return pickerData[row]
//   }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
//    print("eventDayFormatPicker row=",row,"   eventDayFormatPicker value=",pickerData[row])
    appSettings.eventDayFormat = row
    saveSettings(appSettings)
  }
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
  {
    var label = UILabel()
    if let v = view
    {
      label = v as! UILabel
    }
    label.font = UIFont (name: "Helvetica", size: 17)
    label.text =  pickerData[row]
    label.textAlignment = .center

    return label
  }
  
  
}
