//
//  SignUpViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/24/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var mobNumTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    var rider: Rider?
    var indicatorView: ActivityIndicatorView?
    var mobileNumber: String = ""
    var currentTextField: UITextField?
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        registerForKeyboardNotifications()
        mobNumTextField.text = mobileNumber
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        confirmPasswordTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    func registerForKeyboardNotifications() {

        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func deregisterFromKeyboardNotifications() {

        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = currentTextField {
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        switch textField.tag {
        case firstNameTextField.tag:
            firstNameTextField.text = textField.text
            break
        case lastNameTextField.tag:
            lastNameTextField.text = textField.text
            break
        case passwordTextField.tag:
            passwordTextField.text = textField.text
            break
        case emailTextField.tag:
            emailTextField.text = textField.text
            break
        case confirmPasswordTextField.tag:
            confirmPasswordTextField.text = textField.text
            break
        case mobNumTextField.tag:
            mobNumTextField.text = textField.text
            break
        default: break

        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        currentTextField?.resignFirstResponder()
        return true
    }

    func showAlertPopUp(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlreadyLoggedInPopUp(_ message: String) {
        let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
            self.showActivityIndicator()
            self.verifyUserLogin(1)
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessMessage() {
        // the alert view
        let alert = UIAlertController(title: "", message: "Successfully logged In", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            // your code with delay
            alert.dismiss(animated: true, completion: {
                self.moveToHomeScreen()
            })
        }
    }
    
    func saveRiderDetail() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.mobNumTextField.text, forKey: Constants.KMobileNumberString)
        userDefaults.set(self.passwordTextField.text, forKey: Constants.KPasswordString)
        userDefaults.synchronize()
    }
    
    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }
    
    func removeActivityIndicator() {
        indicatorView?.removeIndicator()
        indicatorView = nil
    }
    

    func showSuccessSignUpPopUp() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Information", message: "You have signed up successfully.", preferredStyle: .alert)

            let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in

                for viewController in (self.navigationController?.viewControllers)! {
                    if(viewController is SignInViewController) {
                        self.navigationController?.isNavigationBarHidden = false
                        self.navigationController!.popToViewController(viewController, animated: true)
                    }
                }
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func verifyUserLogin(_ overrideSessionToken: Int) {
        
        if let deviceToken = Utility.fetchDeviceToken() {
            
            let verifyLogInUserViewModel = VerifyLogInUserViewModel()
            verifyLogInUserViewModel.verifyLogin("RIDER", mobNumTextField.text!, passwordTextField.text!, deviceToken, overrideSessionToken, callback: { (riderDetail, message, responseCode) in
                if(responseCode == Constants.KSessionOverrideErrorCode) {
                    DispatchQueue.main.async {
                        self.removeActivityIndicator()
                        self.showAlreadyLoggedInPopUp(message!)
                    }
                } else if(responseCode == Constants.KNetworkSuccessCode) {
                    DispatchQueue.main.async {
                        self.rider = riderDetail
                        self.saveRiderDetail()
                        self.removeActivityIndicator()
                        self.showSuccessMessage()
                    }
                } else if(responseCode == Constants.KAppUpgradationCode) {
                    DispatchQueue.main.async {
                        self.removeActivityIndicator()
                        self.showAlertPopUp(message!)
                    }
                }
                else if(responseCode == Constants.KNetworkErrorCode) {
                    DispatchQueue.main.async {
                        self.removeActivityIndicator()
                        self.showAlertPopUp(message!)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.removeActivityIndicator()
                        self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                    }
                }
            })
        }
        else {
            self.showAlertPopUp(Constants.KPushNotificationIssueString)
        }
    }
    

    func moveToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeScreenViewController = storyboard.instantiateViewController(withIdentifier: "homeScreenViewController") as! HomeScreenViewController
        homeScreenViewController.rider = self.rider
        let navigationController: UINavigationController = UINavigationController(rootViewController: homeScreenViewController)
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.barTintColor = UIColor(red: 77 / 255.0, green: 130 / 255.0, blue: 195 / 255.0, alpha: 1.0)
        navigationController.navigationBar.isTranslucent = false
        
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuViewController") as! MenuViewController
        menuViewController.mainViewController = navigationController
        let slideMenuController = ExSlideMenuController(mainViewController: navigationController, leftMenuViewController: menuViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        self.present(slideMenuController, animated: true, completion: nil)
    }
    
    @IBAction func alreadyAccountButtonClicked(_ sender: Any) {
        currentTextField?.resignFirstResponder()
        let signInViewController = navigationController!.viewControllers.filter { $0 is SignInViewController }.first!
        navigationController!.popToViewController(signInViewController, animated: false)
    }

    @IBAction func signUpButtonClicked(_ sender: Any) {
        
        self.currentTextField?.resignFirstResponder()
        
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let mobile = mobNumTextField.text!
        let password = passwordTextField.text!
        
        self.showActivityIndicator();
        if let deviceToken = Utility.fetchDeviceToken() {
            let saveUserViewModel = SaveUserViewModel()
            saveUserViewModel.saveUserData("RIDER", firstName, lastName, email, mobile, password, "", deviceToken, 1, nil) { (message, responseCode) in
                if(responseCode == Constants.KNetworkSuccessCode) {
                    //self.showSuccessSignUpPopUp()
                    
                    //Call the login service
                    self.verifyUserLogin(0);
                } else if(responseCode == Constants.KNetworkErrorCode) {
                    self.removeActivityIndicator();
                    self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                }
                else if(responseCode == Constants.KAppUpgradationCode){
                    self.removeActivityIndicator();
                    self.showAlertPopUp(message!)
                }
            }
        } else {
            self.showAlertPopUp(Constants.KPushNotificationIssueString)
        }
    }
}
