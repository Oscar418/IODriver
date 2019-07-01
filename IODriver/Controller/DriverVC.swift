//
//  DriverVC.swift
//  IODriver
//
//  Created by Oscar on 2018/09/03.
//  Copyright © 2018 Oscar. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth

class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var centerMapBtn: UIButton!
    @IBOutlet weak var acceptRequestBtn: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    
    private let LOGOUT_SEGUE = "logout"
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    private var acceptedRequest = false
    private var driverCanceled = false
    private var timer = Timer()
    private var status = true
    private var DriverAcceptedReq = false
    
    var carTypeDriverSkill = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager()
        zoomInMap()
        makeButtonRound()
        getUserPreferredName()
        preventScreenFromSleeping()

        UberHandler.Instance.observeMessagesForDriver()
        UberHandler.Instance.delegate = self
        
        // Do any additional setup after loading the view.
    }

    private func initializeLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func customerRequest(title: String, message: String, requestAlive: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                
                self.acceptedRequest = true
                self.acceptRequestBtn.isHidden = false
                self.switchBtn.isEnabled = false
                self.DriverAcceptedReq = true
                
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(DriverVC.updateDriversLocation), userInfo: nil, repeats: true)
                
                //getting driverUID
                let DriverID = Auth.auth().currentUser!.uid
                
                //inform that we accetped request
                UberHandler.Instance.requestAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude), driverUID: DriverID)
                
            })
            
            let cancel = UIAlertAction(title: "Decline", style: .default, handler: nil)
            
            alert.addAction(accept)
            alert.addAction(cancel)
        } else {
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(ok)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func getUserPreferredName() {
        
        //Get userID
        let userID = Auth.auth().currentUser?.uid
        
        //Getting user preferred name
        DBProvider.Instance.dbRef.child("drivers").child(userID!).child("data").observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let username = value?["preferredName"] as? String
            
            UberHandler.Instance.driver = username!
        }
    }
    
    func makeButtonRound() {
        
        centerMapBtn.layer.cornerRadius = centerMapBtn.frame.size.width / 2
        centerMapBtn.layer.masksToBounds = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the coordinates from the locationManager
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            myMap.removeAnnotations(myMap.annotations)
            
            if riderLocation != nil {
                
                if acceptedRequest {
                    
                    let riderAnnotation = MKPointAnnotation()
                    
                    riderAnnotation.coordinate = riderLocation!
                    riderAnnotation.title = "Rider's Location"
                    
                    myMap.addAnnotation(riderAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = userLocation!
            annotation.title = "Your Location"
            myMap.addAnnotation(annotation)
            
        }
    }
    
    //Converting coordinates to actual city name
    func fetchCityAndCountry(location: CLLocation, completion: @escaping (_ street: String?, _ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.name,
                       placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    func zoomInMap() {
        
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            myMap.setRegion(region, animated: true)
        }
    }
    
    func acceptRequest(riderName: String, lat: Double, long: Double, carTypeNeedByCustomer: String) {
        
        //Get userID
        let userID = Auth.auth().currentUser?.uid
        
        //Getting car type and displaying the accept popup
        DBProvider.Instance.dbRef.child("drivers").child(userID!).child("data").observeSingleEvent(of: .value) { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let carType = value?["cartype"] as? String
            
            self.carTypeDriverSkill = carType!
            
            print("this is the skill the driver has \(self.carTypeDriverSkill)")
            print("this is the type of driver the customer wants \(carTypeNeedByCustomer)")
            
            if self.status == true && self.carTypeDriverSkill == carTypeNeedByCustomer {
                
                let location = CLLocation(latitude: lat, longitude: long)
                
                self.fetchCityAndCountry(location: location) { street, city, country, error in
                    guard let street = street, let city = city, let country = country, error == nil else { return }
                    print(city + ", " + country)  // Rio de Janeiro, Brazil
                    
                    if !self.acceptedRequest {
                        self.customerRequest(title: "Request", message: "\(riderName) has requested at this location \(street), \(city), \(country)", requestAlive: true)
                    }
                }
            } else {
                print("The driver is offline")
            }
            
        }
    }
    
    func riderCanceled() {
        
        if !driverCanceled {
            
            if DriverAcceptedReq == true {
                
                //cancel request from driver's perspective
                UberHandler.Instance.cancelRequestForDriver()
                self.acceptedRequest = false
                self.acceptRequestBtn.isHidden = true
                self.switchBtn.isEnabled = true
                
                customerRequest(title: "Request Canceled", message: "The Customer has canceled the request", requestAlive: false)
            }else {
                    print("This driver currently has no trip")
            }
        }
    }
    
    func driverCanceledFunction() {
        
        DriverAcceptedReq = false
        acceptedRequest = false
        acceptRequestBtn.isHidden = true
        switchBtn.isEnabled = true
        timer.invalidate()
        
    }
    
    @IBAction func cancelRequest(_ sender: Any) {
        
        if acceptedRequest {
            
            driverCanceled = true
            acceptRequestBtn.isHidden = true
            switchBtn.isEnabled = true
            DriverAcceptedReq = false
            UberHandler.Instance.cancelRequestForDriver()
            timer.invalidate()
        }
    }
    
    func updateRidersLocation(lat: Double, long: Double) {
        
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    @objc func updateDriversLocation() {
        
        UberHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    @IBAction func changeStatus(_ sender: UISwitch) {
        
        if (sender.isOn == true) {
            
            status = true
            statusLabel.text = "Online"
        } else {
            
            status = false
            statusLabel.text = "Offline"
        }
        
        UberHandler.Instance.observeMessagesForDriver()
        acceptRequest(riderName: String(), lat: Double(), long: Double(), carTypeNeedByCustomer: String())
        
    }
    
    @IBAction func centerLocation(_ sender: Any) {
        
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            myMap.setRegion(region, animated: true)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        
        if AuthProvider.Instance.logOut() {
            
            if acceptedRequest {
                DriverAcceptedReq = false
                acceptRequestBtn.isHidden = true
                switchBtn.isEnabled = true
                UberHandler.Instance.cancelRequestForDriver()
                timer.invalidate()
            }
            self.performSegue(withIdentifier:self.LOGOUT_SEGUE, sender: nil)
        } else {
            // Probleming logging out
            
            customerRequest(title: "Logout Error", message: "We could not log you out in the moment, Please try again", requestAlive: false)
        }

    }

}
