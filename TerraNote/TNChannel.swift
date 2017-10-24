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
            Property.name.rawValue : name,
            Property.members.rawValue : members,
            Property.notes.rawValue : notes
        ]
    }
    
    static func makeWith (id: String, dict: [String:Any])-> TNChannel? {
        if let name = dict[Property.name.rawValue] as? String,
            let memberDict = dict[Property.members.rawValue] as? [String:Any]{
            var channel = TNChannel(id: id, name: name,  members: [], notes: [])
            memberDict.forEach({key, value in
                if let email = value as? String{
                    let user = TNUser(email: email, id: key, channels: [], blocklist: [], notes: [] )
                    channel.members.append(user)
                }
            })
            if let noteDict = dict[Property.notes.rawValue] as? [String:Any]{
                noteDict.forEach({ key, value in
                    if let value = value as? [String:String],
                        let title = value.keys.first,
                        let date = value.values.first {
                        let note = TNNote.Short(id: key, title: title, date: date)
                        channel.notes.append(note)
                    }
                })
            }
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
