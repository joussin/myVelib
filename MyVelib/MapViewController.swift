//
//  MapViewController.swift
//  MyVelib
//
//  Created by etudiant-02 on 17/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Flurry_iOS_SDK

class MapViewController: UIViewController {
    
    var nbType = 0
    var stations =  [Station]()
    var selectedStation : Station?
    var selectedStations = [Station]()
    var favStations = [Int]()
    var screenType : ScreenType = ScreenType.Home
    let regionRadius: CLLocationDistance = 450
    
    @IBOutlet weak var segmentedElement: UISegmentedControl!
    @IBOutlet var showUserLocationButton : UIButton!
    @IBOutlet var backButton : UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func showUserLocationButtonPressed () {
        let location  = mapView.userLocation
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func segmentedElementChanged (sender : UISegmentedControl){
        nbType = sender.selectedSegmentIndex
        addPins()
    }
    
    @IBAction func backButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addPins(){
        
        let mapCenterPosition = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        mapView.removeAnnotations(mapView.annotations)
        
        if screenType != .Geo {
            for station in stations {
                let d = mapCenterPosition.distanceFromLocation( station.position  )
                if d < 1000 {
                    var annotation: Pin
                    
                    if favStations.contains(station.number) {
                        annotation = Pin(title: station.name.realName , pinType: .Home , image: UIImage(named: "station_orange"), station: station, checked: true)
                    } else {
                        annotation = Pin(title: station.name.realName , pinType: .Home , image: UIImage(named: "station_grise"), station: station,checked: false)
                    }
                    mapView.addAnnotation(annotation)
                }
            }
        }
        
        if screenType == .Geo {
            for nearStation in selectedStations {
                var annotation: Pin
                annotation = Pin(title: nearStation.name.realName , pinType: .Home , image: UIImage(named: "station_orange"), station: nearStation, checked: true)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedElement.setTitle("map.segment.0".localize, forSegmentAtIndex: 0)
        segmentedElement.setTitle("map.segment.1".localize, forSegmentAtIndex: 1)
        backButton.setTitle("\u{f0d9} " + "map.backBtn".localize, forState: .Normal)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        mapView.showsUserLocation = true
        
        if selectedStation != nil {
            centerMapOnLocation(selectedStation!.position)
        } else {
            if screenType == .Geo {
                _ = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self,
                                                           selector: #selector(self.showUserLocationButtonPressed),
                                                           userInfo: nil,
                                                           repeats: false)
            }
            else {
                centerMapOnLocation(stations[0].position)
            }
        }
        
        //paris
        // Latitude : 48.8934844
        // Longitude : 2.3505236
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension MapViewController: CLLocationManagerDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: -20)//position du popup par rapport à l'image
                
                //pour bien placer le pin
                view.centerOffset = CGPoint(x: 0, y: -22)
                view.image = annotation.image
                view.frame.size = CGSize(width: 36, height: 40)
                
                //label pour le nb velo
                let nb = UILabel()
                nb.frame = CGRect(x: -7,y: -10,width: 50,height: 50)
                nb.textColor = UIColor.whiteColor()
                nb.textAlignment = .Center
                nb.font = UIFont(name: "Arial", size: 12)
                nb.text =  ( nbType == 0 ) ? String(annotation.station.availableBikes) : String(annotation.station.availableBikeStands)
                
                view.addSubview(nb)
                
                // btn star
                let rightButton = UIButton()
                rightButton.frame = CGRectMake(0, 0, 30, 30)
                rightButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
                rightButton.setTitleColor( UIColor.orangeColor(), forState: .Normal)
                
                // DANS LES FAVS ?
                annotation.checked ? rightButton.setTitle("\u{f005}", forState: .Normal) :  rightButton.setTitle("\u{f006}", forState: .Normal)
                
                if screenType != .Geo  {
                    rightButton.hidden = false
                } else{
                    rightButton.hidden = true
                }
                view.rightCalloutAccessoryView = rightButton
            }
            return view
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,calloutAccessoryControlTapped control: UIControl) {
        let myStationPin = view.annotation as! Pin
        let rightButton = view.rightCalloutAccessoryView as! UIButton
        
        // DANS LES FAVS ?
        
        if !myStationPin.checked {
            rightButton.setTitle("\u{f005}", forState: .Normal)
            view.image = UIImage(named: "station_orange")
            myStationPin.checked = true
            
            favStations.append(myStationPin.station.number)
            Utils.persistChoosenIds(favStations,screenType: screenType,contract: Config.contract!)
            
            let flurryParams = ["name": myStationPin.station.name + " à " +  Config.contract! ]
            Flurry.logEvent("station_fav_add", withParameters: flurryParams)
            
            
        } else{
            rightButton.setTitle("\u{f006}", forState: .Normal)
            view.image = UIImage(named: "station_grise")
            myStationPin.checked = false
            
            favStations.removeAtIndex(favStations.indexOf(myStationPin.station.number)!)
            Utils.persistChoosenIds(favStations,screenType: screenType,contract: Config.contract!)
        }
        
        view.frame.size = CGSize(width: 36, height: 40)
        view.centerOffset = CGPoint(x: 0, y: -22)
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        addPins()
    }
    
    
}






