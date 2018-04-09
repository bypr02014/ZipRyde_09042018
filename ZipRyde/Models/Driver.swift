//
//  Driver.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/2/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct Driver {
    var latitude : String?
    var longitude : String?
    var bookingId : Int?
    var cabTypeId : Int?
    var cabType : String?
    var customerId : Int?
    var driverId : Int?
    var name : String?
    var mobile : String?
    var sourceLocAddress : String?
    var destinationLocAddress : String?
    var sourceLocCordinate : CLLocation?
    var destinationLocCordinate : CLLocation?
    var suggestedPrice : Float?
    var offeredPrice : Float?
    var driverStatus : String?
    var noOfPassengers : Int?
    var vehicleNumber : String?
    var bookingStatus : String?
    var bookingStatusCode : String?
    var arrivalTime : String?
    var driverPhoto : UIImage?
    
}
