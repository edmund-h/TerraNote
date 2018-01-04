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
    
    private class func geoReference(channelID: String? = nil)->GeoFire {
        // the id is a channel ID. the user's locations are basically their own "channel" consisting of the notes they have created so if no ID is given the note is placed in the user database
        /// DO NOT CALL THIS FUNCTION WITH A USER ID
        let user = TNUser.currentUserID
        let locationPath = "locations"
        let userRef = Database.database().reference().child("users")
        let channelRef = Database.database().reference().child("channels")
        if let id = channelID {
            return GeoFire(firebaseRef: userRef.child(id).child(locationPath))
        } else {
            return GeoFire(firebaseRef: channelRef.child(user).child(locationPath))
        }
    }
    
    // the weird collection of punctuation in the following function call is an optional closure with no parameters or outputs
    class func addLocation(note: TNNote, coordinate: CLLocationCoordinate2D, completion:(()->())? = nil){
        var geo = geoReference()
        let loc  = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geo.setLocation(loc, forKey: note.id)
        //if note is in a channel, place a reference there as well so that other people in the channel can see the note
        if let channelID = note.channel?.id {
            geo = geoReference(channelID: channelID)
            geo.setLocation(loc, forKey: note.id)
        }
    }
    
    class func queryLocations(within region: MKCoordinateRegion, channel: String? = nil, response: @escaping (String, CLLocation)->()){
        //remove locations from map first!
        let geo = geoReference(channelID: channel)
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
