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
    
    @IBOutlet weak var topConstrauntHeight: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var changeProfileBtn: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    
    var imagePicker:UIImagePickerController!
    
    private var datePicker: UIDatePicker?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        profileImage.clipsToBounds = true
        changeProfileBtn.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        //usernameTextField
        usernameTextField.backgroundColor = UIColor.clear
        usernameTextField.tintColor = UIColor.blue
        usernameTextField.textColor = UIColor.blue
        let bottomLayerUsername = CALayer()
        bottomLayerUsername.frame = CGRect(x: 0, y: 30, width: 300, height: 0.6)
        bottomLayerUsername.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1).cgColor
        usernameTextField.layer.addSublayer(bottomLayerUsername)
        
        //dateTextField
        dateTextField.backgroundColor = UIColor.clear
        dateTextField.tintColor = UIColor.blue
        dateTextField.textColor = UIColor.blue
        let bottomLayerDate = CALayer()
        bottomLayerDate.frame = CGRect(x: 0, y: 30, width: 300, height: 0.6)
        bottomLayerDate.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1).cgColor
        dateTextField.layer.addSublayer(bottomLayerDate)
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(SignupViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        dateTextField.inputView = datePicker
        
        //emailTextField
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.blue
        emailTextField.textColor = UIColor.blue
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 30, width: 300, height: 0.6)
        bottomLayerEmail.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        //passwordTextField
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.blue
        passwordTextField.textColor = UIColor.blue
        let bottomLayerPassword = CALayer()
        bottomLayerPassword.frame = CGRect(x: 0, y: 30, width: 300, height: 0.6)
        bottomLayerPassword.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        //set show label error
        setupElement()
    }
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc func openImagePicker(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func validateFields() -> String? {
        
        
        if  usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            dateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all Fields."
        }
        
        return nil
        
    }
    
    
    
    
    @IBAction func dismiss_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }//ปุ่มเป็นสมาชิกแล้ว (ปิดหน้าสมัครสมาชิก)
    
    
    
    
    @IBAction func sisnupBtn_touchInside(_ sender: Any) {
        
        //popup ยังไม่เสร็จ
        topConstrauntHeight.constant = 0;
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        print("Clicked")
        
        //keyboard
        view.endEditing(true)
        
        //validateFields
        let error = validateFields()
        
        // show error
        if  error != nil {
            showError(error!)
        }
        else {
            guard let username = usernameTextField.text else { return }
            guard let email = emailTextField.text else { return }
            guard let birthday = dateTextField.text else { return }
            guard let pass = passwordTextField.text else { return }
            guard let image = profileImage.image else { return }
            
            //create user
            Auth.auth().createUser(withEmail: email, password: pass) { user, error in
                
                // check error
                if error == nil && user != nil {
                    
                    print("User created!")
                    self.transitionToWelcome()
                    
                    // 1. Upload the profile image to Firebase Storage
                    self.uploadProfileImage(image) { url in
                        
                        if url != nil {
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.displayName = username
                            changeRequest?.photoURL = url
                            
                            changeRequest?.commitChanges { error in
                                if error == nil {
                                    print("User display name changed!")
                                    
                                    self.saveProfile(username: username, email: email, birthday: birthday, profileImageURL: url!) { success in
                                        if success {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                    
                                } else {
                                    self.showError("Error: \(error!.localizedDescription)")
                                    print("Error: \(error!.localizedDescription)")
                                }
                            }
                        } else {
                            self.showError("Error unable to upload profile image")
                            // Error unable to upload profile image
                        }
                    }
                    
                } else {
                    self.showError("Error: \(error!.localizedDescription)")
                    print("Error: \(error!.localizedDescription)")
                }
            }
        }
    }//ปุ่มรับข้อมูลสมัครสมาชิก
    
    // 1. upload image to firebase storage
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    completion(url)
                    // success!
                }
            } else {
                // failed
                completion(nil)
            }
        }
    }
    
    // 2. save profile to firebase database
    func saveProfile(username:String, email:String, birthday:String, profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var db: Firestore!
        db = Firestore.firestore()
        db.collection("users").addDocument(
            data: [ "uid": uid,
                    "username": username,
                    "email": email,
                    "birthday":birthday,
                    "photoURL": profileImageURL.absoluteString,
                    "createdAt": Date()]
                as [String:Any]) { (error) in
                    if error != nil {
                        self.showError("Error saving user data")
                    }
        }
    }
    
    func setupElement() {
        self.errorLabel.alpha = 0
    }
    
    func showError(_ message:String) {
        // show error
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToWelcome(){
        registerBtn.isUserInteractionEnabled = false
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil{
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                let maintabbarViewController = self.storyboard?.instantiateViewController (identifier:Constants.Storyboard.MaintabbarViewController) as? MaintabbarViewController
                maintabbarViewController?.selectedIndex = 3
                self.view.window?.rootViewController = maintabbarViewController
                self.view.window?.resignKey()
            }
        }
        
    }
    
}


extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImage.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
