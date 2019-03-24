//
//  DetailViewController.swift
//  OW_Mobile
//
//  Created by John Grismore on 3/23/19.
//  Copyright © 2019 John Grismore. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  var selection: String!
  
  @IBOutlet weak var detailLbl: UILabel!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    detailLbl.text = selection
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
