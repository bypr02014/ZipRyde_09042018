//
//  VerifyOTPDataSource.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/24/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation

struct VerifyOTPViewModel {

    func verifyOTP (_ mobileNumber: String, _ otp: String, callback: @escaping (String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/verifyOTPByMobile"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL",zipRydeEndPoint)
                return
            }
            let newRider: [String: Any] = ["mobileNumber": mobileNumber, "otp": otp]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: newRider, options: .prettyPrinted)
                print("jsonData:  create ",jsonData)
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                print("request:  create=========== ",request)

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")
                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {

                                let status: String = responseJson!["otpStatus"] as! String
                                callback(status, httpResponse.statusCode)
                                print("status:  create=========== ",status)
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

    func updatePassword (_ mobileNumber: String, _ password: String, callback: @escaping (String?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/verifyOTPByMobile"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let newRider: [String: Any] = ["mobileNumber": mobileNumber, "userType": "RIDER", "password": password]

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
                        callback(nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode1234: \(httpResponse.statusCode)")
                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {

                                let status: String = responseJson!["otpStatus"] as! String
                                callback(status, httpResponse.statusCode)
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


    func updatePasswordByUserAndType (_ mobileNumber: String, _ password: String, callback: @escaping (Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/updatePasswordByUserAndType"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL",zipRydeEndPoint)
                return
            }
            let newRider: [String: Any] = ["mobileNumber": mobileNumber, "userType": "RIDER", "password": password]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: newRider, options: .prettyPrinted)
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpMethod = "POST"
                request.httpBody = jsonData

                print("request===========updatePasswordByUserAndType",request)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode=======: \(httpResponse.statusCode)")
                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            callback(httpResponse.statusCode)
                        }
                        else {
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

