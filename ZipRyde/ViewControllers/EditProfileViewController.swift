//
//  EditProfileViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 11/9/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var mobileTextField: UITextField!
    //@IBOutlet var countyCodeTextField: UITextField!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNametextField: UITextField!
    
    var currentTextField: UITextField?
    var userId : String?
    var indicatorView: ActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let dictionary = Utility.fetchRiderDetail() {
            userId = String((dictionary["userId"] as? Int)!)
            firstNameTextField.text = (dictionary["firstName"] as? String)!
            mobileTextField.text =  (dictionary["mobileNumber"] as? String)!
            if let emailId = dictionary["emailId"] as? String, let lastName = dictionary["lastName"] as? String  {
                emailTextField.text = emailId
                lastNametextField.text = lastName
            }
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
    
    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }
    
    func removeActivityIndicator() {
        indicatorView?.removeIndicator()
        indicatorView = nil
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateButtonClicked(_ sender: Any) {
        self.currentTextField?.resignFirstResponder()
        self.showActivityIndicator()
        let userDefaults = UserDefaults.standard
        let password = userDefaults.value(forKey: Constants.KPasswordString) as! String
        let firstName = firstNameTextField.text!
        let lastName = lastNametextField.text!
        let email = emailTextField.text!
        let mobile = mobileTextField.text!
        
        if let deviceToken = Utility.fetchDeviceToken() {
            let saveUserViewModel = SaveUserViewModel()
            saveUserViewModel.saveUserData("RIDER", firstName, lastName, email, mobile, password, "", deviceToken, 1, userId) { (message, responseCode) in
                if(responseCode == Constants.KNetworkSuccessCode) {
                    if var dictionary = Utility.fetchRiderDetail() {
                        dictionary["firstName"] = self.firstNameTextField.text
                        dictionary["lastName"] = self.lastNametextField.text
                        dictionary["emailId"] = self.emailTextField.text
                        Utility.saveRiderDetail(dictionary)
                    }
                    self.removeActivityIndicator()
                    self.dismiss(animated: true, completion: nil)
                } else if(responseCode == Constants.KNetworkErrorCode) {
                    self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                }
                else if(responseCode == Constants.KAppUpgradationCode){
                    self.showAlertPopUp(message!)
                }
            }
        }
        
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        switch textField.tag {
        case firstNameTextField.tag:
            firstNameTextField.text = textField.text
            break
        case lastNametextField.tag:
            lastNametextField.text = textField.text
            break
        case emailTextField.tag:
            emailTextField.text = textField.text
            break
        default: break
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentTextField?.resignFirstResponder()
        return true
    }
}
