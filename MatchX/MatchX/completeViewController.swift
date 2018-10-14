//
//  completeViewController.swift
//  MatchX
//
//  Created by Luxiao Zheng on 10/13/18.
//  Copyright © 2018 TeamK. All rights reserved.
//

import UIKit

class completeViewController: UIViewController {

    var large: String = "Congratulations!"
    var medium: String = "A request has been sent to this student"
    @IBOutlet weak var largeText: UILabel!
    @IBOutlet weak var mediumText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        largeText.text = large
        mediumText.text = medium
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToAccount(_ sender: UIButton) {
        let tabCon = self.storyboard?.instantiateViewController(withIdentifier: "tabCon") as! UITabBarController
        
        self.present(tabCon, animated: true, completion: nil)
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
