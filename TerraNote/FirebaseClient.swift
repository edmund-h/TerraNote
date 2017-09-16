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
    
    fileprivate static var firebase: DatabaseReference {
        if let uid = UserDefaults.standard.string(forKey: "uid"){
            return ref.child("users").child(uid).child("notes")
        }
        return ref.child("users").child("unloggedInUser").child("notes")
    }
    
    typealias JSON = [String:Any]
    
    static func queryNotes (by property: TNNote.Property, with search: String, completion: @escaping ([TNNote])->()) {
        firebase.observeSingleEvent(of: .value, with: { snapshot in
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
        let firebase = ref.child("users").child(uid)
        firebase.observeSingleEvent(of: .value, with: { snapshot in
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
    
    static func queryChannels(byProperty: TNChannel.Property) {
        let firebase = ref.child("channels")
        firebase.observeSingleEvent(of: .value, with: { snapshot in
            
        })
    }
    
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
    
    static func queryList(ofIDs ids: [String], completion: @escaping ([TNNote])->()) {
        firebase.observeSingleEvent(of: .value, with: {snapshot in
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
    
    static func pushTo(note: TNNote){
        firebase.child(note.id).setValue(note.values)
    }
    
    static func pushNew(note: TNNote)-> String{
        let newNote = firebase.childByAutoId()
        newNote.setValue(note.values)
        return newNote.key
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
