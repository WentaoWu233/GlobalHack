//
//  accountViewController.swift
//  MatchX
//
//  Created by Luxiao Zheng on 10/12/18.
//  Copyright © 2018 TeamK. All rights reserved.
//

import UIKit
import Firebase
class accountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var fromto = "From"
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var headShot: UIImageView!
    @IBOutlet weak var headView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var Pending = [Request]()
    var Completed = [Request]()
    var userInfo = [String:String]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Pending.count
        default:
            return Completed.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        switch indexPath.section {
        case 0:
            let curStatus = userInfo["status"] ?? ""
            if (curStatus == "student") {
                cell.textLabel?.text = fromto + " "+Pending[indexPath.row].immigrant
                cell.detailTextLabel?.text = Pending[indexPath.row].dateTime + " At: " + Pending[indexPath.row].location
            }else{
                
                cell.textLabel?.text = fromto + " "+Pending[indexPath.row].student
                cell.detailTextLabel?.text = Pending[indexPath.row].dateTime + " At: " + Pending[indexPath.row].location
            }

        default:
            let curStatus = userInfo["status"] ?? ""

            if (curStatus == "student") {
                cell.textLabel?.text = "With: " + Completed[indexPath.row].immigrant
                cell.detailTextLabel?.text = Completed[indexPath.row].dateTime + " At: " + Completed[indexPath.row].location
            }else{
                cell.textLabel?.text = "With: " + Completed[indexPath.row].student
                cell.detailTextLabel?.text = Completed[indexPath.row].dateTime + " At: " + Completed[indexPath.row].location
            }
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Pending Request"
        default:
            return "Accepted Request"
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return indexPath.section == 0
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var curStatus = userInfo["status"] ?? ""
        if curStatus == "student" {
            let Accept = UITableViewRowAction(style: .normal, title: "Accept") { action, index in
                Database.database().reference().child("Requests").child(self.Pending[indexPath.row].requestId).child("status").setValue("Accepted")
            }
            Accept.backgroundColor = UIColor.blue
            
            let Reject = UITableViewRowAction(style: .normal, title: "Decline") { action, index in
                Database.database().reference().child("Requests").child(self.Pending[indexPath.row].requestId).setValue(nil)
            }
            Reject.backgroundColor = UIColor.red
            
            
            return [Reject, Accept]
        }else{
            let Cancel = UITableViewRowAction(style: .normal, title: "Cancel") { action, index in
                Database.database().reference().child("Requests").child(self.Pending[indexPath.row].requestId).setValue(nil)
            }
            Cancel.backgroundColor = UIColor.red
            
            
            return [Cancel]
        }


    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        self.activity.startAnimating()
        self.activity.hidesWhenStopped = true
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observe(DataEventType.value, with: { snapshot in
            self.userInfo = snapshot.value as! [String : String]
            let imageURL = URL(string: self.userInfo["headURL"] as! String)
            let data = try? Data(contentsOf:imageURL!)
            let image = UIImage(data: data!)
            self.headView.image = image!
            self.headView.addBlurEffect()
            self.headShot.image = image
            self.headShot.layer.cornerRadius = (self.headShot.frame.size.height)/2
            
            self.headShot.clipsToBounds = true;
            
            self.nameLabel.text = self.userInfo["displayName"]

            self.nameLabel.isHidden = false
            self.headShot.isHidden = false
            self.headView.isHidden = false
            if self.userInfo["status"] == "student" {
                self.fromto = "From:"
            }else{
                self.fromto = "To:"
            }
            self.grabRequestData()
            
            
        })
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logout(_ sender: UIButton) {
        try! Auth.auth().signOut()
        let loginNav = self.storyboard?.instantiateViewController(withIdentifier: "loginNav")
        self.present(loginNav!, animated: true, completion: nil)
    }
    func grabRequestData() {
        let ref = Database.database().reference().child("Requests")
        var lookat = "";
        if (userInfo["status"] == "student") {
            lookat = "studentId"
            
        }else{
            lookat = "immigrantId"
        }
        ref.queryOrdered(byChild: lookat).queryEqual(toValue: (Auth.auth().currentUser?.uid)!).observe(DataEventType.value, with: { (eventSnapshot) in
            print(eventSnapshot)
            self.Completed.removeAll()
            self.Pending.removeAll()
            let enumerator = eventSnapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as! NSDictionary
                if (value["status"] as! String) == "Pending" {
                    self.Pending.append(Request(snapshot: rest))
                }else{
                    self.Completed.append(Request(snapshot: rest))
                }
            }
            self.Pending = self.Pending.sorted(by: {$0.dateTime > $1.dateTime})
            self.Completed = self.Completed.sorted(by: {$0.dateTime > $1.dateTime})
            //self.tableview.reloadData()
            let range = NSMakeRange(0, self.tableview.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.tableview.reloadSections(sections as IndexSet, with: .automatic)
            self.activity.stopAnimating()
            self.tableview.isHidden = false
            self.logoutButton.isHidden = false
            
        })
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
