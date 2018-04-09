//
//  Ride.swift
//  ZipRyde
//
//  Created by Ashish jha on 10/15/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct Ride {
    var sourceLocAddress : String?
    var destinationLocAddress : String?
    var driverImage : Data?
    var date : String?
    var time : String?
    var crn : String?
    var offeredPrice : String?
    var suggestedPrice : String?
    var rideStatus : String?
    var cabType : String?
    var driverStatus : String?
    var userId : Int?
    var firstName : String?
    var lastName : String?
    var passengerCount : Int?
    var bookingId : String?
    var distanceInMiles : Float?
    var driverName : String?
    var vehicleNumber : String?
    var bookingStatus : String?
    var bookingStatusCode : String?
    var sourceLocCordinate : CLLocation?
    var destinationLocCordinate : CLLocation?
    var cabTypeId : Int?
    var driverId : Int?
    
}
