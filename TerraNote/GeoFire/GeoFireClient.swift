//
//  GeoFireClient.swift
//  TeamOrange
//
//  Created by Edmund Holderbaum on 4/11/17.
//  Copyright © 2017 William Brancato. All rights reserved.
//

import FirebaseDatabase
import MapKit

final class GeoFireClient {
    
    private static var query: GFRegionQuery?
    
    static let geo = GeoFire(firebaseRef: Database.database().reference().child("locations"))
    
    class func addLocation(note id: String, coordinate: CLLocationCoordinate2D, completion:(()->())? = nil){
        let loc  = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geo?.setLocation(loc, forKey: id, withCompletionBlock:{ error in
            NSLog("%@", "added location at (\(coordinate.latitude), \(coordinate.longitude) ")
            if let error = error{ print (error.localizedDescription) }
            if let completion = completion {completion()}
        })
        
    }
    
    class func queryLocations(within region: MKCoordinateRegion, response: @escaping (String, CLLocation)->()){
        //remove locations from map first!
        GeoFireClient.query = geo?.query(with: region)
        guard let query = GeoFireClient.query else {return}
        query.observe(.keyEntered, with: { key, location in
            //key is note id
            //location is CLLocation
            guard let location = location
                , let key = key else { return }
            response(key, location)
        })
    }
    
    class func removeFromLocationId(note id: String, completion: @escaping (Bool)->()){
        geo?.removeKey(id, withCompletionBlock: { error in
            completion(error == nil)
        })
    }
    
    class func stopObservingOldQueries(){
        GeoFireClient.query?.removeAllObservers()
    }
}
