//
//  ViewController.swift
//  MatchX
//
//  Created by Luxiao Zheng on 10/12/18.
//  Copyright © 2018 TeamK. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController {

    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var progress: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        progress.setProgress(0, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func login(_ sender: UIButton) {
        if email.text != "" && pwd.text != "" {
            progress.isHidden = false
            self.progress.setProgress(0.5, animated: true)
            Auth.auth().signIn(withEmail: email.text!, password: pwd.text!, completion: { (authResult, error) -> Void in
                if (error == nil) {
                    self.progress.setProgress(0.75, animated: true)
                    let uid = authResult?.user.uid
                    let ref = Database.database().reference()
                    ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        let status = value?["status"] as? String ?? ""
                        UserDefaults.standard.set(status, forKey: "status")
                        print(status)
                        let tabC = self.storyboard?.instantiateViewController(withIdentifier: "tabCon")
                        self.present(tabC!, animated: true, completion: nil)
                        self.progress.setProgress(1, animated: true)
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }else{
                    let msg = error?.localizedDescription ?? "Unknown Reason"
                    let alert = UIAlertController(title: "Login failed", message: msg, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    alert.view.layoutIfNeeded()
                    self.present(alert, animated: true, completion: nil)
                    self.progress.isHidden = true
                    self.progress.progress = 0
                }
            })
        }else{
            let alert = UIAlertController(title: "Login failed", message: "Username or password is empty", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.view.layoutIfNeeded()
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func register(_ sender: UIButton) {
        let registerVC = storyboard?.instantiateViewController(withIdentifier: "register") as! registerViewController
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
}

