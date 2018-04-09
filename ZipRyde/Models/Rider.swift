//
//  Rider.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/31/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct Rider {
    var sourceLocAddress : String?
    var destinationLocAddress : String?
    var sourceLocCordinate : CLLocation?
    var destinationLocCordinate : CLLocation?
    var userId : Int?
    var firstName : String?
    var lastName : String?
    var cab : Cab?
    var fareList : [Float]?
    var passengerCount : Int?
    var isDislaimerAccepted : Bool = false
    var bookingId : String?
    var driverDetail : Driver?
    var distanceInMiles : Float?
    var mobileNumber : String?
    var emailId : String?
}



