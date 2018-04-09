//
//  ChangePasswordViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 11/15/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet var mobTextField: UITextField!
    @IBOutlet var newPwdTextField: UITextField!
    @IBOutlet var confirmPwdTextField: UITextField!
    var indicatorView: ActivityIndicatorView?

    var currentTextField: UITextField?
    var mobileNumber: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Change Password"
        self.newPwdTextField.delegate = self
        self.confirmPwdTextField.delegate = self
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.mobTextField.text = self.mobileNumber
    }

    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }

    func removeActivityIndicator() {
        indicatorView?.removeIndicator()
        indicatorView = nil
    }

    func showAlertPopUp(_ message: String) {
        DispatchQueue.main.async {
            self.removeActivityIndicator()
            let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func showSuccessMessage() {
        let alert = UIAlertController(title: "", message: "Password updated successfully", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 0.7
        DispatchQueue.main.asyncAfter(deadline: when) {
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    @IBAction func changeButtonClicked(_ sender: Any) {
        if((newPwdTextField.text! == confirmPwdTextField.text!) && (newPwdTextField.text != "")) {
            confirmPwdTextField.resignFirstResponder()
            let verifyOTPViewModel = VerifyOTPViewModel()
            verifyOTPViewModel.updatePasswordByUserAndType(mobTextField.text!, confirmPwdTextField.text!) { (responseCode) in
                if(responseCode == Constants.KNetworkSuccessCode) {
                    print("responseCoderesponseCodechangepwd",responseCode)
                    DispatchQueue.main.async {
                        self.removeActivityIndicator()
                        self.showSuccessMessage()
                    }
                } else if (responseCode == Constants.KNetworkErrorCode) {
                    
                    self.showAlertPopUp(Constants.KNetworkUserNotFound)
                }
                else  {
                    self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                }
            }
        } else {
            self.showAlertPopUp("Password doesn't match. please enter same password.")
        }
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        switch textField.tag {
        case newPwdTextField.tag:
            newPwdTextField.text = textField.text
            break
        case confirmPwdTextField.tag:
            confirmPwdTextField.text = textField.text
            break
        default: break

        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentTextField?.resignFirstResponder()
        return true
    }
}
