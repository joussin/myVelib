//
//  Pin.swift
//  MyVelib
//
//  Created by etudiant-02 on 17/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import Foundation
import MapKit

//   où myPin est de type Pin que l'on va créer
enum PinType {
    case FavoriteStation
    case StandardStation
    case Home
    case Work
    case Troiswa
}


class Pin: NSObject, MKAnnotation {
    var title: String?
    var pinType: PinType
    var station : Station
    var image : UIImage?
    var checked : Bool
    
    init(title: String, pinType: PinType, image: UIImage?,station: Station, checked: Bool ){
        self.title = title
        self.pinType = pinType
        self.image = image
        self.station = station
        self.checked = checked
        super.init()
    }
    
    var coordinate : CLLocationCoordinate2D {
        return self.station.position.coordinate
    }
    
    //nécessaire si on ne veut pas de subtitle
    var subtitle: String? {
        return ""
    }
}
