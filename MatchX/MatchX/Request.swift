//
//  Request.swift
//  WentaoWu-JessicaWu-FinalProject
//
//  Created by labuser on 7/27/18.
//  Copyright © 2018 labuser. All rights reserved.
//

import Foundation
import Firebase
struct Request {
    let requestId: String
    let dateTime: String
    let location: String
    let immigrant: String
    let student: String
    let timeRequested: NSNumber
    let immigrantId: String
    let studentId: String
    let status:String
    init(dateTime: String, location: String, immigrant: String, student: String, timeRequested: NSNumber, immigrantId: String, studentId: String, requestId: String, status:String, rating: NSNumber) {
        self.requestId = requestId
        self.dateTime = dateTime
        self.location = location
        self.immigrant = immigrant
        self.student = student
        self.timeRequested = timeRequested
        self.immigrantId = immigrantId
        self.studentId = studentId
        self.status = status
    }
    init(snapshot: DataSnapshot) {
        self.requestId = snapshot.key
        let value = snapshot.value as! NSDictionary
        self.dateTime = value["dateTime"] as! String
        self.location = value["location"] as! String
        self.student = value["student"] as! String
        self.immigrant = value["immigrant"] as! String
        self.timeRequested = value["timeRequested"] as! NSNumber
        self.studentId = value["studentId"] as! String
        self.immigrantId = value["immigrantId"] as! String
        self.status = value["status"] as! String
    }
}
