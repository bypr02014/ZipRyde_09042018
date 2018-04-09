//
//  VerifyFPViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 11/15/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class VerifyFPViewController: UIViewController {

    @IBOutlet var otpTextField: UITextField!
    var mobileNumber: String!
    var indicatorView: ActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.otpTextField.delegate = self
        self.title = "Forget Password"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changePasswordViewController" {
            self.removeActivityIndicator ()
            let viewController = segue.destination as! ChangePasswordViewController
            viewController.mobileNumber = self.mobileNumber!
        }
    }

    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }

    func removeActivityIndicator() {
        DispatchQueue.main.async {
            self.indicatorView?.removeIndicator()
            self.indicatorView = nil
        }
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
        let alert = UIAlertController(title: "", message: "Pin verified successfully", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 0.7
        DispatchQueue.main.asyncAfter(deadline: when) {
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "changePasswordViewController", sender: self)
        }
    }

    func showFailureMessage() {

        let alertController = UIAlertController(title: "Information", message: "Invalid Pin. Please try again later. ", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok", style: .cancel) { (action: UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func generateOTP () {
        let getOTPViewModel = GetOTPViewModel()
        getOTPViewModel.fetchOTP(mobileNumber) { (otpDetail, responseCode) in
            if(responseCode == Constants.KNetworkErrorCode) {
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            }
        }
    }

    @IBAction func generateOTPButtonClicked(_ sender: Any) {
        self.generateOTP()
    }

    @IBAction func verifyButtonClicked(_ sender: Any) {
        guard self.otpTextField.text != "" else {
            return
        }
        self.otpTextField.resignFirstResponder()
        self.showActivityIndicator()
        let verifyOTPViewModel = VerifyOTPViewModel()
        verifyOTPViewModel.verifyOTP(mobileNumber, self.otpTextField.text!) { (status, responseCode) in
            if(responseCode == Constants.KNetworkSuccessCode) {
                DispatchQueue.main.async {
                    if(status == Constants.KVerifiedString) {
                        self.removeActivityIndicator()
                        self.showSuccessMessage()
                    }
                        else {
                            self.removeActivityIndicator()
                            self.showFailureMessage()
                    }
                }
            } else {
                
                self.removeActivityIndicator()
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            }
        }
    }
}

extension VerifyFPViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.otpTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.otpTextField.resignFirstResponder()
        return true
    }
}
