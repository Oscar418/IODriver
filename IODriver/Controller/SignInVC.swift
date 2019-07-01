//
//  SignInVC.swift
//  IODriver
//
//  Created by Oscar on 2018/08/30.
//  Copyright © 2018 Oscar. All rights reserved.
//

import UIKit
import FirebaseAuth
import SystemConfiguration

class SignInVC: UIViewController, UITextFieldDelegate {
    
    //    MARK: - let PROPERTIES
    private let DRIVER_SEGUE = "DriverVC"

    //    MARK: - var PROPERTIES
    var buttonSelected: Bool = false
    
    //    MARK: - IBOUTLETS
    @IBOutlet weak var loadViewCustom: UIView!
    @IBOutlet weak var passwordbtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //   MARK: - VIEW WILL APPEAR
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserIsAlreadyLoggedIn()
        checkInternetConnection()
        loadViewCustom.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func pushedPasswordbtn(_ sender: Any) {
        
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    
        if buttonSelected == false{
            
            let pressedButtonImage = UIImage(named: "hide") as UIImage!
            passwordbtn.setImage(pressedButtonImage, for: UIControlState.normal)
            buttonSelected = true
        }else if buttonSelected == true{
    let pressedButtonImage = UIImage(named: "showpassio") as UIImage!
    passwordbtn.setImage(pressedButtonImage, for: UIControlState.normal)
    buttonSelected = false
    }
    }
    
    // Login the user
    @IBAction func login(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            LottieActivityIndicator()
            dismissKeyboard()
            
            loadViewCustom.isHidden = false
            
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil {
                    self.loadViewCustom.isHidden = true
                    self.hideHUD()
                    self.alertTheUser(title: "Problem Logging in", message: message!)
                } else {
                    let userID = Auth.auth().currentUser?.uid
                    
                    //Getting isRider Bool
                    DBProvider.Instance.dbRef.child("drivers").child(userID!).child("data").observeSingleEvent(of: .value) { (snapshot) in
                        
                        let value = snapshot.value as? NSDictionary
                        let riderOrDriver = value?["isRider"] as? Bool
                        let isDrvierApproved = value?["isApproved"] as? Bool
                        
                        if riderOrDriver == false {
                            if isDrvierApproved == true {
                                self.hideHUD()
                                self.passwordTextField.text = ""
                                self.performSegue(withIdentifier:self.DRIVER_SEGUE, sender: nil)
                                print("Login successful")
                            } else {
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                                self.hideHUD()
                                self.loadViewCustom.isHidden = true
                                AuthProvider.Instance.logOut()
                                self.alertTheUser(title: "Pending Approval", message: "You haven't been approved yet, please visit one of our offices to complete the process")
                            }
                        }else {
                            self.emailTextField.text = ""
                            self.passwordTextField.text = ""
                            self.hideHUD()
                            self.loadViewCustom.isHidden = true
                            AuthProvider.Instance.logOut()
                            self.alertTheUser(title: "You are not a Driver", message: "Please use the Customer App")
                        }
                    }
                }
                
            })
        } else {
            
            alertTheUser(title: "Email and Password are required", message: "Please make sure you have filled in both the Email and Password fields")
        }
    }
    
    private func alertTheUser(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    //Check if user is logged in
    func checkIfUserIsAlreadyLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            print("User is already logged in")
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let RiderViewcontroller : DriverVC = mainStoryboard.instantiateViewController(withIdentifier: "DriverVC") as! DriverVC
            
            self.present(RiderViewcontroller, animated: true, completion: nil)
        } else {
            print("User hasn't logged in")
        }
    }
    
    //Check internet connection
    func checkInternetConnection(){
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            alertTheUser(title: "Connection Error", message: "Please make sure you have Internet Connection")
            
        }
        
    }

}
