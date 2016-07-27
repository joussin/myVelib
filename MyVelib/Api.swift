//
//  Api.swift
//  MyVelib
//
//  Created by etudiant-02 on 14/06/2016.
//  Copyright © 2016 etudiant-02. All rights reserved.
//



/*
 Ressources Stations et Contrats
 
 Stations
 
 Les stations sont représentées de la façon suivante :
 
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
 On peut distinguer 2 parties, les données statiques et les données dynamiques.
 
 Données statiques
 
 number le numéro de la station. Attention, ce n'est pas un id, ce numéro n'est unique qu'au sein d'un contrat
 contract_name le nom du contrat de cette station
 name le nom de la station
 address adresse indicative de la station, les données étant brutes, parfois il s'agit plus d'un commentaire que d'une adresse.
 position les coordonnées au format WGS84
 banking indique la présence d'un terminal de paiement
 bonus indique s'il s'agit d'une station bonus
 Données dynamiques
 
 status indique l'état de la station, peut être CLOSED ou OPEN
 bike_stands le nombre de points d'attache opérationnels
 available_bike_stands le nombre de points d'attache disponibles pour y ranger un vélo
 available_bikes le nombre de vélos disponibles et opérationnels
 last_update timestamp indiquant le moment de la dernière mise à jour en millisecondes depuis Epoch
 Contrats
 
 Pour chaque agglomération cliente de JCDecaux, un contrat est associé.
 
 {
 "name" : "Paris",
 "commercial_name" : "Vélib'",
 "country_code" : "FR",
 "cities" : [
 "Paris",
 "Neuilly",
 ...
 ]
 }
 name le nom du contrat (son identifiant)
 commercial_name le nom commercial donné à ce contrat
 country_code le code (ISO 3166) du pays
 cities la liste des villes associées au contrat
 Description de l'API REST
 
 Chaque réponse de l'API est propre au type de requête et s'efforce de suivre au mieux le pattern REST. Si le serveur rencontre une erreur lors du traitement de votre requête, vous recevrez une réponse du type : HTTP/1.1 500 Internal Server Error.
 
 N'oubliez pas d'ajouter votre clé d'API aux requêtes présentées ci-dessous (voir l'explication).
 */

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation


/*
 api.getContracts { (contracts) in
 print(contracts)
 }
 
 
 api.getStation(31705, contract_name: "Paris") { (station) in
 print(station.name.realName())
 }
 */





class Api {
    
    let apiKey : String = Config.apiKey
    
    
    /**
     Récupérer la liste des stations
     
     Requête :
     
     GET https://api.jcdecaux.com/vls/v1/stations HTTP/1.1
     Accept: application/json
     Réponse :
     
     HTTP/1.1 200 OK
     Content-Type: application/json
     
     [station_json, station_json, ...]
     */
    /**
     Récupérer la liste des stations d'un contrat
     
     Requête :
     
     GET https://api.jcdecaux.com/vls/v1/stations?contract={contract_name} HTTP/1.1
     Accept: application/json
     Réponse lorsque le contrat existe :
     
     HTTP/1.1 200 OK
     Content-Type: application/json
     
     [station_json, station_json, ...]
     Réponse lorsque le contrat n'existe pas :
     
     HTTP/1.1 400 Bad Request
     
     
     */
    func getStations (contract_name : String, completion: (stations: [Station]) -> () , progress: (state: Float) -> () )  {
        
        
        
        let urlString = "https://api.jcdecaux.com/vls/v1/stations"
        
        Alamofire.request(.GET, urlString, parameters: ["contract": contract_name,"apiKey": self.apiKey ])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let Json = response.result.value {
                        
                        let stationsQueue = dispatch_queue_create("StationsQueue", nil)
                        dispatch_async(stationsQueue, {
                            
                            let json = JSON( Json)
                            let max = Float(json.count - 1)
                             var stations = [Station]()
                            
                            for (index,subJson) in json {
                                
                                if  let number = subJson["number"].int,
                                    let name = subJson["name"].string,
                                    let address = subJson["address"].string,
                                    let lat = subJson["position"]["lat"].double,
                                    let lng = subJson["position"]["lng"].double,
                                    let bonus = subJson["bonus"].bool,
                                    let status = subJson["status"].string,
                                    let available_bike_stands = subJson["available_bike_stands"].int,
                                    let available_bikes = subJson["available_bikes"].int,
                                    let last_update = subJson["last_update"].double
                                {
                                    let station = Station(
                                        number: number,
                                        name: name,
                                        address: address,
                                        position: CLLocation(latitude: lat, longitude: lng) ,
                                        bonus: bonus,
                                        statusOk: ( status == "OPEN" ) ? true : false ,
                                        availableBikeStands: available_bike_stands,
                                        availableBikes: available_bikes,
                                        lastUpdate: NSDate(timeIntervalSince1970: NSTimeInterval(last_update) )
                                    )
                                    
                                    stations.append(station)
                                    
                                    let state = Float(Int(index)!)/max
                                    dispatch_async(dispatch_get_main_queue(), {
                                        progress(state: state)
                                    })
                                }
                                
                            }
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                completion(stations: stations)
                            })
                            
                        })
                    }
                case .Failure(let error):
                    print(error)
                }
        }
    }
    /**
     Consulter la liste des contrats
     
     Requête :
     
     GET https://api.jcdecaux.com/vls/v1/contracts HTTP/1.1
     Accept: application/json
     Réponse :
     
     HTTP/1.1 200 OK
     Content-Type: application/json
     
     [contract_json,contract_json,...]
     
     */
    
    func getContracts (completion: (contracts: [String: [String]] ) -> () )  {
        
        let urlString = "https://api.jcdecaux.com/vls/v1/contracts"
        
        Alamofire.request(.GET, urlString, parameters: ["apiKey": self.apiKey ])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let Json = response.result.value {
                        
                        let json = JSON( Json)
                        
                        var contracts = [String: [String]]()
                        
                        for (_,subJson) in json {
                            
                            if  let name = subJson["name"].string,
                                let cities = subJson["cities"].array
                            {
                                var citiesArray = [String]()
                                
                                for city in cities {
                                    if let city_ = city.string {
                                        citiesArray.append(city_)
                                    }
                                }
                                contracts[name] = citiesArray
                            }
                        }
                        completion(contracts: contracts)
                    }
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    /**
     Récupérer les infos d'une station
     
     Requête :
     
     GET https://api.jcdecaux.com/vls/v1/stations/{station_number}?contract={contract_name} HTTP/1.1
     Accept: application/json
     Réponse lorsque la station existe :
     
     HTTP/1.1 200 OK
     Content-Type: application/json
     
     station_json
     Réponse lorsqu'elle n'existe pas :
     
     HTTP/1.1 404 Not Found
     
     */
    
    func getStation (station_number : Int, contract_name : String, completion: (station: Station) -> () ) {
        
        let urlString = "https://api.jcdecaux.com/vls/v1/stations/" + String(station_number)
        
        Alamofire.request(.GET, urlString, parameters: ["contract": contract_name,"apiKey": self.apiKey ])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let Json = response.result.value {
                        let json = JSON( Json)
                        
                        if  let number = json["number"].int,
                            let name = json["name"].string,
                            let address = json["address"].string,
                            let lat = json["position"]["lat"].double,
                            let lng = json["position"]["lng"].double,
                            let bonus = json["bonus"].bool,
                            let status = json["status"].string,
                            let available_bike_stands = json["available_bike_stands"].int,
                            let available_bikes = json["available_bikes"].int,
                            let last_update = json["last_update"].double
                        {
                            let station = Station(
                                number: number,
                                name: name,
                                address: address,
                                position: CLLocation(latitude: lat, longitude: lng) ,
                                bonus: bonus,
                                statusOk: ( status == "OPEN" ) ? true : false ,
                                availableBikeStands: available_bike_stands,
                                availableBikes: available_bikes,
                                lastUpdate: NSDate(timeIntervalSince1970: NSTimeInterval(last_update/1000.0) )
                            )
                            completion(station: station)
                        }
                    }
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    
}

 