//
//  Extensions.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/6/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation

extension CLPlacemark {
    var address: String? {
        var array: [String] = []
        if let thoro = self.thoroughfare { array.append(thoro) }
        if let loc = self.locality { array.append(loc) }
        if let admin = self.administrativeArea { array.append(admin) }
        if let country = self.country { array.append(country) }
        if array.isEmpty { return nil }
        return array.joined(separator: ", ")
    }
}

extension Date {
    static func from(iso8601: String)-> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: iso8601)
    }
    
    func toISO8601()-> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

extension CLLocationCoordinate2D {
    func isNearbyTo(_ coord: CLLocationCoordinate2D)->Bool {
        let latDiff = abs(coord.latitude - self.latitude)
        let longDiff = abs(coord.longitude - self.longitude)
        let distCheck = latDiff < 0.0002 && longDiff < 0.0002
        return distCheck
    }
}
