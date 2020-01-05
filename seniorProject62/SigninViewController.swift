//
//  SigninViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 20/12/2562 BE.
//  Copyright © 2562 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SigninViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        setupElement()//set show label error



    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupElement() {
        self.errorLabel.alpha = 0
    }
    

    
    
    
    @IBAction func signinBtnTab(_ sender: Any) {
        
        view.endEditing(true) //keyboard
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil{
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                let maintabbarViewController = self.storyboard?.instantiateViewController (identifier:Constants.Storyboard.MaintabbarViewController) as? MaintabbarViewController

                self.view.window?.rootViewController = maintabbarViewController
                self.view.window?.resignKey()
            }
            
            
        }
    }
    


}
