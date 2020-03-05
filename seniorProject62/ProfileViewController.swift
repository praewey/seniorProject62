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
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var signinBtn: UIButton!
//    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var bgCurveProfileView: UIView!
    
    @IBOutlet weak var loginView: UIView!
    
    var user: [(username: String, email: String)]?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signOutBtn.layer.cornerRadius = signOutBtn.frame.size.width / 13
        signOutBtn.clipsToBounds = true
        
        signinBtn.layer.cornerRadius = signinBtn.frame.size.width / 13
        signinBtn.clipsToBounds = true
        
        bgCurveProfileView.layer.cornerRadius = bgCurveProfileView.frame.size.width / 8
        bgCurveProfileView.clipsToBounds = true
        
        if Auth.auth().currentUser?.uid == nil{
            print("ยังไม่ได้เข้าสู่ระบบ")
            loginView.isHidden = false
            editBtn.isEnabled = false
            editBtn.tintColor = UIColor.clear
            
        } else {
            print("เข้าสู่ระบบแล้ว")
            loginView.isHidden = true
            editBtn.isEnabled = true
            //            getProfile()
            db.collection("users").getDocuments { query, error in
                for user in query!.documents {
                    if user["uid"] as! String == Auth.auth().currentUser?.uid {
                        self.usernameLabel.text = user["username"] as? String
                        //                    print(self.usernameLabel.text)
                        self.emailLabel.text = user["email"] as? String
                        if let profilePictureURL = user["photoURL"] as? String
                        {
                            let url = URL(string: profilePictureURL)
                            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                if error != nil{
                                    print(error!)
                                    return
                                }
                                DispatchQueue.main.async {
                                    self.profilePicture?.image = UIImage(data: data!)
                                }
                            }).resume()
                        }
                    }
                    
                }
                
            }
        }
        
        
    }
    
    
    @IBAction func signOutBtnTab(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        print("ออกจากระบบแล้ว")
        self.transitionToWelcome()
    }
    
    @IBAction func editBtn(_ sender: Any) {
        
//        let editProfileViewController = self.storyboard?.instantiateViewController (identifier:Constants.Storyboard.EditProfileViewController) as? EditProfileViewController
//
//        self.view.window?.rootViewController = editProfileViewController
//        self.view.window?.resignKey()
        
        
    }
    //
    //    func getProfile() {
    //
    //        if Auth.auth().currentUser?.uid == nil {
    //            db.collection("users").getDocuments { query, error in
    //                for user in query!.documents {
    //                    if let profilePictureURL = user["photoURL"] as? String
    //                    {
    //                        self.usernameLabel.text = user["username"] as? String
    //                        print(self.usernameLabel.text)
    //                        self.emailLabel.text = user["email"] as? String
    //
    //                        let url = URL(string: profilePictureURL)
    //                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
    //                            if error != nil{
    //                                print(error!)
    //                                return
    //                            }
    //                            DispatchQueue.main.async {
    //                                self.profilePicture?.image = UIImage(data: data!)
    //                            }
    //                        }).resume()
    //                    }
    //                }
    //
    //            }
    //
    //        }
    //    }
    
    
    
    func transitionToWelcome() {
        let signinViewController = storyboard?.instantiateViewController (identifier:Constants.Storyboard.SigninViewController) as? SigninViewController
        
        view.window?.rootViewController = signinViewController
        view.window?.makeKeyAndVisible()
        
    }
    
    
}
