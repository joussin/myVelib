//
//  ViewController.swift
//  MyVelib
//
//  Created by etudiant-02 on 14/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController,CLLocationManagerDelegate {
    
    var refreshControl: UIRefreshControl!
    var favStations : [Int] = []
    var selectedStations = [Station]()
    var stations = [Station]()
    var screenType : ScreenType?
    var locationManager : CLLocationManager = CLLocationManager()
    var locationUser : CLLocation!
    var distanceGeoLoc: CLLocationDistance = 750

    
    
    @IBOutlet var myTableView : UITableView!
    @IBOutlet var screenTypeButton : UIButton!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet var infoLabel : UILabel!
    @IBOutlet var progressBar : UIProgressView!
    
    
    @IBAction func screenTypeButtonPressed() {
        performSegueWithIdentifier("toMap", sender: self)
    }
    
    // Location Manager helper stuff
    func initLocationManager () {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        print("initLocationManager")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        if manager.location != nil {
            
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            locationUser = locationObj
            initTableViewGeo ()
            
            print("locationManager")
        }
    }
    
    func calculColorBack () {
        
        var availableBikes = 0
        for station in self.selectedStations {
            if station.availableBikes > availableBikes {
                availableBikes = station.availableBikes
            }
        }
        
        if availableBikes >= 2 {
            self.view.backgroundColor = UIColor.greenColor()
        } else if availableBikes == 1 {
            self.view.backgroundColor = UIColor.orangeColor()
        }else {
            self.view.backgroundColor = UIColor.redColor()
        }
    }
    
    func initTableView (){
        self.infoLabel.hidden = true
        self.activityIndicator.hidden = false
        self.myTableView.hidden = false
        
        activityIndicator.startAnimating()
        
        if  let favStations_ =  Utils.getChoosenIds(screenType!,contract: Config.contract!) {
            favStations = favStations_
        }
        else {
            Utils.persistChoosenIds(favStations,screenType: screenType!,contract: Config.contract!)
        }
        
        self.selectedStations = [Station]()
        
        let api = Api()
        api.getStations(Config.contract!, completion: { stations in
            
            self.stations = stations
            
            for station in self.stations {
                if self.favStations.contains(station.number) {
                    self.selectedStations.append(station)
                }
            }
            self.myTableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            
            if self.selectedStations.count == 0 {
                self.infoLabel.hidden = false
                self.myTableView.hidden = true
            }
            self.calculColorBack ()
            
            
            },progress : { progress in
                if progress < 1 {
                    self.progressBar.hidden = false
                } else {
                    self.progressBar.hidden = true
                }
                self.progressBar.progress = progress
        })        
    }
    
    func initTableViewGeo () {
        
        self.infoLabel.hidden = true
        self.activityIndicator.hidden = false
        self.myTableView.hidden = false
        
        activityIndicator.startAnimating()
        
        self.selectedStations = [Station]()
        
        let api = Api()
        api.getStations(Config.contract!, completion: { stations in
            self.stations = stations
            print("initTableViewGeo")
            
            for station in self.stations {
                self.selectedStations.append(station)
            }
            
            self.selectedStations = self.selectedStations.sort{ $0.position.distanceFromLocation(self.locationUser) < $1.position.distanceFromLocation(self.locationUser) }
            self.selectedStations = self.selectedStations.filter{ $0.position.distanceFromLocation(self.locationUser) < self.distanceGeoLoc }
            
            for selectStation in self.selectedStations {
                Utils.getWalkingDistance(self.locationUser, endLocation: selectStation.position, completion: { (distance, success) in
                    
                    if success && distance != nil {
                        let distanceStr  = String( Int(distance!.toTime) ) + " min. \u{f177} \u{f29d} \u{f178} " + String( Int(distance!) ) + " mètres"
                        selectStation.distanceStr = distanceStr
                        
                        if let lastElement = self.selectedStations.last {
                            if selectStation.number == lastElement.number {
                                self.myTableView.reloadData()
                            }
                        }
                    }
                    else {
                        /* print("-------")
                         print ("error lors du calcul de la distance à pied")
                         print(self.locationUser)
                         print(selectStation.position)
                         print(   selectStation.position.distanceFromLocation(self.locationUser))
                         print(distance)
                         print("-------")*/
                    }
                })
            }
            self.myTableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            self.calculColorBack ()
            },progress : { progress in
                if progress < 1 {
                   self.progressBar.hidden = false
                } else {
                    self.progressBar.hidden = true
                }
                self.progressBar.progress = progress
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(MainViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        myTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        switch screenType! {
        case .Home:
            screenTypeButton.setTitle("\u{f015}", forState: .Normal)
        case .Work:
            screenTypeButton.setTitle("\u{f1ad}", forState: .Normal)
        case .Geo:
            screenTypeButton.setTitle("\u{f14e}", forState: .Normal)
        }
        infoLabel.text = "main.infoLabel".localize
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        progressBar.hidden = true
        
        if screenType == .Geo {
            initLocationManager()
        }
        else {
            initTableView()
        }
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        refreshControl.endRefreshing()
        if screenType == .Geo {
            initLocationManager()
        }
        else {
            initTableView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toMap") {
            if let detailVC  = segue.destinationViewController as? MapViewController {
                detailVC.stations = stations
                
                if myTableView.indexPathForSelectedRow == nil {
                    detailVC.selectedStation = nil
                }
                else {
                    detailVC.selectedStation = selectedStations[myTableView.indexPathForSelectedRow!.row]
                }
                
                detailVC.selectedStations = selectedStations
                detailVC.favStations = favStations
                detailVC.screenType = screenType!
            }
        }
    }
}



extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // A modifier, retourner le nombre de ligne dans la section
        return self.selectedStations.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StationCell", forIndexPath: indexPath) as! StationCell
        // Ajouter la logique d'affichage du texte dans la cellule de la TableView
        // la variable indexpath.row indique la ligne selectionnée
        // on accède aux IBOutlet de la cellule avec par exemple : cell.name =
        
        if self.selectedStations.count >= ( indexPath.row + 1 ) {
            
            cell.availableBike.text = String(self.selectedStations[indexPath.row].availableBikes)
            cell.availableBikeStands.text = String(self.selectedStations[indexPath.row].availableBikeStands)
            cell.name.text = self.selectedStations[indexPath.row].name.realName
            if screenType == .Geo  {
                //cell.distance.text  = "Distance: " + String( floor(self.locationUser.distanceFromLocation(self.selectedStations[indexPath.row].position)) ) + " m"
                if let d =  self.selectedStations[indexPath.row].distanceStr {
                    cell.distance.text = d
                }
            } else {
                cell.distance.hidden = true
            }
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let selectedRow = indexPath.row
        //faire quelque chose avec selectedRow
        performSegueWithIdentifier("toMap", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}



