//
//  UberHandler.swift
//  IODriver
//
//  Created by Oscar on 2018/09/10.
//  Copyright © 2018 Oscar. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class {
    
    func acceptRequest(riderName: String, lat: Double, long: Double, carTypeNeedByCustomer: String)
    func riderCanceled()
    func driverCanceledFunction()
    func updateRidersLocation(lat: Double, long: Double)
}

class UberHandler {
    
    private static let _instance = UberHandler()
    
    weak var delegate: UberController?
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    static var Instance: UberHandler {
        return _instance
    }
    
    func observeMessagesForDriver() {
        
        // Customer requested
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {
            (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        
                        //inform the driver VC
                        self.delegate?.acceptRequest(riderName: data[Constants.NAME] as! String, lat: latitude, long: longitude, carTypeNeedByCustomer: data[Constants.CARTYPENEEDBYCUSTOMER] as! String)
                    }
                }
                
                if let name = data[Constants.NAME] as? String {
                    self.rider = name
                }
            }
            
            //Rider canceled request
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved, with: { (snapshot: DataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.rider {
                            self.rider = ""
                            self.delegate?.riderCanceled()
                        }
                    }
                }
            })
        }
        
        //Rider updating location
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.updateRidersLocation(lat: lat, long: long)
                    }
                }
            }
        }
        
        //Driver accepts request
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver_id = snapshot.key
                    }
                }
            }
        }
        
        //Driver cancel request
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.delegate?.driverCanceledFunction()
                    }
                }
            }
        }
    }
    
    func requestAccepted(lat: Double, long: Double, driverUID: String) {
        
        let data: Dictionary<String, Any> = [Constants.NAME: driver, Constants.LATITUDE: lat, Constants.LONGITUDE: long, Constants.DRIVERUID: driverUID]
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
    }
    
    func cancelRequestForDriver() {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).removeValue()
    }
    
    func updateDriverLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
}
