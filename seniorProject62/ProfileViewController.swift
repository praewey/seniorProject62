//
//  ProfileViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 20/12/2562 BE.
//  Copyright © 2562 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutBtnTab(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.transitionToWelcome()
    }
    
    func transitionToWelcome(){
        let signinViewController = storyboard?.instantiateViewController (identifier:Constants.Storyboard.SigninViewController) as? SigninViewController
        
        view.window?.rootViewController = signinViewController
        view.window?.makeKeyAndVisible()

    }
    

}
