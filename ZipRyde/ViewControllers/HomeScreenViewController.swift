//
//  HomeScreenViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/27/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import GoogleMaps

class HomeScreenViewController: UIViewController {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var toLocationButton: UIButton!
    @IBOutlet var whereToLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var topViewInContainerView: UIView!

    var locationManager: CLLocationManager!
    var indicatorView: ActivityIndicatorView?
    var rider: Rider!
    var googleMapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        locationManager = CLLocationManager()

        let camera = GMSCameraPosition.camera(withLatitude: 12.8666, longitude: 77.2012, zoom: 15.0)
        let mapFrame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.stackView.frame.size.height - 64)
        self.googleMapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
        self.view.addSubview(self.googleMapView)

        if let dictionary = Utility.fetchRiderDetail() {

            self.rider = Rider()
            self.rider.userId = dictionary["userId"] as? Int
            self.rider.firstName = dictionary["firstName"] as? String
            self.rider.lastName = dictionary["lastName"] as? String
            self.rider.bookingId = dictionary["bookingId"] as? String
            self.rider.mobileNumber =  dictionary["mobileNumber"] as? String
            self.checkAnyBooking()
            self.containerView.removeFromSuperview()
        }
            else {
                var dictionary = [String: Any]()
                dictionary["userId"] = self.rider.userId
                dictionary["firstName"] = self.rider.firstName
                dictionary["lastName"] = self.rider.lastName
                dictionary["bookingId"] = self.rider.bookingId
                dictionary["mobileNumber"] = self.rider.mobileNumber
                dictionary["emailId"] = self.rider.emailId
                Utility.saveRiderDetail(dictionary)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if(self.googleMapView == nil) {
            let camera = GMSCameraPosition.camera(withLatitude: 12.8666, longitude: 77.2012, zoom: 15.0)
            let mapFrame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.stackView.frame.size.height)
            self.googleMapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
            self.view.addSubview(self.googleMapView)
            
            if let dictionary = Utility.fetchRiderDetail() {
                self.rider = Rider()
                self.rider.userId = dictionary["userId"] as? Int
                self.rider.firstName = dictionary["firstName"] as? String
                self.rider.lastName = dictionary["lastName"] as? String
                self.rider.bookingId = dictionary["bookingId"] as? String
                self.rider.mobileNumber =  dictionary["mobileNumber"] as? String
            }
        }
        self.whereToLabel.layer.zPosition += 1
        self.view.addSubview(self.whereToLabel)
        self.whereToLabel.addSubview(self.toLocationButton)
        self.googleMapView.settings.consumesGesturesInView = false
        self.intializeCoreLocation()
        self.setNavigationBarItem()
        if let dictionary = Utility.fetchRiderDetail() {
            if(dictionary["isDislaimerAccepted"] == nil) {
                self.showDisclaimer()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.googleMapView.clear()
        self.googleMapView.removeFromSuperview()
        self.googleMapView = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "selectDestViewController" {
            let viewController = segue.destination as! SelectDestViewController
            viewController.rider = self.rider
        }
            else if segue.identifier == "cabBookedViewController" {
                let viewController = segue.destination as! CabBookedViewController
                viewController.rider = self.rider
        }
    }

    func checkAnyBooking() {
        guard let bookingId = self.rider.bookingId else { return }

        if(Int(bookingId) != 0) {
            self.checkAnyExistingOnGoingRyde(self.rider.bookingId!)
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

    func showDisclaimer() {
        let window = UIApplication.shared.keyWindow!
        self.containerView.frame = window.frame
        self.containerView.center = window.center
        self.topViewInContainerView.center = self.containerView.center
        self.containerView.isHidden = false
        self.navigationController?.view.insertSubview(self.containerView, aboveSubview: (self.navigationController?.view)!)
        textView.text = Constants.KDisclaimerString
    }

    func intializeCoreLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.settings.myLocationButton = true
        self.googleMapView.delegate = self
    }
    
    func showUserCurrentLocOnMap(_ currentLatitide : Double, _ currentLongitude : Double) {
        
            self.googleMapView.camera = GMSCameraPosition.camera(withLatitude: currentLatitide, longitude: currentLongitude, zoom: 15.0)
            let currentLocationMarker = GMSMarker()
            let markerImage = UIImage(named: "pickUpMarker")!.withRenderingMode(.alwaysOriginal)
            let markerView = UIImageView(image: markerImage)
            
            currentLocationMarker.position = CLLocationCoordinate2D(latitude: currentLatitide, longitude: currentLongitude)
            currentLocationMarker.iconView = markerView
            currentLocationMarker.map = googleMapView
    }

    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let locationAddress = address.lines! as [String]
                self.rider.sourceLocAddress = locationAddress.joined(separator: "")
                print(address.lines!)
                if(self.googleMapView != nil){
                    self.googleMapView.clear()
                }
                self.getNearByActiveDriver((self.rider.sourceLocCordinate?.coordinate)!)
            }
        }
    }

    func showAlertPopUp(_ message: String) {
        let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
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

    func checkAnyExistingOnGoingRyde(_ bookingId: String) {
        self.showActivityIndicator()
        let bookingViewModel = BookingViewModel()
        bookingViewModel.fetchBookingDetail(bookingId) { (riderDetail, responseCode, message) in
            DispatchQueue.main.async {
                if(riderDetail != nil) {
                    self.removeActivityIndicator()
                    self.rider = riderDetail
                    self.performSegue(withIdentifier: "cabBookedViewController", sender: self)
                } else if(responseCode == Constants.KSessionLogOutErrorCode ) {
                    self.removeActivityIndicator()
                    self.showSessionExpiredPopUp( message!)
                }else if(responseCode == Constants.KAppUpgradationCode ) {
                    self.showAlertPopUp(message!)
                }
                else {
                    self.removeActivityIndicator()
                    self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                }
            }
        }
    }

    func moveToDestinationController() {
        if(self.rider.sourceLocAddress == nil) {
            self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
        } else {
            self.performSegue(withIdentifier: "selectDestViewController", sender: self)
        }
    }

    func getNearByActiveDriver (_ sourceLocCordinate: CLLocationCoordinate2D) {
        let cabViewModel = CabViewModel()
        cabViewModel.fetchNearByActiveDrivers(String(sourceLocCordinate.latitude), String(sourceLocCordinate.longitude), callback: { (driverDetail, message, responseCode) in
            if(responseCode == Constants.KNetworkErrorCode) {
                DispatchQueue.main.async {
                    self.removeActivityIndicator()
                    self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                }
            } else {
                DispatchQueue.main.async {
                    if(driverDetail != nil) {
                        self.showDriverLocationOnMap((driverDetail?.latitude)!, (driverDetail?.longitude)!)
                    }
                }
            }
        })
    }

    func showDriverLocationOnMap(_ latitude: String, _ longitude: String) {

        let currentDriverLocation = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)

        // Driver Marker
        let driverMarker = GMSMarker()
        let driverMarkerImage = UIImage(named: "driverCarIcon")!.withRenderingMode(.alwaysOriginal)
        let driverMarkerView = UIImageView(image: driverMarkerImage)

        //changing the tint color of the image
        driverMarkerView.tintColor = UIColor.orange
        driverMarker.position = CLLocationCoordinate2D(latitude: currentDriverLocation.latitude, longitude: currentDriverLocation.longitude)
        driverMarker.iconView = driverMarkerView
        driverMarker.map = self.googleMapView
    }

    @IBAction func toLocationButtonClicked(_ sender: Any) {
        moveToDestinationController()
    }

    @IBAction func acceptButtonClicked(_ sender: Any) {
        self.containerView.removeFromSuperview()
        Utility.updateRiderDetail(true)
        self.checkAnyBooking()
    }

    @IBAction func pickUpLocationButtonClicked(_ sender: Any) {
        moveToDestinationController()
    }
}

extension HomeScreenViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            manager.stopUpdatingLocation()
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if(self.googleMapView != nil){
                self.googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                self.rider.sourceLocCordinate = location
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
    }
}

// MARK: - GMSMapViewDelegate
extension HomeScreenViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
        
    }
}
