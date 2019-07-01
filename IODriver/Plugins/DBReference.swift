//
//  DBReference.swift
//  IODriver
//
//  Created by Oscar on 2018/09/05.
//  Copyright © 2018 Oscar. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider {
        return _instance
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var driversRef: DatabaseReference {
        return dbRef.child(Constants.Drivers)
    }
    
    // request reference
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.CUSTOMER_REQUEST)
    }
    
    // requestAccepted
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.REQUEST_ACCEPTED)
    }
    
    func saveUser(withID: String, email: String, name: String, surname: String, carType: String, contact: String, profileimageURL: String, password: String) {
        
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password,Constants.PRENAME: name, Constants.SURNAME: surname, Constants.CONTACT: contact, Constants.CARTYPE: carType , Constants.isRider: false, Constants.isApproved: false, Constants.IMAGEURL: profileimageURL]
        
        driversRef.child(withID).child(Constants.DATA).setValue(data)
    }
}
