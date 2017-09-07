//
//  TNAnnotation.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/6/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation

class TNAnnotation: NSObject, MKAnnotation {
    var latitude: Double
    var longitude: Double
    var noteIDs: [String] = []
    var count: Int  { return noteIDs.count }
    var title: String? {
        var noun = "Note"
        if count != 1 { noun += "s" }
        return "\(count) \(noun)"
    }
    
    public var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(coordinate: CLLocationCoordinate2D, noteID: String? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        
        if let id = noteID { noteIDs.append(id) }
    }
    
}
