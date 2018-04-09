//
//  SelectDestViewController.swift
//  ZipRyde
//
//  Created by Ashish jha on 8/30/17.
//  Copyright © 2017 xyz. All rights reserved.
//

import UIKit
import CoreLocation

protocol UpdateRiderLocation {
    func update(riderSourceLocDetail: Rider)
}

class SelectDestViewController: UIViewController, UpdateRiderLocation {

    @IBOutlet var fromLocationTextField: UITextField!
    @IBOutlet var toLocationTextField: UITextField!
    @IBOutlet var searchPlaceTableView: UITableView!
    var operationQueue : OperationQueue!
    var placesArray: [String] = []
    let googleAutoCompeteApi = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&location=%@,%@&radius=5000&key=%@"
    let baseURLAddressGeocode = "https://maps.googleapis.com/maps/api/geocode/json?address=%@&key=%@"
    var rider: Rider!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        toLocationTextField.delegate = self
        fromLocationTextField.delegate = self
        searchPlaceTableView.isHidden = true
        operationQueue = OperationQueue()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let fromLocation = rider?.sourceLocAddress {
            fromLocationTextField.text = fromLocation
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sourceLocationViewController" {
            let viewController = segue.destination as! SourceLocationViewController
            viewController.delegate = self
            viewController.rider = self.rider!
        }
        else if segue.identifier == "selectCabViewController" {
            let viewController = segue.destination as! SelectCabViewController
            viewController.rider = self.rider!
        }
    }

    func update(riderSourceLocDetail: Rider) {
        rider?.sourceLocCordinate = riderSourceLocDetail.sourceLocCordinate
        rider?.sourceLocAddress = riderSourceLocDetail.sourceLocAddress
        rider?.destinationLocCordinate = riderSourceLocDetail.destinationLocCordinate
        rider?.destinationLocAddress = riderSourceLocDetail.destinationLocAddress
    }

    func beginSearching(_ searchText: String) {
        if searchText.characters.count == 0 {
            placesArray.removeAll()
            self.searchPlaceTableView.reloadData()
            return
        }
        operationQueue.addOperation { () -> Void in
            self.forwardGeoCoding(searchText)
        }
    }

    //MARK: - Search place from Google -
    func forwardGeoCoding(_ searchText: String) {
        self.googlePlacesResult(input: searchText) { (result) -> Void in
            let searchResult: NSDictionary = ["keyword": searchText, "results": result]
            if result.count > 0 {
                let features = searchResult.value(forKey: "results") as! [AnyObject]
                self.placesArray = NSMutableArray(capacity: 100) as! [String]
                for dictAddress in features {

                    let dictionary = dictAddress as! [String: AnyObject]
                    self.placesArray.append(dictionary["description"] as! String)
                }
                DispatchQueue.main.async(execute: {
                    self.searchPlaceTableView.reloadData()
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
                            let array: NSArray = [newError]
                            completion(array)
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
                            let destLocation = CLLocation(latitude: latitude, longitude: longitude)
                            completionHandler(destLocation)
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
    
    func showAlertPopUp(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func selectToLocation(_ sender: Any) {

        self.performSegue(withIdentifier: "sourceLocationViewController", sender: self)
    }
    
    deinit {
        self.placesArray.removeAll()
        operationQueue = nil
    }
}


extension SelectDestViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        beginSearching(result)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchPlaceTableView.isHidden = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toLocationTextField.resignFirstResponder()
        return true
    }
}

extension SelectDestViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableview: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)

        let row = indexPath.row
        cell.textLabel?.text = self.placesArray[row]
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 10)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 35.0
    }
}

extension SelectDestViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        toLocationTextField.text = self.placesArray[row]
        searchPlaceTableView.isHidden = true
        toLocationTextField.resignFirstResponder()
        self.rider?.destinationLocAddress = toLocationTextField.text
        let destAddress = toLocationTextField.text
        geocodeAddress(address: destAddress!) { (location) in
            DispatchQueue.main.async {
                if(location != nil){
                    self.rider?.destinationLocCordinate = location
                    self.performSegue(withIdentifier: "selectCabViewController", sender: self)
                }else{
                    self.showAlertPopUp("Location not found")
                }
            }
        }
    }
}

