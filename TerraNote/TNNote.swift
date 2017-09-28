//
//  TNModel.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/5/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation

struct TNNote {
    let id: String
    let creator: String
    var title: String
    var date: String
    var location: String
    var content: String
    var channel: TNChannel?
    
    var values: [String:Any?] {
        return [
            Property.title.rawValue : self.title,
            Property.date.rawValue: self.date,
            Property.location.rawValue: self.location,
            Property.content.rawValue: self.content,
            Property.creator.rawValue: self.creator,
            Property.channel.rawValue: self.channel?.values
        ]
    }
    
    static func makeBatchFrom(dict:[String:Any])->[TNNote]{
        let ids = dict.keys
        var notes: [TNNote] = []
        for id in ids {
            if let data = dict[id] as? [String:Any],
                let myNote = makeWith(id: id, data: data){
                    notes.append(myNote)
            }
        }
        return notes
    }
    
    static func makeWith(id: String, data: [String:Any])->TNNote? {
        
       if let title = data[Property.title.rawValue] as? String,
        let date = data[Property.date.rawValue] as? String,
        let location = data[Property.location.rawValue] as? String,
        let content = data[Property.content.rawValue] as? String,
        let creator = data[Property.creator.rawValue] as? String {
        var channel: TNChannel? = nil
        //if there is data about a channel this is related to, store it in the channel value
        if let channelData = data[Property.channel.rawValue] as? [String : String],
            let channelID = channelData.keys.first,
            let channelName = channelData.values.first{
            channel = TNChannel(id: channelID, name: channelName, members: [], notes: [])
        }
        return TNNote(id: id, creator: creator, title: title, date: date, location: location, content: content, channel: channel)
        }
        return nil
    }
    
    struct Short {
        let id: String
        let title: String
        // used for search results
        var values: [String: String] {
            return [id:title]
        }
    }
    
    enum Property: String {
        case title = "title"
        case date = "date"
        case location = "location"
        case content = "content"
        case id = "id"
        case creator = "creator"
        case channel = "channel"
    }
}


