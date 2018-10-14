//
//  registerViewController.swift
//  MatchX
//
//  Created by Luxiao Zheng on 10/12/18.
//  Copyright © 2018 TeamK. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import GoogleMaps
import GooglePlaces
class registerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    var student: Bool = false;
    var immi: Bool = false
    var formalAddress: String = ""
    @IBOutlet weak var area: UITextField!
    @IBOutlet weak var radioStudent: UIButton!
    @IBOutlet weak var radioImmigrant: UIButton!
    @IBOutlet weak var registerProgress: UIProgressView!
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var language: UITextField!
    var headShot: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func register(_ sender: UIButton) {
        if email.text != "" && pwd.text != "" && username.text != "" && phone.text != "" && headShot != nil && language.text != "" && area.text != ""{
            for char in phone.text!.characters {
                if (char > "9" || char < "0") && char != "-" {
                    let msg = "Invalid Phone Number"
                    let alert = UIAlertController(title: "Register failed", message: msg, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    alert.view.layoutIfNeeded()
                    self.present(alert, animated: true, completion: nil)
                    self.registerProgress.isHidden = true
                    self.registerProgress.progress = 0
                    return
                }
            }
            registerProgress.isHidden = false
            Auth.auth().createUser(withEmail: email.text!, password: pwd.text!, completion: { (authResult, error) -> Void in
                if (error == nil) {
                    self.registerProgress.setProgress(0.25, animated: true)
                    let uid = authResult?.user.uid
                    let storageRef = Storage.storage().reference(forURL: "gs://matchx-f07fb.appspot.com").child("profile_image").child(uid!)
                    
                    print("Account created :)")
                    var userData = ["phone":self.phone.text!, "displayName":self.username.text!, "email":self.email.text!]
                    let ref = Database.database().reference()
                    self.registerProgress.setProgress(0.35, animated: true)
                    if let profileImg = self.headShot, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
                        storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                return
                            }
                            self.registerProgress.setProgress(0.5, animated: true)
                            var profileImageUrl = ""
                            storageRef.downloadURL{ (url, error) in
                                if error != nil {
                                    print(error)
                                    return
                                }else {
                                    self.registerProgress.setProgress(0.75, animated: true)
                                    profileImageUrl = url?.absoluteString ?? ""
                                    userData["headURL"] = profileImageUrl
                                    userData["language"] = self.language.text!
                                    userData["area"] = self.area.text!
                                    

                                    if self.student {
                                        userData["status"] = "student"
                                        ref.child("users").child((authResult?.user.uid)!).setValue(userData)
                                        self.registerProgress.setProgress(1.0, animated: true)
                                    }else {
                                        userData["status"] = "immigrant"
                                        ref.child("users").child((authResult?.user.uid)!).setValue(userData)
                                        self.registerProgress.setProgress(1.0, animated: true)
                                    }
                                    

                                    let tabC = self.storyboard?.instantiateViewController(withIdentifier: "tabCon")
                                    
                                    self.present(tabC!, animated: true, completion: nil)
                                }
                            }
                            
                        })
                    }
                }else{
                    let msg = error?.localizedDescription ?? "Unknown Reason"
                    let alert = UIAlertController(title: "Register failed", message: msg, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    alert.view.layoutIfNeeded()
                    self.present(alert, animated: true, completion: nil)
                    self.registerProgress.isHidden = true
                    self.registerProgress.progress = 0
                }
            })
        }else{
            var msg = ""
            if headShot != nil {
                msg = "One or more of the fields is empty"
            }else{
                msg = "Please choose a profile picture"
            }
            let alert = UIAlertController(title: "Register failed", message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.view.layoutIfNeeded()
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func chooseHead(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        imageDisplay.image = selectedImage
        headShot = imageDisplay.image
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    @IBAction func ToggleStudent (_ sender: UIButton) {
        if !student {
            radioStudent.setImage(UIImage(named: "solid"), for: .normal)
            radioImmigrant.setImage(UIImage(named: "hollow"), for: .normal)
            student = true
            immi = false
        }
    }
    @IBAction func ToggleImmigrant(_ sender: UIButton) {
        if !immi {
            radioImmigrant.setImage(UIImage(named: "solid"), for: .normal)
            radioStudent.setImage(UIImage(named: "hollow"), for: .normal)
            student = false
            immi = true
        }
    }
    @IBAction func trigger(_ sender: UITextField) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        self.present(acController, animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.area.text = place.formattedAddress
        formalAddress = place.formattedAddress!
        //lines 73-80 from https://stackoverflow.com/questions/45250752/swift-zoom-in-on-location
        let address = (formalAddress as AnyObject)
        let location : String = address as! String
        let geocoder = CLGeocoder()
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
