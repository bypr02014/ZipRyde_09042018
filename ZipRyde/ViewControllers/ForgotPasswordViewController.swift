//
//  ForgotPasswordViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 11/15/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var mobTextField: UITextField!
    var indicatorView: ActivityIndicatorView?
    var mobileNumber: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forgot Password"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "verifyFPViewController" {
            self.removeActivityIndicator ()
            let viewController = segue.destination as! VerifyFPViewController
            viewController.mobileNumber = self.mobTextField.text!
        }
    }

    func getOTP (_ mobileNumber: String) {
        self.showActivityIndicator ()
        let getOTPViewModel = GetOTPViewModel()
        getOTPViewModel.fetchOTP(mobileNumber, callback: { (otpDetail, responseCode) in
            if(responseCode == Constants.KNetworkSuccessCode) {
                print("responseCoderesponseCodefpwd",responseCode)
                DispatchQueue.main.async {
                    self.removeActivityIndicator()
                }
            } else {
                DispatchQueue.main.async {
                    self.removeActivityIndicator ()
                    let alertController = UIAlertController(title: "Information", message: Constants.KNetworkConnectionIssueString, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
                        alertController.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }

    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }

    func removeActivityIndicator() {
        indicatorView?.removeIndicator()
        indicatorView = nil
    }

    func InvalidMobileNumber() {
        let alertController = UIAlertController(title: "Information", message: "Please enter valid mobile number.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            self.mobTextField.resignFirstResponder()
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }


    @IBAction func enterOTPButtonClicked(_ sender: Any) {

        if(self.mobTextField.text != "") {
            self.performSegue(withIdentifier: "verifyFPViewController", sender: self)
        } else {
            InvalidMobileNumber()
        }
    }

    @IBAction func generateButtonClicked(_ sender: Any) {
        if (self.mobTextField.text != "") {
            self.mobTextField.resignFirstResponder()
            let mobileNumber = mobTextField.text!
            getOTP(mobileNumber)
        } else {
            InvalidMobileNumber()
        }
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let set = NSCharacterSet(charactersIn: "+0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: set)
        let phoneNumber = compSepByCharInSet.joined(separator: "")
        return string == phoneNumber
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.mobTextField.resignFirstResponder()
        return true
    }
}
