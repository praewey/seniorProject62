//
//  SignupViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 20/12/2562 BE.
//  Copyright © 2562 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class SignupViewController: UIViewController {

    
        @IBOutlet weak var profileImage: UIImageView!
        @IBOutlet weak var usernameTextField: UITextField!
        @IBOutlet weak var emailTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        @IBOutlet weak var errorLabel: UILabel!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            profileImage.layer.cornerRadius = 20
            profileImage.clipsToBounds = true
            
            usernameTextField.backgroundColor = UIColor.clear
            usernameTextField.tintColor = UIColor.blue
            usernameTextField.textColor = UIColor.blue
            let bottomLayerUsername = CALayer()
            bottomLayerUsername.frame = CGRect(x: 0, y: 30, width: 350, height: 0.6)
            bottomLayerUsername.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1).cgColor
            usernameTextField.layer.addSublayer(bottomLayerUsername)
            
            
            
            emailTextField.backgroundColor = UIColor.clear
            emailTextField.tintColor = UIColor.blue
            emailTextField.textColor = UIColor.blue
            let bottomLayerEmail = CALayer()
            bottomLayerEmail.frame = CGRect(x: 0, y: 30, width: 350, height: 0.6)
            bottomLayerEmail.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1).cgColor
            emailTextField.layer.addSublayer(bottomLayerEmail)
            
            
            passwordTextField.backgroundColor = UIColor.clear
            passwordTextField.tintColor = UIColor.blue
            passwordTextField.textColor = UIColor.blue
            let bottomLayerPassword = CALayer()
            bottomLayerPassword.frame = CGRect(x: 0, y: 30, width: 350, height: 0.6)
            bottomLayerPassword.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1).cgColor
            passwordTextField.layer.addSublayer(bottomLayerPassword)

            setupElement() //set show label error
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func validateFields() -> String? {
        

        if  usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all Fields."
        }

        return nil
        
    }
    
    
    
        
        @IBAction func dismiss_onClick(_ sender: Any) {
            dismiss(animated: true, completion: nil)
        }//ปุ่มเป็นสมาชิกแล้ว (ปิดหน้าสมัครสมาชิก)
    
    
    
    
        @IBAction func sisnupBtn_touchInside(_ sender: Any) {
            view.endEditing(true) //keyboard
            //validateFields
            let error = validateFields()
            
            // show error
            if  error != nil {
                showError(error!)
            }
            else {
                
                let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                
                //create user
                Auth.auth().createUser(withEmail: email!, password: password!) { (result, err) in
                    
                     // check error
                    if  err != nil {
                        self.showError(" Error createing user")
                    }
                    else{
                        // user create successful
                        var db: Firestore!
                        db = Firestore.firestore()
                        
                        db.collection("users").addDocument(data: ["username": username!, "email": email!, "uid": result!.user.uid]) { (error) in
                            if error != nil {
                                self.showError("Error saving user data")
                            }
                        }
                        self.transitionToWelcome()
                        
                    }
                }
            }
            
            
        }//ปุ่มรับข้อมูลสมัครสมาชิก
    func setupElement() {
           self.errorLabel.alpha = 0
       }
    
    func showError(_ message:String) {
         // show error
            errorLabel.text = message
            errorLabel.alpha = 1
    }
    
    func transitionToWelcome(){
        let welcomeViewController = storyboard?.instantiateViewController (identifier:Constants.Storyboard.WelcomeViewController) as? WelcomeViewController
        
        view.window?.rootViewController = welcomeViewController
        view.window?.makeKeyAndVisible()
        
    }
        
}


extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
}
