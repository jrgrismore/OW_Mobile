//
//  ReportViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 11/1/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate
{
  
  var eventId: String?
  var stationId: Int?
  var astroName: String?
  var observedLocation: String?
  var pickerData: [String] = []
  var selectedRow: Int = 0
  
  @IBOutlet weak var astroNameLbl: UILabel!
  @IBOutlet weak var observedAtLbl: UILabel!
  @IBOutlet weak var observationPicker: UIPickerView!
  @IBOutlet weak var posDurStackView: UIStackView!
  @IBOutlet weak var submitBtn: UIButton!
  @IBOutlet weak var durationFld: UITextField!
  @IBOutlet weak var toolBar: UIToolbar!
  @IBOutlet weak var toolBarBack: UIBarButtonItem!
  @IBOutlet weak var commentFld: UITextField!
  
  // MARK: - View functions
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    observationPicker.delegate = self
    observationPicker.dataSource = self
    observationPicker.backgroundColor = .lightGray
    durationFld.backgroundColor = .lightGray
    commentFld.backgroundColor = .lightGray
    
    pickerData = ["Not reported","Observed a miss","Clouded out","Technical failure","Positive detection","No observation"]
    //dismiss keyboard after tap
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
    self.view.addGestureRecognizer(tap)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    astroNameLbl.text = astroName!
    observedAtLbl.text = "Observed at " + observedLocation!
    posDurStackView.isHidden = true
  }
  
  @IBAction func dismissVC(_ sender: Any)
  {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Picker functions
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if row == 4
    {
      posDurStackView.isHidden = false
      submitBtn.isEnabled = false
      submitBtn.alpha = 0.5
    } else {
      posDurStackView.isHidden = true
      submitBtn.isEnabled = true
      submitBtn.alpha = 1.0
    }
    selectedRow = row
  }
  
  // MARK: - Text functions
  @IBAction func textEditingChanged(_ sender: Any)
  {
    if durationFld == sender as! UITextField
    {
      
    }
  }
  
  @IBAction func textEdittingDidEnd(_ sender: Any)
  {
    if durationFld == sender as! UITextField
    {
      if let duration = Double(durationFld.text!)
      {
        //valid Double
        submitBtn.isEnabled = true
        submitBtn.alpha = 1.0
      } else {
        //invalid Double
        submitBtn.isEnabled = false
        submitBtn.alpha = 0.5
      }
    }
  }
  
  // MARK: - Report functions
  @IBAction func submitReport(_ sender: Any)
  {
    var duration: Double? = nil
    if selectedRow == 4
    {
      duration = Double(durationFld.text!)
    }
    //populate data structure
    let postReportData = ObservationReport.init(Outcome: selectedRow, Duration: duration, Comment: commentFld.text)
    //submit report
    OWWebAPI.shared.postReport(eventId: eventId!, stationId: stationId!, reportData: postReportData, completion: { (data, error) in
    })
    dismissVC(ReportViewController.self)
  }
  
  
}
