//
//  GetOTPViewModel.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/24/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation

struct GetOTPViewModel {

    func fetchOTP (_ mobileNumber: String, callback: @escaping ([String: Any]?, Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/getOTPByMobile"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }
            let newRider: [String: Any] = ["mobileNumber": mobileNumber]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: newRider, options: .prettyPrinted)
                var request = URLRequest(url: zipRydeURL)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpMethod = "POST"
                request.httpBody = jsonData
                print("jsonData====>",request)

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")

                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode) {
                            if let dictionary = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                print("dictionarydictionary",dictionary)
                                callback(dictionary, httpResponse.statusCode)
                            }
                        } else {
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
}

