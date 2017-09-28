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
    
    var values: [String:Any]{
        return [
            Property.email.rawValue : email,
            Property.id.rawValue : id,
            Property.channels.rawValue : channels,
            Property.blocklist.rawValue: blocklist
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
    
    static func makeWith(_ dict: [String: Any])-> TNUser? {
        if let id = dict[Property.id.rawValue] as? String,
            let emailValue = dict[Property.email.rawValue] as? String,
            let email = emailValue.fromFBEmailFormat(){
            var user = TNUser(email: email, id: id, channels: [], blocklist: [])
            if let channelDict = dict[Property.channels.rawValue] as? [String:Any],
                let userDict = dict[Property.blocklist.rawValue] as? [String:Any] {
                channelDict.forEach({id, value in
                    if let name = value as? String{
                        let channel = TNChannel(id: id, name: name, members: [], notes: [])
                        user.channels.append(channel)
                    }
                })
                userDict.forEach({key, value in
                    if let emailRaw = value as? String,
                        let email = emailRaw.fromFBEmailFormat() {
                        let blocked = TNUser(email: email, id: id, channels: [], blocklist: [])
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
    }
}
