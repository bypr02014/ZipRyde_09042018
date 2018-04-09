//
//  SignInViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/23/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import CoreLocation

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var mobNumberTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    var currentCLLocation: CLLocation?
    var indicatorView: ActivityIndicatorView?
    var rider: Rider?
    let locationMgr = CLLocationManager()
    var imageView: UIImageView?


    override func viewDidLoad() {
        super.viewDidLoad()
        intializeCoreLocation()
        let window = UIApplication.shared.keyWindow!
        self.imageView = UIImageView()
        self.imageView?.frame = CGRect(x: 0, y: 0, width: (window.bounds.width), height: (window.bounds.height))
        self.imageView?.image = UIImage(named: "zipryde")
        self.imageView?.contentMode = .scaleAspectFit
        UIApplication.shared.keyWindow?.addSubview(self.imageView!)

        let defaults: UserDefaults = UserDefaults.standard
        if defaults.object(forKey: Constants.KIPStringContants) == nil {
              //  defaults.set("mobileservice.zipryde.com:8080/zipryde", forKey: Constants.KIPStringContants)
            defaults.set("52.32.81.75:8080/zipryde", forKey: Constants.KIPStringContants)
           // print("abdcd  sfdfdfdsf===",defaults)
        }
        mobNumberTextField.delegate = self
        passwordTextField.delegate = self
        registerForKeyboardNotifications()
        addDoneButtonOnKeyboard()
        checkInternetConnection()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mobNumberTextField.text = ""
        self.passwordTextField.text = ""
        self.imageView?.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "homeScreenViewController" {
            let viewController = segue.destination as! HomeScreenViewController
            viewController.rider = self.rider
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

    func checkInternetConnection() {
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: Constants.KPasswordString) != nil {
            moveToHomeScreen()
        }
    }

    func intializeCoreLocation() {
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        locationMgr.delegate = self
        locationMgr.requestWhenInUseAuthorization()
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
        if let activeField = self.passwordTextField {
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

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(EnterMobileNumViewController.doneButtonAction))
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.mobNumberTextField.inputAccessoryView = doneToolbar
    }

    func doneButtonAction() {
        self.mobNumberTextField.resignFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case mobNumberTextField.tag:
            mobNumberTextField.text = textField.text
            break
        case passwordTextField.tag:
            passwordTextField.text = textField.text
            break
        default:
            break
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        return true
    }

    @IBAction func signInButtonClicked(_ sender: Any) {
        
        if((self.mobNumberTextField.text != "") && (self.passwordTextField.text != "")) {
            self.mobNumberTextField.resignFirstResponder()
            self.passwordTextField.resignFirstResponder()
            showActivityIndicator()
            self.verifyUserLogin(0)
        } else {
            self.showAlertPopUp ("UserName or Password does not match")
        }
    }

    func verifyUserLogin(_ overrideSessionToken: Int) {

        if let deviceToken = Utility.fetchDeviceToken() {

            let verifyLogInUserViewModel = VerifyLogInUserViewModel()
            verifyLogInUserViewModel.verifyLogin("RIDER", mobNumberTextField.text!, passwordTextField.text!, deviceToken, overrideSessionToken, callback: { (riderDetail, message, responseCode) in
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

    func showAlertPopUp(_ message: String) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)

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
        userDefaults.set(self.mobNumberTextField.text, forKey: Constants.KMobileNumberString)
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
}

extension SignInViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            manager.stopUpdatingLocation()
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            break
        case .authorizedWhenInUse:
            let when = DispatchTime.now() + 2 // change 1 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.imageView?.removeFromSuperview()
            }
            break
        default:
            break
        }
    }
}

