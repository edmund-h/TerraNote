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
    
    private class func geoReference(uid: String? = nil)->GeoFire {
        let user = TNUser.currentUserID
        let locationPath = "locations"
        let ref = Database.database().reference().child("users")
        if let uid = uid {
            return GeoFire(firebaseRef: ref.child(uid).child(locationPath))
        } else {
            return GeoFire(firebaseRef: ref.child(user).child(locationPath))
        }
    }
    
    class func addLocation(noteID id: String, coordinate: CLLocationCoordinate2D, completion:(()->())? = nil){
        let geo = geoReference()
        let loc  = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geo.setLocation(loc, forKey: id, withCompletionBlock:{ error in
            NSLog("%@", "added location at (\(coordinate.latitude), \(coordinate.longitude) ")
            if let error = error{ print (error.localizedDescription) }
            if let completion = completion {completion()}
        })
        
    }
    
    class func queryLocations(within region: MKCoordinateRegion, user: String? = nil, response: @escaping (String, CLLocation)->()){
        //remove locations from map first!
        let geo = geoReference(uid: user)
        GeoFireClient.query = geo.query(with: region)
        guard let query = GeoFireClient.query else {return}
        query.observe(.keyEntered, with: { key, location in
            //key is game id
            //location is CLLocation
            guard let location = location
                , let key = key else { return }
            response(key, location)
        })
    }
    
    class func removeFromLocationId(noteID id: String, completion: @escaping (Bool)->()){
        let geo = geoReference()
        geo.removeKey(id, withCompletionBlock: { error in
            completion(error == nil)
        })
    }
    
    class func stopObservingOldQueries(){
        GeoFireClient.query?.removeAllObservers()
    }
}
