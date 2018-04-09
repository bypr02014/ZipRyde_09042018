//
//  HelpViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/13/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Help"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 77 / 255.0, green: 130 / 255.0, blue: 195 / 255.0, alpha: 1.0)
        self.textView.text = Constants.KHelpString
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
}
