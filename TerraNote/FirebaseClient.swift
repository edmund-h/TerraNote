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
    fileprivate static let users = ref.child(TNObjects.users.rawValue)
    fileprivate static let channels = ref.child(TNObjects.channels.rawValue)
    fileprivate static let notes = ref.child(TNObjects.notes.rawValue)
    fileprivate static let currentUser = users.child(TNUser.currentUserID)
    
    typealias JSON = [String:Any]
    
    // MARK: Note Query Functions
    
    static func getNote (withID id: String, completion: @escaping (TNNote?)->()) {
        notes.child(id).observeSingleEvent(of: .value, with: {snapshot in
            if let noteData = snapshot.value as? JSON,
                let note = TNNote.makeWith(id: id, data: noteData){
                completion(note)
            } else {
                completion(nil)
            }
        })
    }
    
    static func queryNotes (by property: TNNote.Property, with search: String, completion: @escaping ([TNNote.Short])->()) {
        currentUser.child(TNUser.Property.notes.rawValue).observeSingleEvent(of: .value, with: { snapshot in
            if let data = snapshot.value as? JSON {
                switch property{
                case .id:
                    completion(filterByID(data: data, target: search))
                case .date:
                    completion(filterByDate(data: data, target: search))
                case .channel:
                    queryChannelForNotes(name: search, completion: completion)
                case .title:
                    completion(filterByTitle(data: data, target: search))
                default:
                    break
                    //noteData["property"] = property.rawValue
                    //filterFn = filterbyRelevance(data:target:completion:)
                }
            }
        })
    }
    
    static func queryList(ofIDs ids: [String], forUser uid: String, completion: @escaping ([TNNote.Short])->()) {
        // this is used to get ids for the popup preview menu and probably the note list view when looking for another user's notes
        let notesKey = TNUser.Property.notes.rawValue
        users.child(uid).child(notesKey).observeSingleEvent(of: .value, with: {snapshot in
            if let data = snapshot.value as? JSON {
                let idKeys = data.keys
                var output: [TNNote.Short] = []
                idKeys.forEach({ id in
                    if ids.contains(where: {$0 == id}),
                        let noteData = data[id] as? JSON,
                        let note = TNNote.Short.makeWith(id: id, data: noteData){
                        output.append(note)
                    }
                })
                completion (output)
            }
        })
    }
    
    //MARK: Note Edit Functions
    static func pushTo(note: TNNote){
        currentUser.child(TNUser.Property.notes.rawValue).setValue(note.short.values)
        notes.child(note.id).setValue(note.values)
    }
    
    static func pushNew(note: TNNote)-> String{
        //create a child with a random key and save that key to memory
        let newNoteLoc = notes.childByAutoId()
        let idKey = newNoteLoc.key
        //set the note's data at its location in notes directory
        newNoteLoc.setValue(note.values)
        //create shortform entries in the appropriate user and channel directories
        let newNoteShort = TNNote.Short(id: idKey, title: note.title, date: note.date)
        currentUser.child(TNUser.Property.notes.rawValue).updateChildValues(newNoteShort.values)
        if let channel = note.channel {
            let channelIDKey = TNChannel.Property.notes.rawValue
            channels.child(channel.id).child(channelIDKey).updateChildValues(newNoteShort.values)
        }
        return idKey
    }
    
    // MARK: Channel Functions
    static func join(channel: TNChannel) {
        let uid = TNUser.currentUserID
        let email = TNUser.currentUserEmail
        currentUser.child(TNUser.Property.channels.rawValue).setValue([channel.id : channel.name])
        channels.child(channel.id).child(TNChannel.Property.members.rawValue).setValue([uid : email.toFBEmailFormat()])
    }
    
    static func add(channelNamed name: String) {
        let newChannel = channels.childByAutoId()
        newChannel.child(TNChannel.Property.name.rawValue).setValue(name)
        join(channel: TNChannel(id: newChannel.key, name: name, members: [], notes: []))
    }
    
    static func remove(user: TNUser, fromChannel channel: TNChannel) {
        channels.child(channel.id).removeValue()
        users.child(user.id).child(TNUser.Property.channels.rawValue).child(channel.id).removeValue()
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
                                $0.email == value
                            })
                        case .name:
                            shouldAppend = channel.name == value
                        case .id:
                            shouldAppend = channel.id == value
                        }
                        if shouldAppend {
                            output.append(channel)
                        }
                        completion(output)
                    }
                }
            }
        })
    }
    
    // MARK: Block Functions
    static func block(_ user: TNUser) {
        currentUser.child(TNUser.Property.blocklist.rawValue).setValue(user.email.toFBEmailFormat(), forKey: user.id)
    }
    
    static func unblock(_ user: TNUser) {
        currentUser.child(TNUser.Property.blocklist.rawValue).child(user.id).removeValue()
    }
    
    static func observeBlocklist(_ active: Bool){
        if active{
            currentUser.child(TNUser.Property.blocklist.rawValue).observe(.value, with: {snapshot in
                guard let data = snapshot.value as? [String:String] else {return}
                UserDefaults.standard.set(data, forKey: TNUser.Property.blocklist.rawValue)
            })
        }else {
            currentUser.child(TNUser.Property.blocklist.rawValue).removeAllObservers()
        }
    }
    
    // MARK: Filter Functions
    private static func filterByID(data: JSON, target: String)-> [TNNote.Short] {
        for noteData in data {
            if target == noteData.key,
                let noteValues = noteData.value as? JSON,
                let note = TNNote.Short.makeWith(id: target, data: noteValues){
                return [note]
            }
        }
        return []
    }
    
    private static func filterByDate(data: JSON, target: String)->[TNNote.Short] {
        var notes: [TNNote.Short] = []
        for key in data.keys {
            if let noteData = data[key] as? JSON,
                let noteShort = TNNote.Short.makeWith(id: key, data: noteData),
                let targetParse = target.components(separatedBy: "T").first,
                let dateParse = noteShort.date.components(separatedBy: "T").first,
                dateParse.contains(targetParse),
                let note = TNNote.Short.makeWith(id: key, data: noteData){
                notes.append(note)
            }
        }
        return notes
    }
    
    static func queryChannelForNotes(name: String, completion: @escaping ([TNNote.Short])->()) {
        // first get the channels the user is in and see if there is a channel containing that name.
        currentUser.child(TNUser.Property.channels.rawValue).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let channelData = snapshot.value as? JSON else { completion([]); return}
            var myChannels: [TNChannel] = []
            channelData.forEach({ (channelID, channelValueData) in
                if let channelValues = channelValueData as? JSON,
                    let channel = TNChannel.makeWith(id: channelID, dict: channelValues){
                    myChannels.append(channel)
                }
            })
            if let channel = myChannels.filter({ $0.name == name }).first {
                // then ask that channel for all its notes
                let notesKey = TNChannel.Property.notes.rawValue
                channels.child(channel.id).child(notesKey).observeSingleEvent(of: .value, with: {noteSnapshot in
                    guard let notesData = noteSnapshot.value as? JSON else { completion([]); return}
                    var notes: [TNNote.Short] = []
                    notesData.forEach({(id, values) in
                        if let values = values as? JSON,
                            let note  = TNNote.Short.makeWith(id: id, data: values){
                            notes.append(note)
                        }
                    })
                    // return those notes in the completion
                    completion(notes)
                })
            }
            
        })
    }
    
    private static func filterByTitle(data: JSON, target: String)->[TNNote.Short] {
        var output: [TNNote.Short] = []
        data.forEach { (id, values) in
            if let values = values as? [String:String],
                let note = TNNote.Short.makeWith(id: id, data: values),
                note.title.contains(target){
                    output.append(note)
            }
        }
        return output
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
