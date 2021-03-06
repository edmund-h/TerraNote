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
    
    var noteShort: TNNote.Short?
    var note: TNNote? {
        didSet {
            if let note = self.note {
                titleField.text = note.title
                locField.text = note.location
                contentField.text = note.content
                locField.allowsEditingTextAttributes = false
                hereBtn.titleLabel?.text = "Change"
            }
        }
    }
    
    private let myLocationSignifier = "My Current Location"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.layer.borderColor = UIColor.chocolate.cgColor
        locField.layer.borderColor = UIColor.chocolate.cgColor
        TNViewFormatter.formatView(contentField)
        contentField.textColor = UIColor.chocolate
        locField.placeholder = myLocationSignifier
        contentField.text = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let noteID = noteShort?.id else {return}
        FirebaseClient.getNote(withID: noteID, completion: {note in
            if let note = note {
                self.note = note
                FirebaseClient.checkIfBlocked(email: note.creator, completion: {blocked in
                    if blocked {
                        let youreBlockedAlert = UIAlertController(title: "Access Denied", message: "You do not have access to this note.", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                                self.dismiss(animated: false, completion: {})
                            })
                        youreBlockedAlert.addAction(dismissAction)
                        self.present(youreBlockedAlert, animated: true, completion: {})
                    }
                })
            }
        })
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
        navigationController?.popToRootViewController(animated: true)
    }
    
    func sendNewNoteToFirebase(placemark: CLPlacemark?) {
        let title = titleField.text ?? "Untitled Note"
        let content = contentField.text ?? " "
        let date = ISO8601DateFormatter().string(from: Date())
        if let placemark = placemark, let location = placemark.location {
            let addr = placemark.address ?? "Unknown Location"
            var note = TNNote(id: "nil", creator: TNUser.currentUserEmail, title: title, date: date, location: addr, content: content, channel: nil )
            // not having this in a closure kind of bothers me
            note = FirebaseClient.pushNew(note: note)
            let coord = location.coordinate
            GeoFireClient.addLocation(note: note, coordinate: coord)
        } else {
            // TODO: Handle error with alert
            print ("There was a problem getting your location.")
        }
    }
}
