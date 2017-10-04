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
    var notes: [TNNote.Short]
    
    var values: [String:Any]{
        var channels: [String:String] = [:]
        var blocklist: [String:String] = [:]
        var notesDict: [String:[String:String]] = [:]
        self.channels.forEach({channels[$0.id] = $0.name})
        self.blocklist.forEach({blocklist[$0.id] = $0.email})
        self.notes.forEach({notesDict.merge($0.values, uniquingKeysWith: {(current, _) in current}) })
        return [
            Property.id.rawValue : self.id,
            Property.email.rawValue : self.email,
            Property.channels.rawValue : channels,
            Property.blocklist.rawValue: blocklist,
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
        let user = TNUser(email: TNUser.currentUserEmail, id: TNUser.currentUserID, channels: [], blocklist: [], notes: [])
        return user
    }
    
    static func makeWith(_ dict: [String: Any])-> TNUser? {
        if let id = dict[Property.id.rawValue] as? String,
            let emailValue = dict[Property.email.rawValue] as? String,
            let email = emailValue.fromFBEmailFormat(){
            var user = TNUser(email: email, id: id, channels: [], blocklist: [], notes:[])
            if let channelDict = dict[Property.channels.rawValue] as? [String:Any],
                let userDict = dict[Property.blocklist.rawValue] as? [String:Any] {
                channelDict.forEach({id, value in
                    if let name = value as? String {
                        let channel = TNChannel(id: id, name: name, members: [], notes: [])
                        user.channels.append(channel)
                    }
                })
                userDict.forEach({key, value in
                    if let emailRaw = value as? String,
                        let email = emailRaw.fromFBEmailFormat() {
                        let blocked = TNUser(email: email, id: id, channels: [], blocklist: [], notes: [])
                        user.blocklist.append(blocked)
                    }
                })
            }
            return user
        }
        return nil
    }
    
    enum Property: String {
        case email = "email"
        case id = "id"
        case channels = "channels"
        case blocklist = "blocklist"
        case notes = "notes"
    }
}
