//
//  FirebaseClient.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/5/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation
import Firebase

class FirebaseClient {
    
    fileprivate static let firebase = Database.database().reference().child("notes")
    typealias JSON = [String:Any]
    
    static func query (by property: TNProperty, with search: String, completion: ([TNNote])->()) {
        firebase.observeSingleEvent(of: .value, with: { snapshot in
            if let data = snapshot.value as? JSON {
                let ids = data.keys 
            }
        })
    }
}
