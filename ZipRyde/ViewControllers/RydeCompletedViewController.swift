//
//  RydeCompletedViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/18/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class RydeCompletedViewController: UIViewController, UINavigationBarDelegate {

    @IBOutlet var totalFareLabel: UILabel!
    @IBOutlet var destinationAddressLabel: UILabel!
    @IBOutlet var sourceAddressLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var fareLabel: UILabel!

    var rider: Rider!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ZipRyde"
        self.navigationController?.isNavigationBarHidden = false
        self.edgesForExtendedLayout = []
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(RydeCompletedViewController.backButtonClicked))
        sourceAddressLabel.text = self.rider.sourceLocAddress
        destinationAddressLabel.text = self.rider.destinationLocAddress
        if let totalFare = self.rider.driverDetail?.offeredPrice, let distance = self.rider.distanceInMiles {
            totalFareLabel.text = "$ \(String(describing: totalFare))"
            fareLabel.text = totalFareLabel.text
            distanceLabel.text = "\(String(describing: distance))mi"
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.PaymentSuccessNotification),
                                               name: NSNotification.Name(rawValue: Constants.KBookingPaymentSuccess),
                                               object: nil)
    }
    
    func backButtonClicked() {
        belongingsCheckAlert()
    }

    func belongingsCheckAlert() {
        showAlert("Information", "Reminder! Check your belongings before exiting the vehicle")
    }

    func showAlert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            for viewController in (self.navigationController?.viewControllers)! {
                if((viewController is HomeScreenViewController) || (viewController is ScheduleRydesViewController)){
                    self.navigationController!.popToViewController(viewController, animated: true)
                     alertController.dismiss(animated: true, completion: nil)
                }
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showPopUp(_ message : String){
        let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func PaymentSuccessNotification(notification: Notification) -> Void {
        let notificationInfo = notification.userInfo as! [String: Any]
        let notificationType = notificationInfo["notificationType"] as? String
    
        if(Constants.KBookingPaymentSuccess == notificationType) {
            belongingsCheckAlert()
        }
    }
    
    @IBAction func creditCardButtonClicked(_ sender: Any) {
        self.showPopUp("Thank you for choosing ZipRyde.We hope you will ride with us in the future!\nFor credit card payment, your driver will be able to process your card in a Zip!\n!Zip Tips are greatly appreciated!")
    }
    
    @IBAction func cashButtonClicked(_ sender: Any) {
        self.showPopUp("Thank you for choosing ZipRyde.\nWe hope you will ride with us in the future!\nWe would appreciate referrals to all of your friends, family and associates.")
    }
    
    @IBAction func payPalButtonClicked(_ sender: Any) {
        guard let payPalUrl = URL(string: Constants.KPayPalUrlString) else { return }
        UIApplication.shared.open(payPalUrl, options: [:], completionHandler: nil)
    }
    
    @IBAction func cashAppButtonClicked(_ sender: Any) {
        guard let cashAppUrl = URL(string: Constants.KCashAppUrlString) else { return }
        UIApplication.shared.open(cashAppUrl, options: [:], completionHandler: nil)
    }
}
