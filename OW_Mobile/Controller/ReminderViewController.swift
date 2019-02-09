//
//  ReminderViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 1/30/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController
{
  @IBOutlet weak var alertsView: UIView!
  @IBOutlet weak var alertsTimeView: UIView!
  @IBOutlet weak var prevDayView: UIView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.alertsView.layer.cornerRadius = 10
    self.alertsTimeView.layer.cornerRadius = 10
    self.prevDayView.layer.cornerRadius = 10
  }
  
}
