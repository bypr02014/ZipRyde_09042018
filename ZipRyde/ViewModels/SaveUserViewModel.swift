//
//  SaveUserDataSource.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/26/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation

struct SaveUserViewModel {

    func saveUserData (_ userType: String, _ firstName: String, _ lastName: String, _ emailId: String, _ mobileNumber: String, _ password: String, _ alternateNumber: String, _ deviceToken: String, _ isEnable: Int, _ userId : String! , callback: @escaping (String? , Int) -> ()) {

        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {

            let zipRydeEndPoint: String = "http://" + (endPoint as! String) + "/saveUser"
            guard let zipRydeURL = URL(string: zipRydeEndPoint) else {
                print("Error: cannot create URL")
                return
            }

            var riderDetails: [String: Any] = ["userType": userType,
                                               "firstName": firstName,
                                               "lastName": lastName,
                                               "emailId": emailId,
                                               "mobileNumber": mobileNumber,
                                               "password": password,
                                               "alternateNumber": alternateNumber,
                                               "deviceToken": deviceToken,
                                               "isEnable": isEnable]
            if(userId != nil){
                riderDetails["userId"] = userId
            }

            do {
                var request = URLRequest(url: zipRydeURL)
                let boundary = generateBoundaryString()
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = try createBody(with: riderDetails, boundary: boundary)
                request.httpMethod = "POST"

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "No data")
                        callback(nil, Constants.KNetworkErrorCode)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("statusCode: \(httpResponse.statusCode)")
                        if(httpResponse.statusCode == Constants.KNetworkSuccessCode){
                            callback(nil, Constants.KNetworkSuccessCode)
                        }
                        else if(httpResponse.statusCode == Constants.KAppUpgradationCode){
                            if let responseJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                
                                print(responseJson ?? "No data")
                                let message: String = responseJson!["message"] as! String
                                callback(message, httpResponse.statusCode)
                            }
                        }
                        else{
                           callback(nil, httpResponse.statusCode)
                        }
                    }
                }
                task.resume()
            } catch {
                print("")
            }
        }

    }

    func createBody(with parameters: [String: Any], boundary: String) throws -> Data {
        var body = Data()
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        body.append("--\(boundary)--\r\n")
        return body
    }

/// Create boundary string for multipart/form-data request
///
/// - returns: The boundary string that consists of "Boundary-" followed by a UUID string.

    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension Data {

    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:The string to be added to the `NSMutableData`.

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


