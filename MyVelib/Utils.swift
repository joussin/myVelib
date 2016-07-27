//
//  Utils.swift
//  MyVelib
//
//  Created by etudiant-02 on 15/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation

extension CLLocationDistance {
    
    // en min à 4km/h
    var toTime : Double {
        return floor((Double(self)/1000/4)*60)
    }
    
    
}

extension NSDate {
    var absoluteDateToString : String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "UTC")
        return formatter.stringFromDate(self)
    }
    
    var toSimpleDate : String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(self)
    }
}

extension String {
    var toAbsoluteDate : NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "UTC")
        
        if let date = formatter.dateFromString(self) {
            return date
        } else {
            return nil
        }
    }
    
    
    var realName: String {
        if let range: Range<String.Index> = self.rangeOfString("-") {
             return self.substringFromIndex(range.endIndex)
        } else {
            return self
        }
    }
    
    var localize : String {
        return NSLocalizedString(self, comment: "")
    }
    
}

import MapKit

class Utils {
    
    
    //    USER DEFAULT
    
    static func logUserDefaults() {
        print("=================   DEBUT USER DEFAULT =================")
        for (key,value) in NSUserDefaults.standardUserDefaults().dictionaryRepresentation() {
            print( "key : \(key) = value: \(value)" )
        }
        print("=================   FIN USER DEFAULT =================")
    }
    
    
    static func persistChoosenIds (stationsIds: [Int], screenType : ScreenType,contract : String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(stationsIds, forKey: "favStations_\(screenType)_\(contract)"  )
        defaults.synchronize()
    }
    
    static func getChoosenIds (screenType: ScreenType,contract : String) ->[Int]? {
        let defaults = NSUserDefaults.standardUserDefaults()
        if  let returnData = defaults.arrayForKey("favStations_\(screenType)_\(contract)") as? [Int] {
           return returnData
        }else {
            return nil
        }
        
    }
    
    static func persistChoosenContract (contract: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(contract, forKey: "favContract"  )
        defaults.synchronize()
    }
    
    static func getChoosenContract  () -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()

        if  let returnData = defaults.stringForKey("favContract") {
            return returnData
        }else {
            return nil
        }
    }
    
    //  ------------------------------
    
    
    

    
    static func getWalkingDistance(startLocation: CLLocation, endLocation: CLLocation, completion: (distance: CLLocationDistance?, success: Bool)->() ) {
        // requete de chemin
        let request = MKDirectionsRequest()
        
        let destinationCoordinates = endLocation.coordinate
        
        let destination = MKPlacemark(coordinate:
            destinationCoordinates, addressDictionary: nil)
        
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startLocation.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .Walking
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler{
            response, error in
            
            if let myResponse = response  {
                
                if myResponse.routes.count == 1 {
                    let route = myResponse.routes[0]
                    /*
                    for step in route.steps {
                        //print(step.distance)
                    }
                    */
                    //print("the route distance is:\(route.distance)")
                    completion(distance: route.distance, success: true)
                } else {
                    completion(distance: nil, success: false)
                }
            } else {
                //handle the error here
                completion(distance: nil, success: false)
            }
        }
    }
    

    
    
    
}


