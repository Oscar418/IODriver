//
//  RegistrationFirstViewController.swift
//  IODriver
//
//  Created by Oscar on 2018/09/26.
//  Copyright © 2018 Oscar. All rights reserved.
//

import UIKit

class RegistrationFirstViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageViewCustom: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var regScrollView: UIScrollView!
    @IBOutlet weak var contactNumberTextField: UITextField!
    
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
        
        regScrollView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    
    //import image using camera
    @IBAction func importImage(_ sender: Any) {
        
        let image = UIImagePickerController()
        
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.camera
        image.allowsEditing = false
        
        self.present(image, animated: true) {
            // after complete
        }
    }
    
    //import image from photos
    @IBAction func importImageFromPhotos(_ sender: Any) {
        
        let image = UIImagePickerController()
        
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true) {
            // after complete
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
        regScrollView.contentInset =  contentInset
    }
    func keyboardWillHide(notification: Notification) {
        regScrollView.contentInset = UIEdgeInsets.zero
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageViewCustom.image = image
        } else {
            //display error adding image here
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //Alert
    private func alertTheUser(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "toSecondRegistration"){
            
            if nameTextField.text != "" && surnameTextField.text != ""{
            
            let toSecondRegistrationController = segue.destination as! RegistrationViewController
            toSecondRegistrationController.nameFromPrev = nameTextField.text!
            toSecondRegistrationController.surnameFromPrev = surnameTextField.text!
            toSecondRegistrationController.imageFromPrev = imageViewCustom
            toSecondRegistrationController.contactNumberFromPrev = contactNumberTextField.text!
            } else {
                
                alertTheUser(title: "Some Fields Are Missing", message: "Please make sure you have filled in everything")
            }
        }
    }
}
