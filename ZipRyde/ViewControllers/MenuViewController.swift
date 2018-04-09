//
//  MenuViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/12/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

enum LeftMenu: Int {
    case userDetail = 0
    case bookZipRyde
    case scheduleRydes
    case pastRydes
    case help
    case payment
    case logOut
}

protocol LeftMenuProtocol: class {
    func changeViewController(_ menu: LeftMenu)
}

class MenuViewController: UIViewController, LeftMenuProtocol {

    @IBOutlet var menuTableView: UITableView!
    var mainViewController: UIViewController!
    var scheduleRydesViewController: UIViewController!
    var pastRydesViewController: UIViewController!
    var helpViewController: UIViewController!
    var paymentViewController: UIViewController!
    var isPaymentClicked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scheduleRydesViewController = storyboard.instantiateViewController(withIdentifier: "scheduleRydes") as! ScheduleRydesViewController
        self.scheduleRydesViewController = UINavigationController(rootViewController: scheduleRydesViewController)

        let pastRydesViewController = storyboard.instantiateViewController(withIdentifier: "pastRydes") as! PastRydesViewController
        self.pastRydesViewController = UINavigationController(rootViewController: pastRydesViewController)

        let helpViewController = storyboard.instantiateViewController(withIdentifier: "helpView") as! HelpViewController
        self.helpViewController = UINavigationController(rootViewController: helpViewController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        menuTableView.reloadData()
    }
    
    func showAlertMessage(_ message : String) {
        
        let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action: UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
            Utility.deleteRiderDetail()
            self.dismiss(animated: true, completion: nil)
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func logOutUser() {
        let dictionary = Utility.fetchRiderDetail()
        let userId = dictionary?["userId"] as! Int

        let bookingViewModel = BookingViewModel()
        bookingViewModel.logOut(userId) { (responseCode) in
            if((responseCode == Constants.KNetworkSuccessCode) || (responseCode == Constants.KAppUpgradationCode) || (responseCode == Constants.KSessionLogOutErrorCode)) {
                DispatchQueue.main.async {
                    self.showAlertMessage("Are you sure you want to Log Out?")
                }
            }
                else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Information", message: Constants.KNetworkConnectionIssueString, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
            }
        }
    }

    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .bookZipRyde:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
        case .scheduleRydes:
            self.slideMenuController()?.changeMainViewController(self.scheduleRydesViewController, close: true)
        case .pastRydes:
            self.slideMenuController()?.changeMainViewController(self.pastRydesViewController, close: true)
        case .help:
            self.slideMenuController()?.changeMainViewController(self.helpViewController, close: true)
        case .payment:
            self.slideMenuController()?.changeMainViewController(self.pastRydesViewController, close: true)
        case .logOut:
            self.logOutUser()
        default:
            break
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
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.section) {
            switch menu {
            case .userDetail:
                return 168
            case .bookZipRyde, .scheduleRydes, .pastRydes, .help, .payment, .logOut:
                return 50
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.section) {
            if(menu == LeftMenu.payment) {
                if(indexPath.row == 0) {
                    if(menu == LeftMenu.payment && (!isPaymentClicked)) {
                        isPaymentClicked = true
                        menuTableView.reloadData()
                    } else if(menu == LeftMenu.payment && isPaymentClicked) {
                        isPaymentClicked = false
                        menuTableView.reloadData()
                    }
                } else if(indexPath.row == 1) {
                    guard let payPalUrl = URL(string: Constants.KPayPalUrlString) else { return }
                    UIApplication.shared.open(payPalUrl, options: [:], completionHandler: nil)
                } else if(indexPath.row == 2) {
                    guard let cashAppUrl = URL(string: Constants.KCashAppUrlString) else { return }
                    UIApplication.shared.open(cashAppUrl, options: [:], completionHandler: nil)
                } else if(indexPath.row == 3) {
                    showAlertPopUp(Constants.KAirlineVoucherString)
                }
            }
                else {
                    isPaymentClicked = false
                    self.changeViewController(menu)
            }
        }
    }
}

extension MenuViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(isPaymentClicked && (section == 5)) {
            return 4
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let menu = LeftMenu(rawValue: indexPath.section) {
            switch menu {
            case .bookZipRyde, .scheduleRydes, .pastRydes, .help, .logOut:
                let cell: DefaultTableViewCell = (tableView.dequeueReusableCell(withIdentifier: String(describing: menu), for: indexPath) as? DefaultTableViewCell)!
                return cell
            case .userDetail:
                let cell: UserDetailTableViewCell = (tableView.dequeueReusableCell(withIdentifier: String(describing: menu), for: indexPath) as? UserDetailTableViewCell)!

                if let dictionary = Utility.fetchRiderDetail() {
                    let firstName = dictionary["firstName"] as! String
                    let lastName = dictionary["lastName"] as! String

                    cell.fullNameLabel.text = "\(firstName) \(lastName)"
                    //cell.riderImageView.image = ""
                    cell.versionLabel.text = Utility.getAppVersionNumber()
                }
                return cell
            case .payment:
                if(indexPath.row == 0) {
                    let cell: DefaultTableViewCell = (tableView.dequeueReusableCell(withIdentifier: String(describing: menu), for: indexPath) as? DefaultTableViewCell)!
                    return cell
                } else if(indexPath.row == 1) {
                    let cell: PaymentSubDetailTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "paymentSubCell", for: indexPath) as? PaymentSubDetailTableViewCell)!
                    cell.paymentTypeLabel.text = "Paypal"
                    return cell
                } else if(indexPath.row == 2) {
                    let cell: PaymentSubDetailTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "paymentSubCell", for: indexPath) as? PaymentSubDetailTableViewCell)!
                    cell.paymentTypeLabel.text = "Cash App"
                    cell.paymentTypeImageView.image = UIImage(named: "cashIcon")
                    return cell
                } else if(indexPath.row == 3) {
                    let cell: PaymentSubDetailTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "paymentSubCell", for: indexPath) as? PaymentSubDetailTableViewCell)!
                    cell.paymentTypeLabel.text = "Airline Voucher"
                     cell.paymentTypeImageView.image = UIImage(named: "Vocher")
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
}
