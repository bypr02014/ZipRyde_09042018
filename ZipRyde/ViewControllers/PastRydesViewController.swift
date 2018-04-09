//
//  PastRydesViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/13/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit

class PastRydesViewController: UIViewController {

    @IBOutlet var pastRideTableView: UITableView!
    var rideList = [Ride]()
    var indicatorView: ActivityIndicatorView!
    var driver: Driver!
    var rider: Rider!
    var selectedRow = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your ZipRyde"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 77 / 255.0, green: 130 / 255.0, blue: 195 / 255.0, alpha: 1.0)
       //self.showActivityIndicator()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
       self.showActivityIndicator()
        let dictionary = Utility.fetchRiderDetail()
        let userId = dictionary?["userId"] as! Int
        let bookingViewModel = BookingViewModel()
        bookingViewModel.fetchPastRides(userId) { (pastRideArray, message, responseCode) in
            if(responseCode == Constants.KNetworkSuccessCode) {
                DispatchQueue.main.sync {
                 self.removeActivityIndicator()
                    
                    self.rideList = pastRideArray!
                    self.pastRideTableView.reloadData()
                }
            } else if(responseCode == Constants.KSessionLogOutErrorCode) {
                self.removeActivityIndicator()
                
                self.showSessionExpiredPopUp(message!)
            } else if(responseCode == Constants.KServerNoData){
               
                self.removeActivityIndicator()
                self.showAlertPopUp(Constants.KServerNoPastRides)
            }else {
                
                self.removeActivityIndicator()
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ziprydeDetailViewController" {
            let viewController = segue.destination as! ZiprydeDetailViewController
            let selectedRide = rideList[selectedRow]
            viewController.ride = selectedRide
        }
    }

    func removeActivityIndicator() {
        indicatorView.removeIndicator()
        indicatorView = nil
    }

    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }

    func showSessionExpiredPopUp(_ message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)

            let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
                Utility.deleteRiderDetail()
                self.dismiss(animated: true, completion: nil)
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
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

extension PastRydesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rideList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: RideDetailCell = (tableView.dequeueReusableCell(withIdentifier: "rideDetail", for: indexPath) as? RideDetailCell)!
        let ride = rideList[indexPath.row]
        cell.crnLabel.text = ride.crn!
        cell.dateLabel.text = ride.date!
        cell.timeLabel.text = ride.time!
        cell.sourceAddressLabel.text = ride.sourceLocAddress!
        cell.destinationAddressLabel.text = ride.destinationLocAddress!
        cell.zipStatusLabel.text = ride.rideStatus!
        let cabImageName = Utility.getBlackCabImageBasedOnCabType(cabType: ride.cabType!)
        cell.cabTypeImageView.image = UIImage(named: cabImageName)
        cell.suggestedFareLabel.text = "$ \(ride.suggestedPrice!)"
        cell.offerFareLabel.text = "Offer $ \(ride.offeredPrice!)"
        return cell
    }
}

extension PastRydesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let ride = rideList[indexPath.row]
        if(ride.bookingStatus! == Constants.KBookingDriverZipCompleted) {
            selectedRow = indexPath.row
            self.performSegue(withIdentifier: "ziprydeDetailViewController", sender: self)
        }
    }
}


