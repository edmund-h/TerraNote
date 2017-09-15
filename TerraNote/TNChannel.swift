//
//  TNChannel.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/15/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation

struct TNChannel {
    var id: String
    var name: String
    var members: [TNUser]
    var notes: [TNNote.Short]
    
    var values: [String:Any] {
        var members: [String:String] = [:]
        var notes: [String: String] = [:]
        self.members.forEach({members[$0.id] = $0.email})
        self.notes.forEach({notes[$0.id] = $0.title})
        return [
            Property.id.rawValue : id,
            Property.name.rawValue : name,
            Property.members.rawValue : members,
            Property.notes.rawValue : notes
        ]
    }
    
    static func makeWith (dict: [String:Any])-> TNChannel? {
        if let values = dict[Property.id.rawValue] as? [String:Any],
            let id = dict.keys.first,
            let name = values[Property.name.rawValue] as? String,
            let memberDict = values[Property.members.rawValue] as? [String:Any],
            let noteDict = values[Property.notes.rawValue] as? [String:Any]{
            var channel = TNChannel(id: id, name: name, members: [], notes: [])
            memberDict.forEach({key, value in
                if let value = value as? String,
                    let email = value.fromFBEmailFormat() {
                    let user = TNUser(email: email, id: id, channels: [], blocklist: [] )
                    channel.members.append(user)
                }
            })
            noteDict.forEach({ key, value in
                if let value = value as? String {
                    let note = TNNote.Short(id: key, title: value )
                    channel.notes.append(note)
                }
            })
            return channel
        }
        
        return nil
    }
    
    enum Property: String {
        case id = "id"
        case name = "name"
        case members = "members"
        case notes = "notes"
    }
    
}
