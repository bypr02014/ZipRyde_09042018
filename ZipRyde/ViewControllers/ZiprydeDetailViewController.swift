//
//  ZiprydeDetailViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 11/15/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class ZiprydeDetailViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var fromAddressLabel: UILabel!
    @IBOutlet var toAddressLabel: UILabel!
    @IBOutlet var cabTypeLabel: UILabel!
    @IBOutlet var cabImageView: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var driverNameLabel: UILabel!
    @IBOutlet var lostButton: UIButton!
    @IBOutlet var topContainerView: UIView!
    @IBOutlet var queryTextField: UITextField!
    @IBOutlet var lostItemPopUpView: UIView!

    var greyView: UIView!
    var ride: Ride!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.cabTypeLabel.text = ride.cabType!
        let cabImageName = Utility.getWhiteCabImageBasedOnCabType(cabType: (ride.cabType)!)
        self.cabImageView.image = UIImage(named: cabImageName)
        self.fromAddressLabel.text = ride.sourceLocAddress
        self.toAddressLabel.text = ride.destinationLocAddress
        self.driverNameLabel.text = ride.driverName
        self.statusLabel.text = ride.bookingStatus
        self.lostItemPopUpView.isHidden = true
        self.queryTextField.delegate = self
    }

    func showAlertPopUp(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showSuccessMessage() {
        // the alert view
        let alert = UIAlertController(title: "", message: "Your request has been submitted successful", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 0.8
        DispatchQueue.main.asyncAfter(deadline: when) {
            // your code with delay
            alert.dismiss(animated: true, completion: {
            })
        }
    }

    @IBAction func submitButtonClicked(_ sender: Any) {
        queryTextField.resignFirstResponder()
        if ((queryTextField.text != nil) && (queryTextField.text != "")) {
            queryTextField.text = ""
            self.lostItemPopUpView.isHidden = true
            self.greyView.removeFromSuperview()
            let queryText = queryTextField.text
            let bookingViewModel = BookingViewModel()
            bookingViewModel.reportLostItem(self.ride.bookingId!, queryText!) { (responseCode) in
                DispatchQueue.main.async {
                    if(responseCode == Constants.KNetworkErrorCode) {
                        self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                    }else if(responseCode == Constants.KNetworkSuccessCode){
                        self.showSuccessMessage()
                    }
                }
            }
        }else{
             self.showAlertPopUp("Please enter valid query.")
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func lostButtonClicked(_ sender: Any) {
    
        self.lostItemPopUpView.layer.cornerRadius = 10
        self.lostItemPopUpView.clipsToBounds = true
        greyView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        greyView.backgroundColor = UIColor(red: 97 / 255.0, green: 97 / 255.0, blue: 97 / 255.0, alpha: 0.3)
        self.lostItemPopUpView.translatesAutoresizingMaskIntoConstraints = false
        greyView.addSubview(self.lostItemPopUpView)
        self.lostItemPopUpView.centerXAnchor.constraint(equalTo: greyView.centerXAnchor).isActive = true
        self.lostItemPopUpView.centerYAnchor.constraint(equalTo: greyView.centerYAnchor).isActive = true
        self.view.addSubview(greyView)
        self.lostItemPopUpView.isHidden = false
    }
}


extension ZiprydeDetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        queryTextField.text = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        queryTextField.resignFirstResponder()
        return true
    }
}
