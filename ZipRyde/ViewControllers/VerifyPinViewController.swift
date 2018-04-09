//
//  VerifyPinViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/24/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

internal class VerifyPinViewController: UIViewController, UITextFieldDelegate {

    var mobileNumber: String = ""
    var otp: String = ""
    var indicatorView: ActivityIndicatorView?
    @IBOutlet var codeTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.codeTextField.delegate = self
        self.codeTextField.text = self.otp
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "signUpViewController" {
            let viewController = segue.destination as! SignUpViewController
            viewController.mobileNumber = self.mobileNumber

        }
            else if segue.identifier == "enterIPViewController" {
        }
    }

    func retriveOTP () {
        let getOTPViewModel = GetOTPViewModel()
        getOTPViewModel.fetchOTP(mobileNumber, callback: { ( otpDetail, responseCode) in
            if(responseCode == 200){
                if let otpDetailDict = otpDetail {
                    DispatchQueue.main.async {
                        self.otp = otpDetailDict["otp"] as! String
                        print(otpDetailDict)
                        self.performSegue(withIdentifier: "verifyPinViewController", sender: self)
                    }
                }
            }else{
                self.showNoInternetAlert()
            }
        })
    }

    @IBAction func verifyButtonClicked(_ sender: Any) {
        guard self.codeTextField.text != "" else {
            return
        }
        self.showActivityIndicator()
        let verifyOTPViewModel = VerifyOTPViewModel()
        verifyOTPViewModel.verifyOTP(mobileNumber, self.codeTextField.text!) { (status, responseCode) in
            if(responseCode == Constants.KNetworkSuccessCode){
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
            }else{
               self.showNoInternetAlert()
            }
        }
    }
    
    func showNoInternetAlert(){
        DispatchQueue.main.async {
            self.removeActivityIndicator()
            let alertController = UIAlertController(title: "Information", message: Constants.KNetworkConnectionIssueString, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func showSuccessMessage() {
        let alert = UIAlertController(title: "", message: "Pin verified successfully", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "signUpViewController", sender: self)
        }
    }

    func showFailureMessage() {

        let alertController = UIAlertController(title: "Information", message: "Invalid Pin. Please try again later. ", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: "Resend", style: .default) { (action: UIAlertAction!) in
            self.retriveOTP()
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }

    func removeActivityIndicator() {
        indicatorView?.removeIndicator()
    }

    @IBAction func resendCodeButtonClicked(_ sender: Any) {
        self.retriveOTP()
    }

    @IBAction func changeNumberButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        codeTextField = textField
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        codeTextField.resignFirstResponder()
        return true
    }
}
