//
//  EditProfileViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 25/1/2563 BE.
//  Copyright © 2563 Praewey Spokkokkak. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var saveProfileBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveProfileBtn.isEnabled = false
        saveProfileBtn.tintColor = UIColor.clear

    }
    
    @IBAction func backToProfile(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
