//
//  VerifyLogInUserViewModel.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/26/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation

struct VerifyLogInUserViewModel {

    func verifyLogin (_ userType: String, _ mobileNumber: String, _ password: String, _ deviceToken: String, _ overrideSessionToken: Int, callback: @escaping (Rider?, String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/verifyLogInUser"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }

            print(zipRydeURL)
            
            let newRider: [String: Any] = ["userType": userType,
                "mobileNumber": mobileNumber,
                "password": password,
                "deviceToken": deviceToken,
                "appName": "ZIPRYDE",
                "mobileOS": "IOS",
                "versionNumber": Utility.getAppVersionNumber(),
                "buildNo": Utility.getAppBuildNumber(),
                "overrideSessionToken": overrideSessionToken]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: newRider, options: .prettyPrinted)
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
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
                            if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {

                                var rider = Rider()
                                rider.userId = responseJson!["userId"] as? Int
                                rider.bookingId = String(describing: responseJson?["bookingId"] as! Int)
                                rider.firstName = (responseJson!["firstName"] as? String)
                                rider.lastName = (responseJson!["lastName"] as? String)
                                rider.mobileNumber = (responseJson!["mobileNumber"] as? String)
                                rider.emailId = (responseJson!["emailId"] as? String)

                                let accessToken: String = responseJson!["accessToken"] as! String
                                Utility.saveAccessToken(token: accessToken)
                                callback(rider, nil, httpResponse.statusCode)
                            }
                        }
                            else if (httpResponse.statusCode == Constants.KSessionOverrideErrorCode) {
                                if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {

                                    print(responseJson ?? "No data")
                                    let message: String = responseJson!["message"] as! String
                                    callback(nil, message, httpResponse.statusCode)
                                }
                        }
                            else if(httpResponse.statusCode == Constants.KAppUpgradationCode) {
                                if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {

                                    print(responseJson ?? "No data")
                                    let message: String = responseJson!["message"] as! String
                                    callback(nil, message, httpResponse.statusCode)
                                }
                        }
                            else {
                                if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {

                                    print(responseJson ?? "No data")
                                    let message: String = responseJson!["message"] as! String
                                    callback(nil, message, httpResponse.statusCode)
                                }
                        }
                    }
                }
                task.resume()
            } catch {
                callback(nil, Constants.KNetworkConnectionIssueString, Constants.KNetworkErrorCode)
            }
        }
    }

}
