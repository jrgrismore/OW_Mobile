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

        // Do any additional setup after loading the view.
      self.alertsView.layer.cornerRadius = 10
      self.alertsTimeView.layer.cornerRadius = 10
      self.prevDayView.layer.cornerRadius = 10
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
