//
//  AccountViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 1/30/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
