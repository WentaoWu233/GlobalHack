//
//  ConfirmRequestViewController.swift
//  WentaoWu-JessicaWu-FinalProject
//
//  Created by labuser on 7/26/18.
//  Copyright © 2018 labuser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GooglePlaces
import GoogleMaps
import MapKit
class confirmRequestViewController: UIViewController, GMSAutocompleteViewControllerDelegate, MKMapViewDelegate, GMSMapViewDelegate {
    var studentId: String = ""
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    var formalAddress: String = ""
    @IBOutlet weak var mapView: MKMapView!
    var annotation: MKPlacemark?
    var studentName: String = ""
    var headURL: String = ""
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.view.backgroundColor = .clear
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.blue
        navigationBar?.tintColor = UIColor.white
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Confirm Request"
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //start of code from https://www.ioscreator.com/tutorials/display-date-date-picker-ios-tutorial-ios10
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: sender.date)
        dateLabel.text = strDate
    }
    //end of code from https://www.ioscreator.com/tutorials/display-date-date-picker-ios-tutorial-ios10
    @IBAction func cancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func confirm(_ sender: UIButton) {
        if addressText.text == "" || dateLabel.text == "Choose a time" {
            let alert = UIAlertController(title: "Request failed", message: "You haven't entered a time or place yet", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.view.layoutIfNeeded()
            self.present(alert, animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: "Confirm", message: "Are you sure that you want to request a meeting with this student?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (alert: UIAlertAction!) -> Void in
            let counterRef = Database.database().reference().child("Requests").child("counter")
            counterRef.observeSingleEvent(of: .value, with: { (storedCounter) in
                var counter = storedCounter.value as! Int
                counter = counter + 1
                let ref = Database.database().reference()
                let requestData = ["dateTime" : self.dateLabel.text!, "location" : self.addressText.text!, "immigrant" : Auth.auth().currentUser?.email, "immigrantId": Auth.auth().currentUser?.uid, "student" : self.studentName, "studentId" : self.studentId, "status" : "Pending", "timeRequested" : Date().timeIntervalSinceReferenceDate] as [String : Any]
                ref.child("Requests").child("RequestId"+String(counter)).setValue(requestData)
                let compltVC = self.storyboard?.instantiateViewController(withIdentifier: "completeVC") as! completeViewController
                counterRef.setValue(counter)
                self.present(compltVC, animated: true, completion: nil)
            })
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion:nil)

    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func trigger(_ sender: UITextField) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        self.present(acController, animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.addressText.text = place.formattedAddress
        formalAddress = place.formattedAddress!
        //lines 73-80 from https://stackoverflow.com/questions/45250752/swift-zoom-in-on-location
        let address = (formalAddress as AnyObject)
        let location : String = address as! String
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    if self.annotation != nil {
                        self.mapView.removeAnnotation(self.annotation!)
                    }
                    self.annotation = MKPlacemark(placemark: placemarks.first!)
                    self.mapView.addAnnotation(self.annotation!)
                    //Using it
                    self.mapView.zoomToLocation(location: self.annotation!.coordinate)
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
        self.dismiss(animated: true, completion: nil)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
extension MKMapView{
    func zoomToLocation(location : CLLocationCoordinate2D,latitudinalMeters:CLLocationDistance = 100000,longitudinalMeters:CLLocationDistance = 100000)
    {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
        setRegion(region, animated: true)
    }
    //from https://stackoverflow.com/questions/29731857/how-to-zoom-in-or-out-a-mkmapview-in-swift
    func setZoomByDelta(delta: Double, animated: Bool) {
        var _region = region;
        var _span = region.span;
        _span.latitudeDelta *= delta;
        _span.longitudeDelta *= delta;
        _region.span = _span;
        
        setRegion(_region, animated: animated)
    }
}
