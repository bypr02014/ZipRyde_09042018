//
//  SelectCabViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/31/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import GoogleMaps

class SelectCabViewController: UIViewController {

    @IBOutlet var getZipFareButton: UIButton!
    @IBOutlet var containerView: UIView!

    @IBOutlet var leftSideCarName: UIButton!
    @IBOutlet var leftSideCarImage: UIImageView!
    @IBOutlet var leftSideCarATLabel: UILabel!

    @IBOutlet var middleCarName: UIButton!
    @IBOutlet var middleCarImage: UIImageView!
    @IBOutlet var middleCarATLabel: UILabel!

    @IBOutlet var rightSideCarName: UIButton!
    @IBOutlet var rightSideCarATLabel: UILabel!
    @IBOutlet var rightSideCarImage: UIImageView!

    @IBOutlet var containerviewForSeat: UIView!
    @IBOutlet var userSelectedSeatCountLabel: UILabel!
    @IBOutlet var noOfSeatCountLabel: UILabel!
    @IBOutlet var showPickerButton: UIButton!
    
    let navigationControllerHeight : CGFloat = 64.0
    var source: CLLocationCoordinate2D!
    var destination: CLLocationCoordinate2D!
    var polyRoute: String!
    var seatCountArray = [Int]()
    var indicatorView: ActivityIndicatorView?
    var selectedCab: Cab?
    var rider: Rider!
    var cabViewModel : CabViewModel!
    var googleMapView : GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isTranslucent = false;
    
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.showActivityIndicator()
    
        self.getZipFareButton.layer.cornerRadius = 22.5
        self.getZipFareButton.clipsToBounds = true

        self.containerviewForSeat.layer.cornerRadius = 17
        self.containerviewForSeat.clipsToBounds = true

        self.source = (rider.sourceLocCordinate?.coordinate)!
        self.destination = (rider?.destinationLocCordinate?.coordinate)!

        let camera = GMSCameraPosition.camera(withLatitude: self.source.latitude, longitude: self.source.longitude, zoom: 15.0)
        let frame = CGRect(x: self.view.bounds.origin.x , y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.containerView.frame.size.height - navigationControllerHeight)
        self.googleMapView = GMSMapView.map(withFrame: frame, camera: camera)
        self.view.addSubview(self.googleMapView)
        self.googleMapView.settings.consumesGesturesInView = true
        
        self.cabViewModel = CabViewModel()
        self.retriveAllCabTypes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(self.googleMapView == nil) {
            let camera = GMSCameraPosition.camera(withLatitude: self.source.latitude, longitude: self.source.longitude, zoom: 15.0)
            let frame = CGRect(x: self.view.bounds.origin.x , y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height - self.containerView.frame.size.height)
            self.googleMapView = GMSMapView.map(withFrame: frame, camera: camera)
            self.view.addSubview(self.googleMapView)
        }
        
        self.getPolylineRoute(source, destination)
        self.setSourceAndDestinationMarker(source, destination)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.polyRoute.removeAll()
        //self.polyRoute = nil
        self.googleMapView.clear()
        self.googleMapView.removeFromSuperview()
        self.googleMapView = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "selectFareViewController" {
            self.rider?.cab = selectedCab
            let viewController = segue.destination as! SelectFareViewController
            viewController.rider = self.rider!
            viewController.polyRoute = self.polyRoute!
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
        self.polyRoute = polyString
        let path = GMSPath(fromEncodedPath: polyString)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4.0
        polyline.strokeColor = UIColor.orange
        polyline.map = self.googleMapView
    }

    func retriveAllCabTypes () {
        self.cabViewModel.fetchAllCabTypes { (cabDetails, message, responseCode) in
            if(responseCode == Constants.KNetworkErrorCode) {
                self.removeActivityIndicator()
                self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
            } else {
                if(message != nil) {
                    DispatchQueue.main.async {
                        self.removeActivityIndicator()
                        self.showSessionExpiredPopUp(message!)
                    }
                }
                if(cabDetails != nil) {
                     self.cabViewModel.fetchNearByActiveDrivers(String(self.source.latitude), String(self.source.longitude), callback: { (driverDetail, message, responseCode) in
                        if(responseCode == Constants.KNetworkErrorCode) {
                            self.removeActivityIndicator()
                            self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                        } else {
                            if(message != nil) {
                                DispatchQueue.main.async {
                                    self.removeActivityIndicator()
                                    self.showSessionExpiredPopUp(message!)
                                }
                            }
                            if(driverDetail != nil) {

                                self.rider?.driverDetail = driverDetail!
                                self.cabViewModel.calculateTimeBetweenCoordinates(String(self.source.latitude), String(self.source.longitude), (driverDetail?.latitude)!, (driverDetail?.longitude)!, callback: { (arrivalTime) in

                                    self.rider?.driverDetail?.arrivalTime = arrivalTime
                                    DispatchQueue.main.async {
                                        self.configureCarDetails(cabDetails!, self.rider.driverDetail!)
                                        self.removeActivityIndicator()
                                    }
                                })
                            }
                                else {
                                    DispatchQueue.main.async {
                                        self.removeActivityIndicator()
                                        let newframe = CGRect(x: self.view.bounds.origin.x , y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height: self.view.bounds.size.height )
                                        self.googleMapView .frame = newframe
                                        self.containerView.removeFromSuperview()
                                        self.showZipRydeNotAvailableMessage()
                                    }
                            }
                        }
                    })
                }
            }
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

    func showSessionExpiredPopUp(_ message: String) {
        let alertController = UIAlertController(title: "Information", message: message, preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            Utility.deleteRiderDetail()
            self.dismiss(animated: true, completion: nil)
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func showZipRydeNotAvailableMessage() {
        let errorMessageView: UIView = UIView()
        errorMessageView.frame = CGRect(x: 0, y: self.googleMapView.bounds.height - 100, width: self.googleMapView.bounds.width, height: 100)
        errorMessageView.backgroundColor = UIColor(red: 61 / 255.0, green: 110 / 255.0, blue: 179 / 255.0, alpha: 1.0)

        let msgLabel = UILabel(frame: CGRect(x: 0, y: errorMessageView.bounds.origin.y, width: self.googleMapView.bounds.width, height: 100))
        msgLabel.font = UIFont.boldSystemFont(ofSize: 16)
        msgLabel.textColor = .white
        msgLabel.textAlignment = .center
        msgLabel.text = Constants.KZipRydeNotAvailableString
        msgLabel.numberOfLines = 0
        errorMessageView.addSubview(msgLabel)
        self.googleMapView.addSubview(errorMessageView)
    }

    func intializeSeatCount (seatCount: Int) {
        rider?.passengerCount = 1
        userSelectedSeatCountLabel.text = "1"
        noOfSeatCountLabel.text = "Seats 1-\(seatCount)"
        for i in 1...seatCount {
            seatCountArray.append(i)
        }
    }

    func configureCarDetails(_ cabs: [Cab], _ driver: Driver) {

        let leftSideCab = cabs[0]
        leftSideCarName.setTitle(leftSideCab.type, for: .normal)
        leftSideCarImage.image = UIImage(named: "micro_white_color")
        if(driver.cabType == leftSideCab.type) {
            leftSideCarATLabel.text = driver.arrivalTime
            self.intializeSeatCount(seatCount: leftSideCab.seatingCapacity!)
            selectedCab = leftSideCab
            leftSideCarName.setTitleColor(.orange, for: .normal)
        }
            else {
                leftSideCarName.isEnabled = false
        }

        let middleCab = cabs[1]
        middleCarName.setTitle(middleCab.type, for: .normal)
        middleCarImage.image = UIImage(named: "sedan_white_color")
        if(driver.cabType == middleCab.type) {
            middleCarATLabel.text = driver.arrivalTime
            self.intializeSeatCount(seatCount: middleCab.seatingCapacity!)
            selectedCab = middleCab
            middleCarName.setTitleColor(.orange, for: .normal)
        }
            else {
                middleCarName.isEnabled = false
        }

        let rightSideCab = cabs[2]
        rightSideCarName.setTitle(rightSideCab.type, for: .normal)
        rightSideCarImage.image = UIImage(named: "suv_white_color")
        if(driver.cabType == rightSideCab.type) {
            rightSideCarATLabel.text = driver.arrivalTime
            self.intializeSeatCount(seatCount: rightSideCab.seatingCapacity!)
            selectedCab = rightSideCab
            rightSideCarName.setTitleColor(.orange, for: .normal)
        }
            else {
                rightSideCarName.isEnabled = false
        }
    }

    func showPassengerPicker() {
        let pickerView: UIPickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200)
        pickerView.backgroundColor = UIColor.white
        pickerView.layer.borderColor = UIColor.white.cgColor

        indicatorView = ActivityIndicatorView ()
        let grayView = indicatorView?.showGreyOutView()
        pickerView.center = (grayView?.center)!
        grayView?.addSubview(pickerView)
        self.navigationController?.view.addSubview(grayView!)
    }

    func removePicker() {
        indicatorView?.removeGreyOutView()
    }

    func distanceBetweenTwoLocations(source: CLLocation, destination: CLLocation) -> Float {

        let distanceInMeters = source.distance(from: destination)
        let distanceInMiles = distanceInMeters / 1609.344
        return Float(distanceInMiles)
    }

    @IBAction func getZipFareButtonClicked(_ sender: Any) {

        let distanceInMiles = self.distanceBetweenTwoLocations(source: (rider?.sourceLocCordinate)!, destination: (rider?.destinationLocCordinate)!)
        self.rider?.distanceInMiles = distanceInMiles.roundTwoDigit
        self.cabViewModel.getAllNYOPByCabTypeDistAndNoOfPassenger(String(distanceInMiles), (selectedCab?.cabTypeId)!, Int(userSelectedSeatCountLabel.text!)!,
                                                callback: { (cabFare, message, responseCode) in
                                                    if(responseCode == Constants.KNetworkErrorCode) {
                                                        self.removeActivityIndicator()
                                                        self.showAlertPopUp(Constants.KNetworkConnectionIssueString)
                                                    } else {
                                                        if(message != nil) {
                                                            self.removeActivityIndicator()
                                                            self.showSessionExpiredPopUp(message!)
                                                            return
                                                        }
                                                        self.rider?.fareList = cabFare
                                                        DispatchQueue.main.async {
                                                            self.performSegue(withIdentifier: "selectFareViewController", sender: self)
                                                        }
                                                    }
                                                })
    }

    @IBAction func selectSeatButtonClicked(_ sender: Any) {
        self.showPassengerPicker()
    }
}

extension SelectCabViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seatCountArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(seatCountArray[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(seatCountArray[row])
        rider?.passengerCount = seatCountArray[row]
        userSelectedSeatCountLabel.text = String(seatCountArray[row])
        removePicker()
    }
}







