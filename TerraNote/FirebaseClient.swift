//
//  CoreLocClient.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/6/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import Foundation
import Firebase

class FirebaseClient {
    
    fileprivate static let ref = Database.database().reference()
    fileprivate static let users = ref.child("users")
    fileprivate static let channels = ref.child("channels")
    fileprivate static let currentUser = users.child(TNUser.currentUserID)
    
    typealias JSON = [String:Any]
    
    // MARK: Note Query Functions
    
    static func queryNotes (by property: TNNote.Property, with search: String, completion: @escaping ([TNNote])->()) {
        currentUser.observeSingleEvent(of: .value, with: { snapshot in
            if let data = snapshot.value as? JSON {
                let ids = data.keys
                var output: [TNNote] = []
                for id in ids {
                    guard var noteData = data[id] as? JSON else {continue}
                    var filterFn: (JSON,String,String)->TNNote?
                    switch property{
                    case .id:
                        filterFn = filterByID(data:id:target:)
                    case .date:
                        filterFn = filterByDate(data:id:target:)
                    default:
                        noteData["property"] = property.rawValue
                        filterFn = filterbyRelevance(data:id:target:)
                    }
                    if let note = filterFn(noteData, id, search){
                        output.append(note)
                        if property == .id { break }
                    }
                }
                completion(output)
            }
        })
    }
    
    static func query(user uid: String, forNote noteID: String, completion: @escaping (TNNote?)->()){
        users.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let data = snapshot.value as? JSON{
                let ids = data.keys
                for id in ids {
                    guard let noteData = data[id] as? JSON else {continue}
                    if let note = filterByID(data: noteData, id: id, target: noteID){
                        completion(note)
                        return
                    }
                }
            }
            completion(nil)
        })
    }
    
    static func queryList(ofIDs ids: [String], forUser uid: String, completion: @escaping ([TNNote])->()) {
        // this is used to get ids for the popup preview menu and probably the note list view
        users.child(uid).observeSingleEvent(of: .value, with: {snapshot in
            if let data = snapshot.value as? JSON {
                let idKeys = data.keys
                var output: [TNNote] = []
                idKeys.forEach({ id in
                    if ids.contains(where: {$0 == id}),
                        let noteData = data[id] as? JSON,
                        let note = TNNote.makeWith(id: id, data: noteData){
                        output.append(note)
                    }
                })
                completion (output)
            }
        })
    }
    
    //MARK: Note Edit Functions
    static func pushTo(note: TNNote){
        currentUser.child(note.id).setValue(note.values)
    }
    
    static func pushNew(note: TNNote)-> String{
        let newNote = currentUser.childByAutoId()
        newNote.setValue(note.values)
        return newNote.key
    }
    
    // MARK: Channel Functions
    static func join(channel: TNChannel) {
        let uid = TNUser.currentUserID
        let email = TNUser.currentUserEmail
        currentUser.child(TNUser.Property.channels.rawValue).setValue(channel.name, forKey: channel.id)
        channels.child(channel.id).child(TNChannel.Property.members.rawValue).setValue(email.toFBEmailFormat(), forKey: uid)
    }
    
    static func add(channelNamed name: String) {
        let newChannel = channels.childByAutoId()
        newChannel.setValue([TNChannel.Property.name : name])
        join(channel: TNChannel(id: newChannel.key, name: name, members: [], notes: []))
    }
    
    static func remove(user: TNUser, fromChannel channel: TNChannel) {
        
    }
    
    static func queryChannels(byProperty property: TNChannel.Property, withValue value: String, completion: @escaping ([TNChannel])->()) {
        channels.observeSingleEvent(of: .value, with: { snapshot in
            if let data = snapshot.value as? JSON {
                var output: [TNChannel] = []
                let ids = data.keys
                for id in ids {
                    guard let channelData = data[id] as? JSON else {continue}
                    if let channel = TNChannel.makeWith(id: id, dict: channelData){
                        var shouldAppend = false
                        switch property{
                        case .notes:
                            shouldAppend = channel.notes.contains(where: {
                                $0.title.lowercased() == value.lowercased()
                            })
                        case .members:
                            //NOTE: Cannot search members by id. Users will never have access to this
                            shouldAppend = channel.members.contains(where: {
                                $0.email == value.toFBEmailFormat() ?? " "
                            })
                        case .name:
                            shouldAppend = channel.name == value
                        case .id:
                            shouldAppend = channel.id == value
                        }
                        if shouldAppend {
                            output.append(channel)
                        }
                    }
                }
            }
        })
    }
    
    // MARK: Block Functions
    static func block(_ user: TNUser) {
        currentUser.child("blocklist").setValue(user.email.toFBEmailFormat(), forKey: user.id)
    }
    
    static func unblock(_ user: TNUser) {
        currentUser.child("blocklist").child(user.id).removeValue()
    }
    
    static func observeBlocklist(_ active: Bool){
        if active{
            currentUser.child("blocklist").observe(.value, with: {snapshot in
                guard let data = snapshot.value as? [String:String] else {return}
                UserDefaults.standard.set(data, forKey: "blocklist")
            })
        }else {
            currentUser.child("blocklist").removeAllObservers()
        }
    }
    
    // MARK: Filter Functions
    private static func filterByID(data: JSON, id: String, target: String)->TNNote? {
        if target == id, let note = TNNote.makeWith(id: id, data: data){
            return note
        }
        return nil
    }
    
    private static func filterByDate(data: JSON, id: String, target: String)->TNNote? {
        if let note = TNNote.makeWith(id: id, data: data),
            let targetParse = target.components(separatedBy: "T").first,
            let dateParse = note.date.components(separatedBy: "T").first,
            dateParse.contains(targetParse) {
            return note
        }
        return nil
    }
    
    private static func filterbyRelevance(data: JSON, id: String, target: String)->TNNote?  {
        if let property = data["property"] as? String,
            let value = data[property] as? String,
            let note = TNNote.makeWith(id: id, data: data) {
            let valueParsed = value.lowercased()
            let targetParsed = target.lowercased()
            if valueParsed.contains(targetParsed){
                return note
            }
        }
        return nil
        
    }
}
    /*
    static func makeTestData(){
        let observations = ["I saw","I heard","I watched","It looked like","I thought about","I remembered", "I observed"]
        let names = ["John","Fred","Sally","Margaret","Umberto","Raquel", "Tran", "Seung-In"]
        let nouns = ["a bird", "a roach", "a sandwich", "a cat", "a dog", "a statue", "a weasel", "a burrito"] + names
        let actions = ["eating","sniffing","looking at", "sizing up", "shopping for", "hugging", "arguing with"]
        let places = ["House","Restaurant","Hotel","Garage","Favorite Park","Apartment","Grocery Store", "Department Store"]
        let titles1 = ["Just a ", "Untitled ", "Today's ", "A little "]
        let titles2 = ["Poem", "Thought", "Rant", "Note", "Weird Thing"]
        for _ in 0...20 {
            
            // get random nums for random info
            let plNameNum = Int(arc4random_uniform(UInt32(names.count)))
            let plPlaceNum = Int(arc4random_uniform(UInt32(places.count)))
            let contobsNum = Int(arc4random_uniform(UInt32(observations.count)))
            let contNoun1Num = Int(arc4random_uniform(UInt32(nouns.count)))
            let contNoun2Num = Int(arc4random_uniform(UInt32(nouns.count)))
            let contVerbNum = Int(arc4random_uniform(UInt32(actions.count)))
            let title1Num = Int(arc4random_uniform(UInt32(titles1.count)))
            let title2Num = Int(arc4random_uniform(UInt32(titles2.count)))
            let interval = Double(arc4random())
            let x = Double(arc4random_uniform(100)) * 0.0001
            let y = Double(arc4random_uniform(100)) * 0.0001
            
            // put together random info
            let place = names[plNameNum] + "'s " + places[plPlaceNum]
            let content = [observations[contobsNum], nouns[contNoun1Num], actions[contVerbNum], nouns[contNoun2Num]].joined(separator: " ")
            let title = titles1[title1Num] + titles2[title2Num]
            let date =  Date(timeIntervalSinceNow: interval)
            let dateStr = ISO8601DateFormatter().string(from: date)
            let myCoord = CLLocationCoordinate2DMake(
                37.332000 - x,
                -122.032969 - y
            )   //should be near apple HQ
            
            print ("MAKING: \(myCoord)")
            
            // create note object
            let newNote = TNNote(id: "nil", title: title, date: dateStr, location: place, content: content)
            
            // pass note object to firebase, get id
            let id = pushNew(note: newNote)
            
            // push location up to geofire at id
            GeoFireClient.addLocation(noteID: id, coordinate: myCoord)
        }
    }
}*/
