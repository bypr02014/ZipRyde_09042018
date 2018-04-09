//
//  EnterMobileNumViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/24/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import MICountryPicker

class EnterMobileNumViewController: UIViewController {

   // @IBOutlet var flagButton: UIButton!
    @IBOutlet var mobileNumTextField: UITextField!
    var indicatorView: ActivityIndicatorView?
    var mobileNumber: String?
    var otp: String?
    var countryPicker : MICountryPicker!
    var countryCode : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.addDoneButtonOnKeyboard ()
         mobileNumTextField.translatesAutoresizingMaskIntoConstraints = false
        //self.mobileNumTextField.delegate = self as! UITextFieldDelegate
        self.countryCode = "+1"
      // self.flagButton.setBackgroundImage(UIImage(named: "us.png"), for: .normal)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(EnterMobileNumViewController.noInternetConnection), name: NSNotification.Name(rawValue: Constants.KNetworkStatusChangeNotifier), object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "verifyPinViewController" {
            self.removeActivityIndicator ()
            let viewController = segue.destination as! VerifyPinViewController
            viewController.mobileNumber = self.mobileNumber!
            viewController.otp = self.otp!
        }
    }

    func noInternetConnection() {
        let alert = UIAlertController(title: "Information", message: "Please enable internet connection in Settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let number: String = mobileNumTextField.text {
            self.mobileNumber = number
            return true
        }
            else {
                return false
        }
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

        self.mobileNumTextField.inputAccessoryView = doneToolbar
    }

    func doneButtonAction() {
        self.mobileNumTextField.resignFirstResponder()
    }

    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }
    
    func removeActivityIndicator() {
        indicatorView?.removeIndicator()
    }
    
    func getOTP () {
        self.showActivityIndicator ()
        let getOTPViewModel = GetOTPViewModel()
        getOTPViewModel.fetchOTP(self.mobileNumber!, callback: { ( otpDetail, responseCode) in
            if(responseCode == 200){
                print("respondecode==if if otp====>",responseCode)
                if let otpDetailDict = otpDetail {
                    DispatchQueue.main.async {
                        self.otp = otpDetailDict["otp"] as? String
                        self.performSegue(withIdentifier: "verifyPinViewController", sender: self)
                    }
                }
            }else{
                print("respondecode==else  otp====>",responseCode)
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
    
    @IBAction func submitButtonClicked(_ sender: Any) {

        if (self.mobileNumTextField.text != "" && self.mobileNumTextField.text?.characters.count == 13) {
          //  self.mobileNumber = self.countryCode + mobileNumTextField.text!
            self.mobileNumber =  mobileNumTextField.text!
            getOTP()
        
        }
            
       else if (self.mobileNumTextField.text != "" && self.mobileNumTextField.text?.characters.count == 10) {
            //  self.mobileNumber = self.countryCode + mobileNumTextField.text!
            self.mobileNumber =  mobileNumTextField.text!
            getOTP()
            
        }
        
        else {
            let alertController = UIAlertController(title: "Information", message: "Please enter valid mobile number.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
                self.mobileNumTextField.resignFirstResponder()
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
//    @IBAction func flagButtonClicked(_ sender: Any) {
//        countryPicker = MICountryPicker()
//        countryPicker.delegate = self
//        navigationController?.pushViewController(countryPicker, animated: true)
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//}
//
//extension EnterMobileNumViewController: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let set = NSCharacterSet(charactersIn: "0123456789").inverted
//        let compSepByCharInSet = string.components(separatedBy: set)
//        let phoneNumber = compSepByCharInSet.joined(separator: "")
//        return string == phoneNumber
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.mobileNumTextField.resignFirstResponder()
//        return true
//    }
//}
//
//extension EnterMobileNumViewController: MICountryPickerDelegate {
//    func countryPicker(picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String,  countryImage: UIImage) {
//        self.countryCode = dialCode
//        self.flagButton.setBackgroundImage(countryImage, for: .normal)
//    }
}
