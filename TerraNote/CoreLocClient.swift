//
//  CoreLocClient.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/6/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation

final class CoreLocClient{
    private static let client = CoreLocClient()
    
    private var manager: CLLocationManager
    private var authStatus: CLAuthorizationStatus
    private var enabled: Bool
    weak var delegate: CLLocationManagerDelegate?
    
    var authorized: Bool {
        let always = authStatus == .authorizedAlways
        let whenInUse = authStatus == .authorizedWhenInUse
        return always || whenInUse
    }
    
    
    private init (){
        self.manager = CLLocationManager()
        self.authStatus = CLLocationManager.authorizationStatus()
        self.enabled = CLLocationManager.locationServicesEnabled()
        manager.startUpdatingLocation()
    }
    
    class func authCheckRequest() {
        if client.authorized && client.enabled {return}
        self.client.manager.requestWhenInUseAuthorization()
    }
    
    class func forwardGeocode(address: String, completion: @escaping (CLPlacemark?)->()) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemark, error in
            completion(placemark?.first)
        }
    }
    
    class func forwardGeocodeAutoCompletions(text: String, completion: @escaping ([String])->()) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(text, completionHandler: { placemarks, error in
            var completions: [String] = []
            if  let placemarks = placemarks {
                print (placemarks.count)
                placemarks.forEach({
                    if let dict = $0.addressDictionary,
                        let street = dict ["Street"] as? String,
                        let city = dict ["City"] as? String,
                        let zip = dict ["ZIP"] as? String{
                        completions.append("\(street), \(city), \(zip)")
                    }
                })
            }
            DispatchQueue.main.async {completion(completions)}
        })
    }
    
    class func reverseGeocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?)->()) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location, completionHandler: { placemark, error in
            completion(placemark?.first)
        })
        
    }
    
    class func geocodeMyLocation(completion: @escaping (CLPlacemark?)->()){
        let geocoder = CLGeocoder()
        if let location = client.manager.location {
            geocoder.reverseGeocodeLocation(location){ placemarks, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let placemarks = placemarks{
                    completion(placemarks.first)
                }
                else { completion (nil) }
            }
        }
    }
}
