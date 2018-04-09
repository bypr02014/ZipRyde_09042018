//
//  Utility.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/2/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation

struct Utility {
    
    static func saveAccessToken(token : String) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(token, forKey: Constants.KAccessTokenString)
    }
    
    static func fetchAccessToken() -> String?  {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let accessToken = defaults.object(forKey: Constants.KAccessTokenString) {
            return accessToken as? String
        }
        return nil
    }
    
    static func saveDeviceToken(token : String) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(token, forKey: Constants.KDeviceTokenString)
    }
    
    static func fetchDeviceToken() -> String?  {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let accessToken = defaults.object(forKey: Constants.KDeviceTokenString) {
            return accessToken as? String
        }
        return nil
    }
    
    static func saveRiderDetail(_ riderDict : [String:Any]) {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(riderDict, forKey: Constants.KRiderDetailString)
    }
    
    static func updateRiderDetail(_ isDislaimerAccepted : Bool) {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let riderDict = defaults.object(forKey: Constants.KRiderDetailString) {
            var dict = riderDict as! [String : Any]
            dict["isDislaimerAccepted"] = isDislaimerAccepted
            defaults.set(dict, forKey: Constants.KRiderDetailString)
        }
    }
    
    static func saveBookingId(_ bookingId : String) {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let riderDict = defaults.object(forKey: Constants.KRiderDetailString) {
            var dict = riderDict as! [String : Any]
            dict["bookingId"] = bookingId
            defaults.set(dict, forKey: Constants.KRiderDetailString)
        }
    }
    
    static func deleteRiderDetail() {
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.KPasswordString)
        defaults.removeObject(forKey: Constants.KAccessTokenString)
        defaults.removeObject(forKey: Constants.KRiderDetailString)
    }

    static func fetchRiderDetail() -> [String:Any]?  {
        
        let defaults:UserDefaults = UserDefaults.standard
        if let riderDict = defaults.object(forKey: Constants.KRiderDetailString) {
            return riderDict as? [String : Any]
        }
        return nil
    }
    
    static func getWhiteCabImageBasedOnCabType(cabType: String) -> String {
        
        let cabTypes : [String : Any] = ["ZIP CAR" : "micro_white_color", "TAXI" : "sedan_white_color", "LIMO" : "suv_white_color"]
        return cabTypes[cabType] as! String
    }
    
    static func getBlackCabImageBasedOnCabType(cabType: String) -> String {
        
        let cabTypes : [String : Any] = ["ZIP CAR" : "micro_black_color", "TAXI" : "sedan_black_color", "LIMO" : "suv_black_color"]
        return cabTypes[cabType] as! String
    }
    
    static func getAppVersionNumber() -> String {
        
        var versionNumnber : String! = nil
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumnber = version
        }
        print(versionNumnber)
        return versionNumnber
    }
    
    static func getAppBuildNumber() -> Int {
        var buildNumnber : Int! = nil
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumnber = Int(version)
        }
        print(buildNumnber)
        return buildNumnber
    }
    
}
