//
//  EnterIPViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/24/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class EnterIPViewController: UIViewController {

    @IBOutlet var ipTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.ipTextField.delegate = self
        let defaults: UserDefaults = UserDefaults.standard
        if let endPoint = defaults.object(forKey: Constants.KIPStringContants) {
            self.ipTextField.text = endPoint as? String
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func updateButtonClicked(_ sender: Any) {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(self.ipTextField.text, forKey: Constants.KIPStringContants)
        self.navigationController?.popViewController(animated: true)
    }
}

extension EnterIPViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.ipTextField = textField
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ipTextField.resignFirstResponder()
        return true
    }
}
