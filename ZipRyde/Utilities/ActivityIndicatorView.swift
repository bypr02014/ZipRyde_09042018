//
//  ActivityIndicatorView.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/26/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class ActivityIndicatorView : UIView {
    var activityIndicator: UIActivityIndicatorView? = nil
    
    func showIndicator() -> UIView {
        
        let window = UIApplication.shared.keyWindow!
        self.frame = window.frame
        self.center = window.center
        self.backgroundColor = UIColor(red:237/255.0 , green: 237/255.0, blue: 237/255.0, alpha: 0.1)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x:0, y:0, width: 80,height: 80)
        loadingView.center = window.center
        loadingView.backgroundColor = UIColor.white
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator?.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0)
        activityIndicator?.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.gray
        activityIndicator?.center = CGPoint(x:loadingView.frame.size.width / 2,
                                 y:loadingView.frame.size.height / 2);
        loadingView.addSubview(activityIndicator!)
        self.addSubview(loadingView)
        activityIndicator?.startAnimating()
        return self
    }
    
    func removeIndicator() {
        activityIndicator?.stopAnimating()
        self.removeFromSuperview()
    }
    
    func showIndicatorWithMessage() -> UIView {
        
        let window = UIApplication.shared.keyWindow!
        self.frame = window.frame
        self.center = window.center
        self.backgroundColor = UIColor(red:237/255.0 , green: 237/255.0, blue: 237/255.0, alpha: 0.1)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x:0, y:0, width: 160, height: 120)
        loadingView.center = window.center
        loadingView.layer.cornerRadius = 20
        loadingView.clipsToBounds = true
        loadingView.backgroundColor = UIColor.white
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator?.frame = CGRect(x:50.0, y:5.0, width:60.0, height:60.0)
        activityIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingView.addSubview(activityIndicator!)
        
        let msgLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 160, height: 70))
        msgLabel.font = UIFont.boldSystemFont(ofSize: 16)
        msgLabel.textColor = .orange
        msgLabel.textAlignment = .center
        msgLabel.text = "Routing Your ZipRyde!"
        msgLabel.numberOfLines = 0
        loadingView.addSubview(msgLabel)
        
        self.addSubview(loadingView)
        activityIndicator?.startAnimating()
        return self
    }
    
    func showGreyOutView() -> UIView {
        
        let window = UIApplication.shared.keyWindow!
        self.frame = window.frame
        self.center = window.center
        self.backgroundColor = UIColor(red:237/255.0 , green: 237/255.0, blue: 237/255.0, alpha: 0.1)
        return self
    }
    
    func removeGreyOutView() {
        self.removeFromSuperview()
    }
}
