//
//  SelectFareViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/1/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import GoogleMaps

protocol RydeScheduleTime {
    func scheduleRyde(time: String)
}

class SelectFareViewController: UIViewController, RydeScheduleTime {

    @IBOutlet var suggestedPriceLabel: UILabel!
    @IBOutlet var userSelectedPriceLabel: UILabel!
    @IBOutlet var zipMeNowButton: UIButton!
    @IBOutlet var zipMeLaterButton: UIButton!
    @IBOutlet var containerView: UIView!

    var polyRoute: String!
    var rider: Rider!
    var scrollView: UIScrollView!
    let buttonPadding: CGFloat = 10
    var xOffset: CGFloat = 10
    let navigationControllerHeight : CGFloat = 64.0
    var fareList = [Float]()
    var selectedCab: Cab?
    var movedToTrackScreen : Bool = false
    var indicatorView: ActivityIndicatorView!
    var bookingViewModal : BookingViewModel!
    var googleMapView : GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.edgesForExtendedLayout = []
        bookingViewModal = BookingViewModel()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        zipMeNowButton.layer.cornerRadius = 22.5
        zipMeNowButton.clipsToBounds = true
        zipMeLaterButton.layer.cornerRadius = 22.5
        zipMeLaterButton.clipsToBounds = true

        scrollView = UIScrollView ()
        scrollView.center.x = self.view.center.x
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.layer.cornerRadius = 25
        scrollView.clipsToBounds = true
        containerView.addSubview(scrollView)

        scrollView.backgroundColor = UIColor(red: 50 / 255.0, green: 89 / 255.0, blue: 144 / 255.0, alpha: 0.5)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        fareList = (rider.fareList!)
        for i in 0..<fareList.count
        {
            let fareButton = UIButton()
            fareButton.tag = i
            let fare = fareList[i]
            fareButton.backgroundColor = UIColor.clear
            fareButton.setTitle("$" + "\(String(describing: fare))", for: .normal)
            fareButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
            fareButton.addTarget(self, action: #selector(fareButtonClicked(_:)), for: UIControlEvents.touchUpInside)
            fareButton.frame = CGRect(x: xOffset, y: 5, width: 60, height: 35)
            xOffset = xOffset + 5 + fareButton.frame.size.width

            if(i == (fareList.count - 1)) {
                fareButton.setTitleColor(.orange, for: .normal)
            }
            scrollView.addSubview(fareButton)
        }
        scrollView.frame = CGRect(x: (self.view.bounds.width - xOffset) / 2, y: (containerView.bounds.height - 70), width: xOffset, height: 45)
        scrollView.contentSize = CGSize(width: xOffset, height: scrollView.frame.height)

        let suggestedFare: String = String(((rider.fareList)?.last)!)
        suggestedPriceLabel.text = "$\(suggestedFare)"
        userSelectedPriceLabel.text = "$\(suggestedFare)"

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.bookingNotification),
                                               name: NSNotification.Name(rawValue: Constants.KBookingStatusString),
                                               object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "cabBookedViewController" {
            let viewController = segue.destination as! CabBookedViewController
            viewController.rider = self.rider!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showActivityIndicator()
        
        let camera = GMSCameraPosition.camera(withLatitude: (self.rider.sourceLocCordinate?.coordinate.latitude)!,
                                                              longitude: (self.rider.sourceLocCordinate?.coordinate.longitude)!,
                                                             zoom: 15.0)
        let frame = CGRect(x: self.view.bounds.origin.x , y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.containerView.frame.size.height - navigationControllerHeight)
        self.googleMapView = GMSMapView.map(withFrame: frame, camera: camera)
        self.view.addSubview(self.googleMapView)
        self.showPath(polyString: polyRoute!)
        self.setSourceAndDestinationMarker((self.rider.sourceLocCordinate?.coordinate)!, (self.rider.destinationLocCordinate?.coordinate)!)
        self.removeActivityIndicator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.polyRoute.removeAll()
        self.polyRoute = nil
        self.googleMapView.clear()
        self.googleMapView.removeFromSuperview()
        self.googleMapView = nil
    }

    func fareButtonClicked(_ sender: UIButton) {

        for subview in scrollView.subviews { // Loop thorough ScrollView view hierarchy
            if subview is UIButton && subview.tag == sender.tag { // Check if view is type of VisualEffect and tag is equal to the view clicked
                let button = subview as! UIButton
                button.setTitleColor(.orange, for: .normal)
                userSelectedPriceLabel.text = "$\(fareList[sender.tag])"
            } else {
                if(subview is UIButton) {
                    let button = subview as! UIButton
                    button.setTitleColor(.white, for: .normal)
                }
            }
        }
    }

    func showPath(polyString: String) {
        polyRoute = polyString
        let path = GMSPath(fromEncodedPath: polyString)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4.0
        polyline.strokeColor = UIColor.orange
        polyline.map = self.googleMapView
    }

    func setSourceAndDestinationMarker(_ source: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D) {

        // Source Marker
        let sourceMarker = GMSMarker()
        let srcMarkerImage = UIImage(named: "startPointMarker")!.withRenderingMode(.alwaysOriginal)
        let srcMarkerView = UIImageView(image: srcMarkerImage)

        //changing the tint color of the image
        srcMarkerView.tintColor = UIColor.orange
        sourceMarker.position = CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude)
        sourceMarker.iconView = srcMarkerView
        sourceMarker.map = self.googleMapView

        // Destination Marker
        let destinationMarker = GMSMarker()
        let desMarkerImage = UIImage(named: "endPointMarker")!.withRenderingMode(.alwaysOriginal)
        let desMarkerView = UIImageView(image: desMarkerImage)

        //changing the tint color of the image
        desMarkerView.tintColor = UIColor.orange
        destinationMarker.position = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        destinationMarker.iconView = desMarkerView
        destinationMarker.map = self.googleMapView

        let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
        let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(100, 30, 30, 30))
        self.googleMapView!.moveCamera(update)
    }

    func showActivityIndicatorWithMessage() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicatorWithMessage())!)
    }

    func removeActivityIndicator() {
        if(indicatorView != nil) {
            indicatorView.removeIndicator()
            indicatorView = nil
        }
    }

    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }

    func removerObserver() {
        if(!movedToTrackScreen) {
            NotificationCenter.default.removeObserver(self)
            self.getBookingDetail((self.rider.bookingId)!)
        }
    }

    func showCancelledBookingPopUp() {
        let alertController = UIAlertController(title: "Booking Cancelled", message: "No \(String(describing: (self.rider.cab?.type)!)) available / Driver not accepting the request.", preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            for viewController in (self.navigationController?.viewControllers)! {
                if(viewController is HomeScreenViewController) {
                    self.showActivityIndicator()
                    self.bookingViewModal.updateBookingStatus(self.rider.bookingId!) { (bookingStatus, responseCode) in
                        if(responseCode == Constants.KNetworkErrorCode) {
                            self.removeActivityIndicator()
                            self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                        } else {
                            DispatchQueue.main.async {
                                if(bookingStatus == Constants.KBookingDriverZipCancelled) {
                                    for viewController in (self.navigationController?.viewControllers)! {
                                        if(viewController is HomeScreenViewController) {
                                            self.removeActivityIndicator()
                                            self.navigationController?.isNavigationBarHidden = false
                                            self.navigationController!.popToViewController(viewController, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func showAlertPopUp(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showSuccessBookingPopUp() {
        let alertController = UIAlertController(title: "Booking Successful", message: "Get ready. Driver is on the way.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Done", style: .default) { (action: UIAlertAction!) in

             Utility.saveBookingId(self.rider.bookingId!)
            self.performSegue(withIdentifier: "cabBookedViewController", sender: self)
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessScheduledBookingPopUp() {
        let alertController = UIAlertController(title: "Booking Successful", message: "Your trip has been scheduled successfully.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Done", style: .default) { (action: UIAlertAction!) in
            
            for viewController in (self.navigationController?.viewControllers)! {
                if(viewController is HomeScreenViewController) {
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController!.popToViewController(viewController, animated: true)
                }
            }
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func getBookingDetail(_ bookingId: String) {
        self.bookingViewModal.fetchBookingDetailByBookingId(bookingId) { (driverDetail, responseCode) in
            if(responseCode == Constants.KNetworkErrorCode) {
                self.removeActivityIndicator()
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            } else {
                DispatchQueue.main.async {
                    self.removeActivityIndicator()
                    if(driverDetail?.bookingStatusCode! == Constants.KBookingStatus_Scheduled) {
                        self.rider.driverDetail = driverDetail
                        self.showSuccessBookingPopUp()
                    }else if (driverDetail?.bookingStatusCode! == Constants.KBookingStatus_Accepted){
                        self.showSuccessScheduledBookingPopUp()
                    } else if(driverDetail?.bookingStatusCode! == Constants.KBookingStatus_Requested ||
                        driverDetail?.bookingStatusCode! == Constants.KBookingStatus_FutureRequested) {
                        self.removeActivityIndicator()
                        self.showCancelledBookingPopUp()
                    }
                }
            }
        }
    }

    func bookingNotification(notification: Notification) -> Void {

        movedToTrackScreen = true
        let notificationInfo = notification.userInfo as! [String: Any]
        let bookingId = notificationInfo["bookingId"] as? String
        let notificationType = notificationInfo["notificationType"] as? String

        if(Constants.KBookingUserConfirmation == notificationType) {
            self.rider.bookingId = bookingId
            self.removeActivityIndicator()
            self.getBookingDetail((self.rider.bookingId)!)
        }
    }

    func scheduleRyde(time: String) {
        bookRyde(scheduleDateTime: time)
    }

    func bookRyde(scheduleDateTime: String!) {

        self.showActivityIndicatorWithMessage()
        var suggestedFare: String = suggestedPriceLabel.text!
        var selectedFare: String = userSelectedPriceLabel.text!
        let ryderCount: String = String(self.rider.passengerCount!)
        let cabTypeId = (self.rider.cab?.cabTypeId)!
        let riderId = (self.rider.userId)!
        let sourceAddress = (self.rider.sourceLocAddress)!
        let destinationAddress = (self.rider.destinationLocAddress)!

        guard let sourceLatitude = self.rider.sourceLocCordinate?.coordinate.latitude, let sourceLongitude = self.rider.sourceLocCordinate?.coordinate.longitude,
            let destinationLatitude = self.rider.destinationLocCordinate?.coordinate.latitude, let destinationLongitude = self.rider.destinationLocCordinate?.coordinate.longitude,
            let travelDistance = self.rider.distanceInMiles
            else {
                return
        }

        let geoLocationDetail: [String: Any] = ["fromLatitude": sourceLatitude,
                                                "fromLongitude": sourceLongitude,
                                                "toLatitude": destinationLatitude,
                                                "toLongitude": destinationLongitude,
                                                "distanceInMiles": String(travelDistance)]

        suggestedFare = suggestedFare.replacingOccurrences(of: "$", with: "")
        selectedFare = selectedFare.replacingOccurrences(of: "$", with: "")

        self.bookingViewModal.requestBooking(cabTypeId, riderId, scheduleDateTime, sourceAddress, destinationAddress, geoLocationDetail, suggestedFare, selectedFare ,ryderCount){
            (bookingId, responseCode) in
            if(responseCode == Constants.KNetworkErrorCode) {
                self.removeActivityIndicator()
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            } else {
                self.rider.bookingId = bookingId
                let when = DispatchTime.now() + 60
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.removerObserver()
                }
            }
        }
    }

    @IBAction func zipMeNowButtonClicked(_ sender: Any) {
        bookRyde(scheduleDateTime: nil)
    }

    @IBAction func zipMeLaterButtonClicked(_ sender: Any) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let calenderViewController: CalenderViewController = storyboard.instantiateViewController(withIdentifier: "calenderViewController") as! CalenderViewController
        calenderViewController.delegate = self
        calenderViewController.modalPresentationStyle = .overCurrentContext
        calenderViewController.view.backgroundColor = UIColor.clear
        self.present(calenderViewController, animated: false, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


















