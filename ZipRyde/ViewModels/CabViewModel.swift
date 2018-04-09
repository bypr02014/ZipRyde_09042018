//
//  CabDataSource.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/2/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation

struct CabViewModel {
    
    func fetchAllCabTypes (callback: @escaping ([Cab]?, String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getAllCabTypes"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            do {
                let accessToken: String = Utility.fetchAccessToken()!
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
                request.httpMethod = "GET"

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]] {
                                var cabDetail: [Cab] = [Cab]()

                                for dictionary in response {
                                    var cab = Cab()
                                    cab.isEnable = dictionary["isEnable"] as? Int
                                    cab.seatingCapacity = dictionary["seatingCapacity"] as? Int
                                    cab.level = dictionary["level"] as? Int
                                    cab.type = dictionary["type"] as? String
                                    cab.pricePerUnit = dictionary["pricePerUnit"] as? Float
                                    cab.cabTypeId = dictionary["cabTypeId"] as? Int
                                    cabDetail.append(cab)

                                }
                                callback(cabDetail, nil, httpResponse.statusCode)
                            }
                        }
                            else if(httpResponse.statusCode == Constants.KSessionLogOutErrorCode) {
                                if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                    print(response)
                                    let message: String = response["message"] as! String
                                    callback(nil, message, httpResponse.statusCode)
                                }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, nil, Constants.KNetworkErrorCode)
            }
        }
    }


    func fetchNearByActiveDrivers (_ latitude: String, _ longitude: String, callback: @escaping (Driver?, String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getNearByActiveDrivers"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let locationDetail: [String: Any] = ["fromLatitude": latitude, "fromLongitude": longitude]

            do {

                let jsonData = try JSONSerialization.data(withJSONObject: locationDetail, options: .prettyPrinted)
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

                        if(httpResponse.statusCode == 200) {
                            if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]] {

                                var driver: Driver?
                                for dictionary in response {

                                    driver = Driver ()
                                    driver?.latitude = String(describing: dictionary["latitude"]!)
                                    driver?.longitude = String(describing: dictionary["longitude"]!)
                                    driver?.driverId = dictionary["userId"] as? Int
                                    driver?.cabType = dictionary["cabType"] as? String
                                    driver?.cabTypeId = dictionary["cabTypeId"] as? Int
                                    driver?.bookingId = dictionary["bookingId"] as? Int
                                    driver?.bookingStatus = dictionary["bookingStatus"] as? String
                                    driver?.bookingStatusCode = dictionary["bookingStatusCode"] as? String
                                    break
                                }
                                callback(driver, nil, httpResponse.statusCode)
                            }
                        }
                            else if(httpResponse.statusCode == Constants.KSessionLogOutErrorCode) {
                                if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                    print(response)
                                    let message: String = response["message"] as! String
                                    callback(nil, message, httpResponse.statusCode)
                                }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, nil, Constants.KNetworkErrorCode)
            }
        }
    }

    func calculateTimeBetweenCoordinates(_ sourceLatitude: String, _ sourceLongitude: String, _ destinationLatitude: String,
                                         _ destinationLongitude: String, callback: @escaping (String?) -> ()) {

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLatitude),\(sourceLongitude)&destination=\(destinationLatitude),\(destinationLongitude)&sensor=true&mode=driving&key=\(Constants.KGoogleAPIServerKeyString)")!

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
                else {
                    do {
                        if let json: [String: Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                            guard let routes = json["routes"] as? NSArray else {
                                return
                            }
                            if (routes.count > 0) {
                                let routeArray = ((routes.object(at: 0)) as! NSDictionary).object(forKey: "legs") as! NSArray
                                let durationDetail = (routeArray.object(at: 0) as! NSDictionary).object(forKey: "duration")
                                let time: String = ((durationDetail as! NSDictionary).object(forKey: "text") as? String)!
                                callback(time)
                            }
                                else {
                                    callback("NO ROUTES")
                            }
                        }
                    }
                    catch {
                        print("error in JSONSerialization")
                    }
            }
        })
        task.resume()
    }

    func getAllNYOPByCabTypeDistAndNoOfPassenger(_ distance: String, _ cabTypeId: Int, _ passengerCount: Int, callback: @escaping ([Float]?, String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getAllNYOPByCabTypeDistAndNoOfPassenger"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let detail: [String: Any] = ["distanceInMiles": distance, "cabTypeId": cabTypeId, "noOfPassengers": passengerCount]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: detail, options: .prettyPrinted)
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
                            if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]] {

                                var cabFareArray = [Float]()
                                for dictionary in response {
                                    let fareValue = dictionary["price"] as? String
                                    let fare: Float = Float(fareValue!)!
                                    let finalFare = fare.roundTwoDigit
                                    cabFareArray.append(finalFare)
                                }
                                let sortedFareArray = cabFareArray.sorted(by: { $0 < $1 })
                                callback(sortedFareArray, nil, httpResponse.statusCode)
                            }
                        }
                            else if(httpResponse.statusCode == Constants.KSessionLogOutErrorCode) {
                                if let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] {
                                    print(response)
                                    let message: String = response["message"] as! String
                                    callback(nil, message, httpResponse.statusCode)
                                }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, nil, Constants.KNetworkErrorCode)
            }
        }
    }
}

extension Float {
    var roundTwoDigit: Float {
        return roundf(100 * self) / 100
    }
}




