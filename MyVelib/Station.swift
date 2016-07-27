//
//  Station.swift
//  MyVelib
//
//  Created by etudiant-02 on 15/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import CoreLocation


/*
 
 Retour API
 
 {
 "number": 123,
 "contract_name" : "Paris",
 "name": "nom station",
 "address": "adresse indicative",
 "position": {
 "lat": 48.862993,
 "lng": 2.344294
 },
 "banking": true,
 "bonus": false,
 "status": "OPEN",
 "bike_stands": 20,
 "available_bike_stands": 15,
 "available_bikes": 5,
 "last_update": <timestamp>
 }
 
 
 */

class Station {

    var number : Int
    var name : String
    var address : String
    var position : CLLocation
    var bonus : Bool
    var statusOk : Bool
    var availableBikeStands : Int
    var availableBikes : Int
    var lastUpdate : NSDate
    var distanceStr : String?
    
    
    init( number: Int, name: String, address: String, position: CLLocation, bonus: Bool, statusOk: Bool, availableBikeStands: Int, availableBikes : Int, lastUpdate: NSDate  ) {
        self.number = number
        self.name = name
        self.address = address
        self.position = position
        self.bonus = bonus
        self.statusOk = statusOk
        self.availableBikeStands = availableBikeStands
        self.availableBikes = availableBikes
        self.lastUpdate = lastUpdate
    }

    func toString () -> String {
        return
            "number: \(number) \n"
            + "name: \(name) \n"
            + "address: \(address) \n"
            + "position: \(position) \n"
            + "bonus: \(bonus) \n"
            + "statusOk: \(statusOk) \n"
            + "availableBikeStands: \(availableBikeStands) \n"
            + "availableBikes: \(availableBikes) \n"
            + "lastUpdate: \(lastUpdate) \n"
    }
}




