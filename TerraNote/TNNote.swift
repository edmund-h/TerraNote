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
    var title: String
    var date: String
    var location: String
    var content: String
    
    var values: [String:String] {
        return [
            TNNote.meta.title : self.title,
            TNNote.meta.date : self.date,
            TNNote.meta.location: self.location,
            TNNote.meta.content: self.content
        ]
    }
    
    static let meta =
        TNNote(id: TNProperty.id.rawValue,
               title: TNProperty.title.rawValue,
               date: TNProperty.date.rawValue,
               location: TNProperty.location.rawValue,
               content: TNProperty.content.rawValue)
    
    static func makeFrom(dict:[String:Any])->[TNNote]{
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
        
       if let title = data[meta.title] as? String,
        let date = data[meta.date] as? String,
        let location = data[meta.location] as? String,
        let content = data[meta.content] as? String{
            return TNNote(id: id, title: title, date: date, location: location, content: content)
        }
        return nil
    }
}

enum TNProperty: String {
    case id = "id"
    case title = "title"
    case date = "date"
    case location = "location"
    case content = "content"
}
