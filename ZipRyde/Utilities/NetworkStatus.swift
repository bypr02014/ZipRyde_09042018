//
//  NetworkStatus.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/25/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import Foundation
import SystemConfiguration
import AFNetworking

class NetworkStatus {
    
     static func addNetworkStatusChangeNotification() {
        var previousNetworkReachabilityStatus: AFNetworkReachabilityStatus = .unknown
        
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            let reachabilityStatus = AFStringFromNetworkReachabilityStatus(status)
            var reachableOrNot = ""
            var networkSummary = ""
            var reachableStatusBool = false
            
            switch (status) {
            case .reachableViaWWAN, .reachableViaWiFi:
                // Reachable.
                reachableOrNot = "Reachable"
                networkSummary = "Connected to Network"
                reachableStatusBool = true
            default:
                // Not reachable.
                reachableOrNot = "Not Reachable"
                networkSummary = "Disconnected from Network"
                reachableStatusBool = false
            }
            
            if (previousNetworkReachabilityStatus != .unknown && status != previousNetworkReachabilityStatus) {
                NotificationCenter.default.post(name: NSNotification.Name(Constants.KNetworkStatusChangeNotifier), object: nil, userInfo: [
                    "reachabilityStatus" : "Connection Status : \(reachabilityStatus)",
                    "reachableOrNot" : "Network Connection \(reachableOrNot)",
                    "summary" : networkSummary,
                    "reachableStatus" : reachableStatusBool
                    ])
            }
            previousNetworkReachabilityStatus = status
        }
    }
}
