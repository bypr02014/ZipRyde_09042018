//
//  SourceLocationViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/31/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import GoogleMaps

class SourceLocationViewController: UIViewController {

    @IBOutlet var resultTableView: UITableView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var googleMapView: GMSMapView!
    @IBOutlet var serachLocationTextField: UITextField!

    let operationQueue = OperationQueue()
    var placesArray: [String] = []
    let googleAutoCompeteApi = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&location=%@,%@&radius=5000&key=%@"
    let baseURLAddressGeocode = "https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=%@"
    let baseURLCoordinateGeocode = "https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&key=%@"

    var rider: Rider!
    var delegate: UpdateRiderLocation!
    var sourceLocationMarker : GMSMarker!
    var indicatorView: ActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.resultTableView.isHidden = true
        self.serachLocationTextField.delegate = self
        self.googleMapView.delegate = self
        self.googleMapView.settings.consumesGesturesInView = false
        self.googleMapView.addSubview(self.doneButton)
        self.googleMapView.addSubview(self.serachLocationTextField)
        self.googleMapView.addSubview(self.resultTableView)
        self.googleMapView.settings.myLocationButton = true
        self.googleMapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        self.updateMarkerOnMap()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.googleMapView.clear()
        self.googleMapView.removeFromSuperview()
        self.googleMapView = nil
        self.placesArray.removeAll()
    }

    func updateMarkerOnMap() {
        
        if let sourceLatitude = rider.sourceLocCordinate?.coordinate.latitude, let sourceLongitude = rider?.sourceLocCordinate?.coordinate.longitude {
            serachLocationTextField?.text = rider.sourceLocAddress
            self.googleMapView.camera = GMSCameraPosition.camera(withLatitude: sourceLatitude, longitude: sourceLongitude, zoom: 15.0)
            sourceLocationMarker = GMSMarker()
            sourceLocationMarker.isDraggable = true
            let markerImage = UIImage(named: "pickUpMarker")!.withRenderingMode(.alwaysOriginal)
            let markerView = UIImageView(image: markerImage)
            
            sourceLocationMarker.position = CLLocationCoordinate2D(latitude: sourceLatitude, longitude: sourceLongitude)
            sourceLocationMarker.iconView = markerView
            sourceLocationMarker.map = googleMapView
        }
    }

    func beginSearching(_ searchText: String) {
        if searchText.characters.count == 0 {
            placesArray.removeAll()
            self.resultTableView.reloadData()
            return
        }
        operationQueue.addOperation { () -> Void in
            self.forwardGeoCoding(searchText)
        }
    }

    func forwardGeoCoding(_ searchText: String) {
        self.googlePlacesResult(input: searchText) { (result) -> Void in
            let searchResult: NSDictionary = ["keyword": searchText, "results": result]
            if result.count > 0
                {
                let features = searchResult.value(forKey: "results") as! [AnyObject]
                self.placesArray = NSMutableArray(capacity: 100) as! [String]
                for dictAddress in features {

                    let dictionary = dictAddress as! [String: AnyObject]
                    self.placesArray.append(dictionary["description"] as! String)
                }
                DispatchQueue.main.async(execute: {
                    self.resultTableView.reloadData()
                })
            }
        }
    }

    //MARK: - Google place API request -
    func googlePlacesResult(input: String, completion: @escaping (_ result: NSArray) -> Void) {
        let searchWordProtection = input.replacingOccurrences(of: " ", with: "")
        if searchWordProtection.characters.count != 0 {
            let urlString = NSString(format: googleAutoCompeteApi as NSString, input, "12.91126", "77.643512", Constants.KGoogleAPIServerKeyString)
            let url = NSURL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            let defaultConfigObject = URLSessionConfiguration.default
            let delegateFreeSession = URLSession(configuration: defaultConfigObject, delegate: nil, delegateQueue: OperationQueue.main)
            let request = NSURLRequest(url: url! as URL)
            let task = delegateFreeSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    do {
                        let jSONresult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                        let results: NSArray = jSONresult["predictions"] as! NSArray
                        let status = jSONresult["status"] as! String

                        if status == "NOT_FOUND" || status == "REQUEST_DENIED" {

                            let userInfo: NSDictionary = ["error": jSONresult["status"]!]
                            let newError = NSError(domain: "API Error", code: 666, userInfo: userInfo as [NSObject: AnyObject])
                            let placeArray: NSArray = [newError]
                            completion(placeArray)
                            return
                        } else {
                            completion(results)
                        }
                    }
                    catch {
                        print("json error: \(error)")
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }
    }

    func geocodeAddress(address: String, withCompletionHandler completionHandler: @escaping ((CLLocation?) -> Void)) {

        let urlString = NSString(format: baseURLAddressGeocode as NSString, address, Constants.KGoogleAPIServerKeyString)
        let geocodeURL = NSURL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

        DispatchQueue.main.async(execute: { () -> Void in
            do {
                let geocodingResultsData = try Data(contentsOf: geocodeURL! as URL)
                do {
                    var error: NSError?
                    let dictionary: [String: AnyObject] = try JSONSerialization.jsonObject(with: geocodingResultsData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    if (error != nil) {
                        completionHandler(nil)
                    }
                        else {
                            let status = dictionary["status"] as! String
                            if status == "OK" {
                                let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                                let lookupAddressResults: [String: AnyObject] = allResults[0] as! [String: AnyObject]
                                let geometry = lookupAddressResults["geometry"] as! [String: AnyObject]
                                let longitude = ((geometry["location"] as! [String: AnyObject])["lng"] as! NSNumber).doubleValue
                                let latitude = ((geometry["location"] as! [String: AnyObject])["lat"] as! NSNumber).doubleValue
                                let sourceLocation = CLLocation(latitude: latitude, longitude: longitude)
                                completionHandler(sourceLocation)
                            }  else {
                                completionHandler(nil)
                            }
                    }
                }
                catch {
                    print("json error: \(error)")
                }
            } catch {
                print("json error: \(error)")
            }
        })
    }
    
    func geocodeCoordinate(latitude: String, longitude : String, withCompletionHandler completionHandler: @escaping ((String?) -> Void)) {
        
        let urlString = NSString(format: baseURLCoordinateGeocode as NSString, latitude, longitude, Constants.KGoogleAPIServerKeyString)
        let geocodeURL = NSURL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        DispatchQueue.main.async(execute: { () -> Void in
            do {
                let geocodingResultsData = try Data(contentsOf: geocodeURL! as URL)
                do {
                    var error: NSError?
                    let dictionary: [String: AnyObject] = try JSONSerialization.jsonObject(with: geocodingResultsData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    if (error != nil) {
                        completionHandler(nil)
                    }
                    else {
                        let status = dictionary["status"] as! String
                        if status == "OK" {
                            let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                            let lookupAddressResults: [String: AnyObject] = allResults[0] as! [String: AnyObject]
                            let geocodeAddress = lookupAddressResults["formatted_address"] as! String
                            completionHandler(geocodeAddress)
                        }  else {
                            completionHandler(nil)
                        }
                    }
                }
                catch {
                    print("json error: \(error)")
                }
            } catch {
                print("json error: \(error)")
            }
        })
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let locationAddress = address.lines! as [String]
                self.rider.sourceLocAddress = locationAddress.joined(separator: "")
                self.serachLocationTextField.text = locationAddress.joined(separator: "")
                self.getNearByActiveDriver((self.rider.sourceLocCordinate?.coordinate)!)
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.rider.sourceLocCordinate = location
            }
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
    
    func showAlertPopUp(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
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

    @IBAction func doneButtonClicked(_ sender: Any) {
        delegate.update(riderSourceLocDetail: self.rider!)
        self.navigationController?.popViewController(animated: true)
    }

}

extension SourceLocationViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        sourceLocationMarker.position = position.target
        reverseGeocodeCoordinate(position.target)
        
    }
}

extension SourceLocationViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        beginSearching(result)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        resultTableView.isHidden = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        serachLocationTextField.resignFirstResponder()
        return true
    }
}

extension SourceLocationViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableview: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)

        let row = indexPath.row
        cell.textLabel?.text = placesArray[row]
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 10)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 35.0
    }
}

extension SourceLocationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        serachLocationTextField.text = placesArray[row]
        resultTableView.isHidden = true
        serachLocationTextField.resignFirstResponder()
        self.rider?.sourceLocAddress = serachLocationTextField.text
        let sourceAddress = serachLocationTextField.text
        geocodeAddress(address: sourceAddress!) { (location) in
            DispatchQueue.main.async {
                if(location != nil){
                    self.rider?.sourceLocCordinate = location
                    self.googleMapView.clear()
                    self.updateMarkerOnMap()
                }else{
                    self.showAlertPopUp("Location not found")
                }
            }
        }
    }
}
