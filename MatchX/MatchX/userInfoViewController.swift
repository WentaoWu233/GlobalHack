//
//  userInfoViewController.swift
//  MatchX
//
//  Created by Luxiao Zheng on 10/13/18.
//  Copyright © 2018 TeamK. All rights reserved.
//

import UIKit
import Firebase
class userInfoViewController: UIViewController {
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var lanLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var headShot: UIImageView!
    @IBOutlet weak var headView: UIImageView!
    var userid: String?
    var userInfo = [String:String]()
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.view.backgroundColor = .clear
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.barTintColor = UIColor.white
        navigationBar?.tintColor = UIColor.white

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.startAnimating()
        self.activity.hidesWhenStopped = true
        Database.database().reference().child("users").child(userid!).observe(DataEventType.value, with: { snapshot in
            self.userInfo = snapshot.value as! [String : String]
            let imageURL = URL(string: self.userInfo["headURL"] as! String)
            let data = try? Data(contentsOf:imageURL!)
            let image = UIImage(data: data!)
            self.headView.image = image!
            self.headView.addBlurEffect()
            self.headShot.image = image
            self.headShot.layer.cornerRadius = (self.headShot.frame.size.height)/2
            
            self.headShot.clipsToBounds = true;
            self.activity.stopAnimating()
            self.nameLabel.text = self.userInfo["displayName"]
            self.emailLabel.text = self.userInfo["email"]
            self.lanLabel.text = self.userInfo["language"]
            self.areaLabel.text = self.userInfo["area"]
            self.areaLabel.isHidden = false
            self.emailLabel.isHidden = false
            self.nameLabel.isHidden = false
            self.lanLabel.isHidden = false
            self.headShot.isHidden = false
            self.headView.isHidden = false
            self.name.isHidden = false
            self.email.isHidden = false
            self.area.isHidden = false
            self.language.isHidden = false
            if self.userInfo["status"] == "student"{
                self.requestButton.isHidden = false
            }
            
        })
        
        // Do any additional setup after loading the view.
    }
    @IBAction func request(_ sender: Any) {
        let confirmVC = storyboard?.instantiateViewController(withIdentifier: "confirmVC") as! confirmRequestViewController
        confirmVC.studentId = userid!
        confirmVC.studentName = userInfo["email"]!
        navigationController?.pushViewController(confirmVC, animated: true)
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
extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}
