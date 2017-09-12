//
//  TNNewNoteVC.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/6/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import UIKit

class TNNewNoteVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locField: UITextField!
    @IBOutlet weak var hereBtn: UIButton!
    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    
    var note: TNNote?
    
    private let myLocationSignifier = "My Current Location"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.layer.borderColor = UIColor.chocolate.cgColor
        locField.layer.borderColor = UIColor.chocolate.cgColor
        TNViewFormatter.formatView(contentField)
        contentField.textColor = UIColor.chocolate
        locField.placeholder = myLocationSignifier
        contentField.text = nil
        if let note = note {
            titleField.text = note.title
            locField.text = note.location
            contentField.text = note.content
            locField.allowsEditingTextAttributes = false
            hereBtn.titleLabel?.text = "Change"
        }
    }
    
    @IBAction func hereBtnTouched() {
        if let note = note {
            //TODO: make an alert that asks the user to confirm editing location
        }
        locField.text = myLocationSignifier
    }
    
    @IBAction func doneBtnTouched() {
        //TODO: should not make a new note if note already exists
        let loc = locField.text ?? myLocationSignifier
        if loc == myLocationSignifier  || loc.isEmpty {
            CoreLocClient.geocodeMyLocation(completion: { placemark in
               self.sendNewNoteToFirebase(placemark: placemark)
            })
        } else {
            CoreLocClient.forwardGeocode(address: loc, completion: { placemark in
                self.sendNewNoteToFirebase(placemark: placemark)
            })
        }
    }
    
    func sendNewNoteToFirebase(placemark: CLPlacemark?) {
        let title = titleField.text ?? "Untitled Note"
        let content = contentField.text ?? " "
        let date = ISO8601DateFormatter().string(from: Date())
        if let placemark = placemark, let location = placemark.location {
            let addr = placemark.address ?? "Unknown Location"
            let note = TNNote(id: "nil", title: title, date: date, location: addr, content: content)
            let id = FirebaseClient.pushNew(note: note)
            let coord = location.coordinate
            GeoFireClient.addLocation(noteID: id, coordinate: coord)
        } else {
            // TODO: Handle error with alert
            print ("There was a problem getting your location.")
        }
    }
}
