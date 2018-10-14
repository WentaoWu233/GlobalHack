//
//  homeViewController.swift
//  MatchX
//
//  Created by Luxiao Zheng on 10/12/18.
//  Copyright © 2018 TeamK. All rights reserved.
//

import UIKit
import Firebase
class homeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableview: UITableView!
    var names = [String]()
    @IBOutlet weak var searchBar: UISearchBar!
    var cities = [String]()
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var headImages = [UIImage]()
    var headURLs = [String]()
    var languages = [String]()
    var userInfo = [String:String]()
    var userIds = [String]()
    @IBOutlet weak var sorry2: UILabel!
    @IBOutlet weak var sorry1: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableview.dataSource = self
        tableview.delegate = self
        self.activity.startAnimating()
        self.activity.hidesWhenStopped = true
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observe(DataEventType.value, with: { snapshot in

            self.userInfo = snapshot.value as! [String : String]
            self.getRecommend()
            
        })
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let image = headImages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! customTableCell
        cell.cellImageView.layer.cornerRadius = (cell.cellImageView.frame.size.height)/2
        
        cell.cellImageView.clipsToBounds = true;
        cell.title.text = names[indexPath.row]
        cell.subtitle.text = cities[indexPath.row]
        cell.cellImageView.image = image
        cell.language.text = languages[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100.0;//Choose your custom row height
    }
    func getRecommend(){
        names = [String]()
        cities = [String]()
        headImages = [UIImage]()
        //start of code from https://stackoverflow.com/questions/27341888/iterate-over-snapshot-children-in-firebase
        var interest: String = "";
        if self.userInfo["status"] == "student" {
            interest = "immigrant"
        }else{
            interest = "student"
        }
        let ref = Database.database().reference().child("users")
        ref.observe(DataEventType.value, with: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as? NSDictionary
                let status = value!["status"] as! String
                if status == interest {
                    let language = value!["language"] as! String
                    let city = value!["area"] as! String
                    if (language.lowercased().range(of: self.userInfo["language"]!.lowercased()) != nil) {
                        var pos: Int = 0
                        if (city == self.userInfo["area"]) {
                            pos = max(self.names.count-1, 0)
                        }
                        self.userIds.insert(rest.key, at: pos)
                        self.names.insert(value!["displayName"] as! String, at: pos)
                        self.cities.insert(city, at: pos)
                        self.headURLs.insert(value!["headURL"] as! String, at: pos)
                        self.languages.insert(language, at: pos)
                        let imageURL = URL(string: value!["headURL"] as! String)
                        let data = try? Data(contentsOf:imageURL!)
                        let image = UIImage(data: data!)
                        self.headImages.insert(image!, at: pos)
                    }
                }
            }
            self.activity.stopAnimating()
            if (self.names.count > 0) {
                self.tableview.isHidden = false
                self.tableview.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            }else{
                self.sorry1.isHidden = false
                self.sorry2.isHidden = false
            }
            
        })
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uInfoVC = storyboard?.instantiateViewController(withIdentifier: "uInfoVC") as! userInfoViewController
        uInfoVC.userid = userIds[indexPath.row]
        navigationController?.pushViewController(uInfoVC, animated: true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("call")
        if searchBar.text != "" {
            self.activity.startAnimating()
            self.activity.isHidden = false
            self.tableview.isHidden = true
            updateTable(query: searchBar.text!)
        }
    }
    func updateTable(query: String){
        names = [String]()
        cities = [String]()
        headImages = [UIImage]()
        userIds = [String]()
        //start of code from https://stackoverflow.com/questions/27341888/iterate-over-snapshot-children-in-firebase
        var interest: String = "";
        if self.userInfo["status"] == "student" {
            interest = "immigrant"
        }else{
            interest = "student"
        }
        let ref = Database.database().reference().child("users")
        ref.observe(DataEventType.value, with: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let value = rest.value as? NSDictionary
                let status = value!["status"] as! String
                if status == interest {
                    let language = value!["language"] as! String
                    let city = value!["area"] as! String
                    let name = value!["displayName"] as! String
                    if (language.lowercased().range(of: query.lowercased()) != nil) || (city.lowercased().range(of: query.lowercased()) != nil) || (name.lowercased().range(of: query.lowercased()) != nil){
                        var pos: Int = 0
                        if (city == self.userInfo["area"]) {
                            pos = max(self.names.count-1, 0)
                        }
                        self.userIds.insert(rest.key, at: pos)
                        self.names.insert(value!["displayName"] as! String, at: pos)
                        self.cities.insert(city, at: pos)
                        self.headURLs.insert(value!["headURL"] as! String, at: pos)
                        self.languages.insert(language, at: pos)
                        let imageURL = URL(string: value!["headURL"] as! String)
                        let data = try? Data(contentsOf:imageURL!)
                        let image = UIImage(data: data!)
                        self.headImages.insert(image!, at: pos)
                    }
                }
            }
            self.activity.stopAnimating()
            if (self.names.count > 0) {
                self.tableview.isHidden = false
                self.tableview.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            }else{
                self.sorry1.text = "your search"
                self.sorry1.isHidden = false
                self.sorry2.isHidden = false
            }
            
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
