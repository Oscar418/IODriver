//
//  RegistrationViewController.swift
//  IODriver
//
//  Created by Oscar on 2018/09/13.
//  Copyright © 2018 Oscar. All rights reserved.
//

import UIKit
import Firebase
class RegistrationViewController: UIViewController, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //    MARK: - let PROPERTIES
    private let RIDER_SEGUE = "RiderVC"
    private let typeOfCar = ["Select type of driver","Car", "Van", "Lorry"]
    
    //    MARK: - var PROPERTIES
    var buttonSelected: Bool = false
    var pickerCar = "black"
    var surnameFromPrev = ""
    var nameFromPrev = ""
    var contactNumberFromPrev = ""
    var imageFromPrev = UIImageView()
    var imageURLFromPrev = ""
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var passwordBtn: UIButton!
    @IBOutlet weak var RegScrollView: UIScrollView!
    @IBOutlet weak var loadViewCustom: UIView!
    
    
    
    //   MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    //   MARK: - VIEW WILL DISAPPEAR
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeObservers()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        RegScrollView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func passwordChange(_ sender: Any) {
        
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        confirmPasswordTextField.isSecureTextEntry = !confirmPasswordTextField.isSecureTextEntry
        
        if buttonSelected == false{
            
            let pressedButtonImage = UIImage(named: "hide") as UIImage!
            passwordBtn.setImage(pressedButtonImage, for: UIControlState.normal)
            buttonSelected = true
        }else if buttonSelected == true{
            let pressedButtonImage = UIImage(named: "showpassio") as UIImage!
            passwordBtn.setImage(pressedButtonImage, for: UIControlState.normal)
            buttonSelected = false
        }
    }
    @IBAction func signup(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != ""{
            
            if passwordTextField.text! == confirmPasswordTextField.text! {
                
                LottieActivityIndicator()
                
                dismissKeyboard()
                
                loadViewCustom.isHidden = false
                
                //creating unique string for image name
                let imageName = NSUUID().uuidString
                
                //uploading image
                let storageRef = Storage.storage().reference().child("\(imageName).png")
                if let uploadData = UIImagePNGRepresentation(self.imageFromPrev.image!) {
                    
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print("this is the firebase error \(error)")
                            return
                        }
                        
                        storageRef.downloadURL { (url, error) in
                            
                            if error != nil {
                                print("this is the URL error \(error)")
                                return
                            } else {
//                                let imageURL = (url?.absoluteString)!
                                
//                                print("this is the second image url \(imageURL)")
                                
                            }
                            
                            let selectedValue = self.typeOfCar[self.pickerView.selectedRow(inComponent: 0)]
                            
                            AuthProvider.Instance.signUp(withEmail: self.emailTextField.text!, name: self.nameFromPrev, surname: self.surnameFromPrev, carType: selectedValue, contact: self.contactNumberFromPrev, profileimageURL: (url?.absoluteString)!, password: self.passwordTextField.text!, loginHandler: { (message) in
                                
                                if message != nil {
                                    self.hideHUD()
                                    self.loadViewCustom.isHidden = true
                                    self.alertTheUser(title: "The was a problem registering you", message: message!)
                                } else {
                                    self.hideHUD()
                                    self.passwordTextField.text = ""
                                    AuthProvider.Instance.logOut()
                                    self.alertTheUserWithAction(title: "Registration Successful", message: "Please visit one of our offices to get approved as our driver and then you will be able to login 😊")
                                    
                                    print("Creating user successful")
                                }
                            })
                            
                        }
                        print(metadata)
                        
                    })
                }
                
                
            } else {
                alertTheUser(title: "Password Error", message: "Entered Password and Confirm Password do not match")
            }
            
        } else {
            
            alertTheUser(title: "Some Fields Are Missing", message: "Please make sure you have filled in everything")
        }
    }
    
    @objc func didTapView(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    func addObservers() {
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) {
            notification in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) {
            notification in
            self.keyboardWillHide(notification: notification)
        }
    }
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        RegScrollView.contentInset =  contentInset
    }
    func keyboardWillHide(notification: Notification) {
        RegScrollView.contentInset = UIEdgeInsets.zero
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return typeOfCar[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return typeOfCar.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let pickerCar = typeOfCar[row]
        
        print("this is the selected one \(pickerCar)")
    }
    
    //Alert
    private func alertTheUser(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func alertTheUserWithAction(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            
            let SignInVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
            self.present(SignInVC!, animated: true, completion: nil)
        }
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
