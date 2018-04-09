//
//  CabBookedViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 9/1/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import GoogleMaps

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class CabBookedViewController: UIViewController {

    @IBOutlet var topContainerView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var fromAddressLabel: UILabel!
    @IBOutlet var toAddressLabel: UILabel!
    @IBOutlet var cabTypeLabel: UILabel!
    @IBOutlet var cabImageView: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var driverNameLabel: UILabel!
    @IBOutlet var driverImageView: UIImageView!
    @IBOutlet var callButton: UIButton!

    var driverStatusUpdateTimer: Timer!
    var rider: Rider!
    var currentDriverLocation: CLLocationCoordinate2D!
    var driverMarker: GMSMarker!
    var source: CLLocationCoordinate2D!
    var destination: CLLocationCoordinate2D!
    var indicatorView: ActivityIndicatorView?
    var bookingDataSource : BookingViewModel!
    var googleMapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        bookingDataSource = BookingViewModel()
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.showActivityIndicator()
        let camera = GMSCameraPosition.camera(withLatitude: (self.rider.sourceLocCordinate?.coordinate.latitude)!,
                                              longitude: (self.rider.sourceLocCordinate?.coordinate.longitude)!,
                                              zoom: 15.0)
        let frame = CGRect(x: self.view.bounds.origin.x, y: 88, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 198)
        self.googleMapView = GMSMapView.map(withFrame: frame, camera: camera)
        self.view.addSubview(self.googleMapView)

       
        driverImageView.layer.cornerRadius = 25
        driverImageView.clipsToBounds = true

        fromAddressLabel.text = self.rider.sourceLocAddress
        toAddressLabel.text = self.rider.destinationLocAddress

        source = (rider.sourceLocCordinate?.coordinate)!
        destination = (rider?.destinationLocCordinate?.coordinate)!

        getPolylineRoute(source, destination)
        setSourceAndDestinationMarker(source, destination)

        self.addNotificationObserver()
        self.setDriverDetails(self.rider.driverDetail!)
        self.updateDriverStatus((self.rider.driverDetail?.bookingStatus)!)
        self.cabTypeLabel.text = self.rider.driverDetail?.cabType
        let cabImageName = Utility.getWhiteCabImageBasedOnCabType(cabType: (self.rider.driverDetail?.cabType)!)
        self.cabImageView.image = UIImage(named: cabImageName)
        self.fetchDriverCurrentLocation()
        self.fetchDriverMobileNumber()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.googleMapView.clear()
        self.googleMapView.removeFromSuperview()
        self.googleMapView = nil
        self.source = nil
        self.destination = nil
        self.driverMarker = nil
        self.currentDriverLocation = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "rydeCompletedViewController" {
            let viewController = segue.destination as! RydeCompletedViewController
            viewController.rider = self.rider!
        }
    }

    func showAlertPopUp(_ message: String) {
        DispatchQueue.main.async {
            self.removeActivityIndicator()
            let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func getPolylineRoute(_ source: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D) {

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        print(source.latitude, source.longitude, destination.latitude, destination.longitude)
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=\(Constants.KGoogleAPIServerKeyString)")!

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
                else {
                    do {
                        if let json: [String: Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {

                            guard let routes = json["routes"] as? NSArray else {
                                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                                return
                            }
                            if (routes.count > 0) {
                                let overview_polyline = routes[0] as? NSDictionary
                                let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                                let points = dictPolyline?.object(forKey: "points") as? String

                                DispatchQueue.main.async {
                                    self.showPath(polyString: points!)
                                    let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                    let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(100, 30, 100, 30))
                                    self.googleMapView!.moveCamera(update)
                                }
                            }
                                else {
                                    self.showAlertPopUp("No route found between source and destination address.")
                            }
                        }
                    }
                    catch {
                        print("error in JSONSerialization")
                    }
            }
        })
        task.resume()
    }

    func showPath(polyString: String) {
        let path = GMSPath(fromEncodedPath: polyString)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4.0
        polyline.strokeColor = UIColor.orange
        polyline.map = self.googleMapView
    }

    func fetchDriverMobileNumber() {
        self.bookingDataSource.fetchDriverNumber(self.rider.bookingId!) { (mobileNumber, responseCode) in
            if(responseCode == Constants.KNetworkErrorCode) {
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            } else if(responseCode == Constants.KNetworkSuccessCode) {
                DispatchQueue.main.async {
                    self.rider.driverDetail?.mobile = mobileNumber
                    self.removeActivityIndicator()
                    self.driverStatusUpdateTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(CabBookedViewController.fetchDriverCurrentLocation), userInfo: nil, repeats: true)
                }
            }else{
                DispatchQueue.main.async {
                    self.removeActivityIndicator()
                    self.driverStatusUpdateTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(CabBookedViewController.fetchDriverCurrentLocation), userInfo: nil, repeats: true)
                }
            }
        }
    }


    func fetchDriverCurrentLocation () {
        self.bookingDataSource.fetchDriverLocation ((self.rider.driverDetail?.driverId)!) { (latitude, longitude, bookingStatus, responseCode) in
            if(responseCode == Constants.KNetworkErrorCode) {
                self.removeActivityIndicator()
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            } else {
                guard let latitudeValue :String = latitude , let longitudeValue : String = longitude  else {
                        return
                    }
                    let latitudeDouble = Double(latitudeValue)
                    let longitudeDouble = Double(longitudeValue)
                    let updatedDriverLocation = CLLocationCoordinate2D(latitude: latitudeDouble!, longitude: longitudeDouble!)
                    DispatchQueue.main.async {
                        if(self.currentDriverLocation == nil) {
                            self.showDriverLocationOnMap(latitudeValue, longitudeValue)
                        } else {
                            if(bookingStatus != Constants.KBookingDriverZipCompleted){
                                self.updateDriverLocationOnMap(self.currentDriverLocation, updatedDriverLocation)
                            }
                        }
                        self.currentDriverLocation = updatedDriverLocation
                        guard let status = bookingStatus else { return }
                        self.updateDriverStatus(status)
                }
            }
        }
    }

    func addNotificationObserver() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.bookingStatusNotification),
                                               name: NSNotification.Name(rawValue: Constants.KBookingStatusString),
                                               object: nil)
    }

    func setDriverDetails(_ driver: Driver) {
        driverNameLabel.text = driver.name
        //driverImageView.image = driver.driverPhoto
    }

    func updateDriverStatus(_ status: String) {
        statusLabel.text = status
        if(status == Constants.KBookingDriverZipCompleted) {
            rydeCompleted()
        } else if (status == Constants.KBookingDriverOnZip) {
            hideCancelAndCallButton()
        }
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

    func showDriverLocationOnMap(_ latitude: String, _ longitude: String) {

        currentDriverLocation = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)

        // Driver Marker
        self.driverMarker = GMSMarker()
        let driverMarkerImage = UIImage(named: "driverCarIcon")!.withRenderingMode(.alwaysOriginal)
        let driverMarkerView = UIImageView(image: driverMarkerImage)

        //changing the tint color of the image
        driverMarkerView.tintColor = UIColor.orange
        self.driverMarker.position = CLLocationCoordinate2D(latitude: currentDriverLocation.latitude, longitude: currentDriverLocation.longitude)
        self.driverMarker.iconView = driverMarkerView
        self.driverMarker.map = self.googleMapView
    }

    func updateDriverLocationOnMap(_ oldCoodinate: CLLocationCoordinate2D, _ newCoodinate: CLLocationCoordinate2D) {
        
        if(self.driverMarker != nil){
            self.driverMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
            self.driverMarker.rotation = CLLocationDegrees(self.getDriverHeadingDirection(oldCoodinate, newCoodinate))
            self.driverMarker.position = oldCoodinate
            self.driverMarker.map = googleMapView
            CATransaction.begin()
            CATransaction.setValue(Int(2.0), forKey: kCATransactionAnimationDuration)
            CATransaction.setCompletionBlock({ () -> Void in
                self.driverMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                self.driverMarker.rotation = 0
            })
            self.driverMarker.position = newCoodinate
            self.driverMarker.map = self.googleMapView
            self.driverMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
            self.driverMarker.rotation = CLLocationDegrees(self.getDriverHeadingDirection(oldCoodinate, newCoodinate))
            CATransaction.commit()
        }
    }

    func getDriverHeadingDirection(_ fromLoc: CLLocationCoordinate2D, _ toLoc: CLLocationCoordinate2D) -> Float {

        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        if degree >= 0 {
            return degree
        }
            else {
                return 360 + degree
        }
    }

    func bookingStatusNotification(notification: Notification) -> Void {

        let notificationInfo = notification.userInfo as! [String: Any]
        let notificationType = notificationInfo["notificationType"] as! String

        switch notificationType {
        case Constants.KBookingDriverOnSite:
            updateDriverStatus(Constants.KBookingDriverStatusOnSite)
            hideCancelAndCallButton()
            break
        case Constants.KBookingDriverOnTrip:
            updateDriverStatus(Constants.KBookingDriverOnZip)
            break
        case Constants.KBookingDriverCompleted:
            updateDriverStatus(Constants.KBookingDriverZipCompleted)
            break
        default:
            break
        }
    }

    func hideCancelAndCallButton() {
        cancelButton.isHidden = true
        callButton.isHidden = true
    }

    func rydeCompleted() {
        if(driverStatusUpdateTimer != nil){
            driverStatusUpdateTimer.invalidate()
            driverStatusUpdateTimer = nil
            Utility.saveBookingId("0")
            self.performSegue(withIdentifier: "rydeCompletedViewController", sender: self)
        }
    }

    func showActivityIndicator() {
        indicatorView = ActivityIndicatorView ()
        self.navigationController?.view.addSubview((indicatorView?.showIndicator())!)
    }

    func removeActivityIndicator() {
        DispatchQueue.main.async {
            self.indicatorView?.removeIndicator()
        }
    }


    @IBAction func cancelButtonClicked(_ sender: Any) {
        showActivityIndicator()
        self.bookingDataSource.updateBookingStatus(self.rider.bookingId!) { (bookingStatus, responseCode) in
            if(responseCode == Constants.KNetworkErrorCode) {
                self.removeActivityIndicator()
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            } else {
                DispatchQueue.main.async {
                    if(bookingStatus == Constants.KBookingDriverZipCancelled) {
                        for viewController in (self.navigationController?.viewControllers)! {
                            if((viewController is HomeScreenViewController) || (viewController is ScheduleRydesViewController)) {
                                self.driverStatusUpdateTimer.invalidate()
                                self.driverStatusUpdateTimer = nil
                                Utility.saveBookingId("0")
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

    @IBAction func callButtonClicked(_ sender: Any) {
        
        let mobileNumber : String =  (self.rider.driverDetail?.mobile)!
        guard let number = URL(string: "telprompt://\(mobileNumber)") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(number)
        } else {
            UIApplication.shared.openURL(number)
        }
    }
}







