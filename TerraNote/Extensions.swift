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
