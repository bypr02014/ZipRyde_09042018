//
//  BookingDataSource.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/3/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct BookingViewModel {

    func requestBooking (_ cabTypeId: Int, _ customerId: Int, _ bookingDateTime: String!, _ fromAddress: String, _ toAddress: String, _ geoLocationRequest: [String: Any], _ suggestedPrice: String, _ offeredPrice: String, _ noOfPassengers: String, callback: @escaping (String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/requestBooking"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }

            var bookingDetail: [String: Any] = ["cabTypeId": cabTypeId,
                "customerId": customerId,
                "from": fromAddress,
                "to": toAddress,
                "geoLocationRequest": geoLocationRequest,
                "suggestedPrice": suggestedPrice,
                "offeredPrice": offeredPrice,
                "noOfPassengers": noOfPassengers]
            if let bookingTime = bookingDateTime {
                bookingDetail["bookingDateTime"] = bookingTime
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bookingDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                print(response)
                                let bookingId = String(response["bookingId"] as! Int)
                                callback(bookingId, httpResponse.statusCode)
                            }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, Constants.KNetworkErrorCode)
            }
        }
    }

    func fetchBookingDetailByBookingId (_ bookingId: String, callback: @escaping (Driver?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getBookingByBookingId"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let bookingDetail: [String: Any] = ["bookingId": bookingId]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bookingDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                print(response)
                                var driver = Driver()
                                driver.name = response["driverName"] as? String
                                driver.bookingId = response["bookingId"] as? Int
                                driver.cabTypeId = response["cabTypeId"] as? Int
                                driver.cabType = response["cabType"] as? String
                                driver.customerId = response["customerId"] as? Int
                                driver.driverId = response["driverId"] as? Int

                                let suggestedPrice = response["suggestedPrice"] as? Float
                                driver.suggestedPrice = suggestedPrice?.roundTwoDigit

                                let offeredPrice = response["offeredPrice"] as? Float
                                driver.offeredPrice = offeredPrice?.roundTwoDigit

                                driver.driverStatus = response["driverStatus"] as? String
                                driver.noOfPassengers = response["noOfPassengers"] as? Int
                                driver.vehicleNumber = response["vehicleNumber"] as? String
                                driver.bookingStatus = response["bookingStatus"] as? String
                                driver.bookingStatusCode = response["bookingStatusCode"] as? String
                                let imageString = response["driverImage"] as? String
                                // if let imageStr = imageString {
                                //let dataa = imageString?.data(using: .base64)!
                                //driver.driverPhoto = getDriverImage(dataa)
                                //}
                                callback(driver, httpResponse.statusCode)
                            }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, Constants.KNetworkErrorCode)
            }
        }
    }

    func getDriverImage(_ imageData: Data?) -> UIImage {

        guard let image = imageData else {
            return UIImage(named: "placeholder")!
        }
        return UIImage(data: image)!
    }


    func fetchDriverLocation (_ driverId: Int, callback: @escaping (String?, String?, String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getGeoLocationByDriverId"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let driverDetail: [String: Any] = ["userId": driverId]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: driverDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, nil, nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                print(response)
                                let latitudeDouble = response["latitude"] as? NSNumber
                                let longitudeDouble = response["longitude"] as? NSNumber
                                
                                if((latitudeDouble != nil) && (longitudeDouble != nil)){
                                    let latitude = String(describing: latitudeDouble!)
                                    let longitude = String(describing: longitudeDouble!)
                                    let status = response["bookingStatus"] as? String
                                    callback(latitude, longitude, status, httpResponse.statusCode)
                                }else{
                                   callback(nil, nil, nil, httpResponse.statusCode)
                                }
                            }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, nil, nil, Constants.KNetworkErrorCode)
            }
        }
    }

    func updateBookingStatus (_ bookingId: String, callback: @escaping (String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/updateBookingStatus"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let bookingDetail: [String: Any] = ["bookingId": bookingId, "bookingStatus": "CANCELLED"]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bookingDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                let bookingStatus = response["bookingStatus"] as? String
                                callback(bookingStatus!, httpResponse.statusCode)
                            }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, Constants.KNetworkErrorCode)
            }
        }
    }

    func fetchDriverNumber (_ bookingId: String, callback: @escaping (String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getCallMaskingNumber"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                callback(nil, Constants.KNetworkErrorCode)
                return
            }
            let bookingDetail: [String: Any] = ["bookingId": bookingId]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bookingDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                let mobileNumber = response["mobileNumber"] as? String
                                callback(mobileNumber!, httpResponse.statusCode)
                            }
                        }else{
                            callback(nil, httpResponse.statusCode)
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, Constants.KNetworkErrorCode)
            }
        }
    }

    func fetchBookingDetail (_ bookingId: String, callback: @escaping (Rider?, Int, String?) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getBookingByBookingId"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let bookingDetail: [String: Any] = ["bookingId": bookingId]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bookingDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, Constants.KNetworkErrorCode, nil)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let responseDictionary = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                
                                let driverStatusCode = responseDictionary["driverStatusCode"] as! String
                                if(driverStatusCode != Constants.KDriverStatus_Completed && driverStatusCode != Constants.KDriverStatus_Cancelled && driverStatusCode != Constants.KBookingStatus_Scheduled) {
                                    var rider = Rider()
                                    rider.sourceLocAddress = responseDictionary["from"] as? String
                                    rider.destinationLocAddress = responseDictionary["to"] as? String
                                    let bookingId = responseDictionary["bookingId"] as! Int
                                    rider.bookingId = String(describing: bookingId)
                                    let geoLocationResponse = responseDictionary["geoLocationResponse"] as? [String: Any]

                                    rider.distanceInMiles = responseDictionary["distanceInMiles"] as? Float
                                    let toLatitude = geoLocationResponse!["toLatitude"] as! String
                                    let toLongitude = geoLocationResponse!["toLongitude"] as! String
                                    let fromLatitude = geoLocationResponse!["fromLatitude"] as! String
                                    let fromLongitude = geoLocationResponse!["fromLongitude"] as! String

                                    let destCoordinate = CLLocation(latitude: Double(toLatitude)!, longitude: Double(toLongitude)!)
                                    rider.destinationLocCordinate = destCoordinate
                                    
                                    let sourceCoordinate  = CLLocation(latitude: Double(fromLatitude)!, longitude: Double(fromLongitude)!)
                                    rider.sourceLocCordinate = sourceCoordinate

                                    var driver = Driver()
                                    driver.noOfPassengers = responseDictionary["noOfPassengers"] as? Int
                                    driver.vehicleNumber = responseDictionary["vehicleNumber"] as? String
                                    driver.name = responseDictionary["driverName"] as? String
                                    driver.driverId = responseDictionary["driverId"] as? Int
                                    driver.cabType = responseDictionary["cabType"] as? String
                                    //driver.driverPhoto =
                                    driver.driverStatus = responseDictionary["driverStatus"] as? String
                                    driver.suggestedPrice = responseDictionary["acceptedPrice"] as? Float
                                    driver.offeredPrice = responseDictionary["offeredPrice"] as? Float
                                    driver.bookingStatus = responseDictionary["bookingStatus"] as? String
                                    driver.cabTypeId = responseDictionary["cabTypeId"] as? Int
                                    rider.driverDetail = driver
                                    callback(rider, httpResponse.statusCode, nil)
                                }
                                callback(nil, httpResponse.statusCode, nil)
                            }
                        }else if((httpResponse.statusCode == Constants.KSessionLogOutErrorCode) || (httpResponse.statusCode == Constants.KAppUpgradationCode) ) {
                            if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                
                                print(responseJson ?? "No data")
                                let message: String = responseJson!["message"] as! String
                                callback(nil, httpResponse.statusCode, message)
                            }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, Constants.KNetworkErrorCode, nil)
            }
        }
    }

    func logOut (_ userId: Int, callback: @escaping (Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/logoutUser"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let userDetail: [String: Any] = ["userId": userId]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")
                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            callback(httpResponse.statusCode)
                        }else{
                            callback(httpResponse.statusCode)
                        }

                    }
                }
                task.resume()
            } catch {
                callback(Constants.KNetworkErrorCode)
            }
        }
    }

    func fetchPastRides (_ userId: Int, callback: @escaping ([Ride]?, String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getBookingByuserId"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let userDetail: [String: Any] = ["customerId": userId]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let responseArray = try? JSONSerialization.jsonObject(with: data!, options: []) as! [Any] {
                                if(responseArray.count > 0) {
                                    var rideList = [Ride]()
                                    for var i in 0..<(responseArray.count) {

                                        let dictionary = responseArray[i] as! [String: Any]
                                        var ride = Ride()
                                        ride.sourceLocAddress = dictionary["from"] as? String
                                        ride.destinationLocAddress = dictionary["to"] as? String
                                        // ride.driverImage =
                                        ride.driverStatus = dictionary["driverStatus"] as? String
                                        ride.cabType = dictionary["cabType"] as? String
                                        ride.rideStatus = dictionary["bookingStatus"] as? String
                                        ride.suggestedPrice = String(describing: (dictionary["suggestedPrice"] as? Float)!.roundTwoDigit)
                                        ride.offeredPrice = String( describing: (dictionary["offeredPrice"] as? Float)!.roundTwoDigit)
                                        ride.crn = dictionary["crnNumber"] as? String
                                        ride.driverName = dictionary["driverName"] as? String
                                        ride.userId = dictionary["customerId"] as? Int
                                        ride.vehicleNumber = dictionary["vehicleNumber"] as? String
                                        ride.bookingId = String(describing: dictionary["bookingId"] as! Int)
                                        ride.passengerCount = dictionary["noOfPassengers"] as? Int
                                        ride.cabType = dictionary["cabType"] as? String
                                        ride.bookingStatus = dictionary["bookingStatus"] as? String
                                        let geoLocationResponse = dictionary["geoLocationResponse"] as? [String: Any]
                                        
                                        let toLatitude = geoLocationResponse!["toLatitude"] as! String
                                        let toLongitude = geoLocationResponse!["toLongitude"] as! String
                                        let fromLatitude = geoLocationResponse!["fromLatitude"] as! String
                                        let fromLongitude = geoLocationResponse!["fromLongitude"] as! String
                                        
                                        let destCoordinate = CLLocation(latitude: Double(toLatitude)!, longitude: Double(toLongitude)!)
                                        ride.destinationLocCordinate = destCoordinate
                                        
                                        let sourceCoordinate  = CLLocation(latitude: Double(fromLatitude)!, longitude: Double(fromLongitude)!)
                                        ride.sourceLocCordinate = sourceCoordinate
                                        
                                        ride.cabTypeId = dictionary["cabTypeId"] as? Int
                                        ride.bookingStatusCode = dictionary["bookingStatusCode"] as? String
                                        ride.driverId = dictionary["driverId"] as? Int

                                        let bookingDateTime = dictionary["bookingDateTime"] as? String                                        
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                                        formatter.timeZone = TimeZone(abbreviation : "UTC")
                                        let utcTime = formatter.date(from: bookingDateTime!)
                                        
                                        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
                                        formatter.timeZone = TimeZone.current
                                        let localTime = formatter.string(from: utcTime!)
                                        let localTimeArray = localTime.characters.split{$0 == " "}.map(String.init)
                                        ride.date = localTimeArray[0]
                                        let time = localTimeArray[1]
                                        let clock = localTimeArray[2]
                                        ride.time = "\(time) \(clock)"

                                        rideList.append(ride)
                                    }
                                    callback(rideList, nil, httpResponse.statusCode)
                                }else {
                                    callback(nil, nil, Constants.KServerNoData)
                                }
                            }else {
                                callback(nil, nil, Constants.KServerNoData)
                            }
                        } else if(httpResponse.statusCode == Constants.KSessionLogOutErrorCode){
                            if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                
                                print(responseJson ?? "No data")
                                let message: String = responseJson!["message"] as! String
                                callback(nil, message, httpResponse.statusCode)
                            }
                        }else{
                            callback(nil, nil, httpResponse.statusCode)
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, nil, Constants.KNetworkErrorCode)
            }
        }
    }

    
    func fetchScheduleRides (callback: @escaping ([Ride]?, String?, Int) -> ()) {
        
        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {
            
            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getBookingByBookingStatus"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let userDetail: [String: Any] =  ["bookingStatus" : "ACCEPTED"]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")
                        
                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let responseArray = try? JSONSerialization.jsonObject(with: data!, options: []) as! [Any] {
                                if(responseArray.count > 0) {
                                    var rideList = [Ride]()
                                    for var i in 0..<(responseArray.count) {
                                        
                                        let dictionary = responseArray[i] as! [String: Any]
                                        var ride = Ride()
                                        ride.sourceLocAddress = dictionary["from"] as? String
                                        ride.destinationLocAddress = dictionary["to"] as? String
                                        // ride.driverImage =
                                        ride.driverStatus = dictionary["driverStatus"] as? String
                                        ride.cabType = dictionary["cabType"] as? String
                                        ride.rideStatus = dictionary["bookingStatus"] as? String
                                        ride.suggestedPrice = String(describing: (dictionary["suggestedPrice"] as? Float)!.roundTwoDigit)
                                        ride.offeredPrice = String( describing: (dictionary["offeredPrice"] as? Float)!.roundTwoDigit)
                                        ride.crn = dictionary["crnNumber"] as? String
                                        let bookingDateTime = dictionary["bookingDateTime"] as? String
                                        
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                                        formatter.timeZone = TimeZone(abbreviation : "UTC")
                                        let utcTime = formatter.date(from: bookingDateTime!)
                                        
                                        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
                                        formatter.timeZone = TimeZone.current
                                        let localTime = formatter.string(from: utcTime!)
                                        let localTimeArray = localTime.characters.split{$0 == " "}.map(String.init)
                                        ride.date = localTimeArray[0]
                                        let time = localTimeArray[1]
                                        let clock = localTimeArray[2]
                                        ride.time = "\(time) \(clock)"
                                        
                                        ride.driverName = dictionary["driverName"] as? String
                                        ride.userId = dictionary["customerId"] as? Int
                                        ride.vehicleNumber = dictionary["vehicleNumber"] as? String
                                        ride.bookingId = String(describing: dictionary["bookingId"] as! Int)
                                        ride.passengerCount = dictionary["noOfPassengers"] as? Int
                                        ride.cabType = dictionary["cabType"] as? String
                                        ride.bookingStatus = dictionary["bookingStatus"] as? String
                                        let geoLocationResponse = dictionary["geoLocationResponse"] as? [String: Any]
                                        
                                        let toLatitude = geoLocationResponse!["toLatitude"] as! String
                                        let toLongitude = geoLocationResponse!["toLongitude"] as! String
                                        let fromLatitude = geoLocationResponse!["fromLatitude"] as! String
                                        let fromLongitude = geoLocationResponse!["fromLongitude"] as! String
                                        
                                        let destCoordinate = CLLocation(latitude: Double(toLatitude)!, longitude: Double(toLongitude)!)
                                        ride.destinationLocCordinate = destCoordinate
                                        
                                        let sourceCoordinate  = CLLocation(latitude: Double(fromLatitude)!, longitude: Double(fromLongitude)!)
                                        ride.sourceLocCordinate = sourceCoordinate
                                        
                                        ride.cabTypeId = dictionary["cabTypeId"] as? Int
                                        ride.bookingStatusCode = dictionary["bookingStatusCode"] as? String
                                        ride.driverId = dictionary["driverId"] as? Int
                                        rideList.append(ride)
                                    }
                                    callback(rideList, nil, httpResponse.statusCode)
                                }
                            }
                        } else if(httpResponse.statusCode == Constants.KSessionLogOutErrorCode){
                            if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                
                                print(responseJson ?? "No data")
                                let message: String = responseJson!["message"] as! String
                                callback(nil, message, httpResponse.statusCode)
                            }
                        }else{
                            callback(nil, nil, httpResponse.statusCode)
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, nil, Constants.KNetworkErrorCode)
            }
        }
    }
    
    func reportLostItem (_ bookingId: String, _ comments: String,  callback: @escaping (Int) -> ()) {
        
        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {
            
            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/saveLostItem"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let userDetail: [String: Any] =  ["bookingId" : bookingId,
                                              "comments"  : comments ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userDetail, options: .prettyPrinted)
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "POST"
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")
                        
                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            callback(httpResponse.statusCode)
                        }else{
                            callback(httpResponse.statusCode)
                        }
                    }
                }
                task.resume()
            } catch {
                callback(Constants.KNetworkErrorCode)
            }
        }
    }
}










