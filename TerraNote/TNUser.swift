//
//  TNUser.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/14/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation

struct TNUser {
    var email: String
    let id: String
    var channels: [TNChannel]
    var blocklist: [TNUser]
    var blockedBy: [TNUser]
    var notes: [TNNote.Short]
    
    var values: [String:Any]{
        var channels: [String:String] = [:]
        var blocklist: [String:String] = [:]
        var blockedBy: [String:String] = [:]
        var notesDict: [String:[String:String]] = [:]
        self.channels.forEach({channels[$0.id] = $0.name})
        self.blocklist.forEach({blocklist[$0.id] = $0.email})
        self.blockedBy.forEach({blockedBy[$0.id] = $0.email})
        self.notes.forEach({notesDict.merge($0.values, uniquingKeysWith: {(current, _) in current}) })
        return [
            Property.id.rawValue : self.id,
            Property.email.rawValue : self.email,
            Property.channels.rawValue : channels,
            Property.blocklist.rawValue: blocklist,
            Property.blockedBy.rawValue: blockedBy,
            Property.notes.rawValue: notesDict
        ]
    }
    
    static var currentUserID: String {
        if let uid = UserDefaults.standard.string(forKey: "uid"){
            return uid
        }
        return "unloggedInUser"
    }
    static var currentUserEmail:String {
        if let email = UserDefaults.standard.string(forKey: "email") {
            return email
        }
        return "unloggedInUser"
    }
    
    static var currentUserFull: TNUser {
        let user = TNUser(email: TNUser.currentUserEmail, id: TNUser.currentUserID, channels: [], blocklist: [], blockedBy: [], notes: [])
        return user
    }
    
    static func makeWith(_ dict: [String: Any], id: String)-> TNUser? {
        if let id = dict[Property.id.rawValue] as? String,
            let email = dict[Property.email.rawValue] as? String{
            var user = TNUser(email: email, id: id, channels: [], blocklist: [], blockedBy: [], notes: [])
            if let channelDict = dict[Property.channels.rawValue] as? [String:Any],
                let blockedDict = dict[Property.blocklist.rawValue] as? [String:Any],
            let blockedByDict = dict[Property.blockedBy.rawValue] as? [String:Any]{
                channelDict.forEach({key, value in
                    if let name = value as? String {
                        let channel = TNChannel(id: key, name: name, members: [], notes: [])
                        user.channels.append(channel)
                    }
                })
                blockedDict.forEach({key, value in
                    if let blockedUser = keyValueMake(key: key, value: value) {
                        user.blocklist.append(blockedUser)
                    }
                })
                blockedByDict.forEach({key, value in
                    if let blockingUser = keyValueMake(key: key, value: value) {
                        user.blocklist.append(blockingUser)
                    }
                })
            }
            return user
        }
        return nil
    }
    
    private static func keyValueMake(key: String, value: Any)-> TNUser? {
        if let email = value as? String{
            let user = TNUser(email: email, id: key, channels: [], blocklist: [], blockedBy: [], notes: [])
            return user
        }
        return nil
    }
    
    enum Property: String {
        case email = "email"
        case id = "id"
        case channels = "channels"
        case blocklist = "blocklist"
        case blockedBy = "blockedBy"
        case notes = "notes"
    }
}
