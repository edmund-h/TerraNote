//
//  ViewController.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/5/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import UIKit
import FTPopOverMenu_Swift
import GoogleSignIn

class TNMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        mapView.isRotateEnabled = false
        mapView.showsPointsOfInterest = false
        mapView.setUserTrackingMode(.follow, animated: true)
        
        addButton.layer.cornerRadius = 19
        searchButton.layer.cornerRadius = 19
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.title = "TerraNote"
        
        let notificationName = NSNotification.Name.init("mapViewChangeLocation")
        NotificationCenter.default.addObserver(self, selector: #selector(changeLocation), name: notificationName, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == false {
            presentSettingsController()
        } else {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let identifier = segue.identifier else {return}
        switch identifier {
        case "note":
            if let note = sender as? TNNote.Short, let destination = segue.destination as? TNNewNoteVC {
                destination.noteShort = note
            }
        case "search":
            if let notes = sender as? [TNNote.Short], let destination = segue.destination as? TNSearchTableVC{
                destination.notes = notes
                destination.showSearch = false
            }
        default: break
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        
        FTPopOverMenu.showForSender(sender: sender, with: ["My Location!", "Find Location","Find Note","Change Channel"], done: { option in
            switch option{
            case 0:
                self.mapView.setUserTrackingMode( .follow , animated: true)
            case 1:
                self.performSegue(withIdentifier: "location", sender: nil)
            case 2:
                self.performSegue(withIdentifier: "search", sender: nil)
            case 3:
                self.performSegue(withIdentifier: "channel", sender: nil)
            default:
                print("oops!")
            }
        }, cancel: {})
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        presentSettingsController()
    }
    
    // MARK: Helper functions
    @objc func changeLocation(notification: Notification) {
        var location: String = ""
        if let info = notification.userInfo, let myLocation = info["location"] as? String {
            location = myLocation
        } // left the possibility for other ways to use this function here but probably should only use this notification
        mapView.userTrackingMode = .none
        CoreLocClient.forwardGeocode(address: location, completion: { placemark in
            if let placemark = placemark, let placemarkLocation = placemark.location{
                let coordinate = placemarkLocation.coordinate
                DispatchQueue.main.async {
                    self.mapView.setCenter(coordinate, animated: true)
                }
            }
        })
    }
    func presentSettingsController() {
        let signIn = TNSignInController(nibName: "TNSignInController", bundle: Bundle.main)
        self.present(signIn, animated: false, completion: nil)
    }
}

//MARK: MapView, CLLocationManager Delelegate
extension TNMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is TNAnnotation {
            let identifier = "TNAnnotation"
            var annotationView: MKPinAnnotationView
            if let rawAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView{
                annotationView = rawAnnotationView
                annotationView.annotation = annotation
            } else {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.subviews.forEach({$0.removeFromSuperview()})
                //initial annotation setup if needed
            }
            // further setup here
            annotationView.pinTintColor = UIColor.mapChoco
            return annotationView
        }
        return nil
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        let id = UserDefaults.standard.string(forKey: "currentChannel")
        GeoFireClient.queryLocations(within: mapView.region, channel: id, response: { (id, loc) in
            let placemark = TNAnnotation(coordinate: loc.coordinate, noteID: id)
            for annotation in mapView.annotations{
                guard annotation is TNAnnotation,
                    let myAnnotation = annotation as? TNAnnotation else { continue }
                let idCheck = !(myAnnotation.noteIDs.contains(id))
                let coordCheck = myAnnotation.coordinate.isNearbyTo(loc.coordinate)
                if idCheck && coordCheck {
                    myAnnotation.noteIDs.append(id)
                    return
                }
            }
            self.mapView.addAnnotation(placemark)
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? TNAnnotation, annotation.count > 0 else { return }
        let count = annotation.count
        let max = 4
        FirebaseClient.queryList(ofIDs: annotation.noteIDs, forUser: TNUser.currentUserID, completion: { notes in
            var titles = notes.map({$0.title})
            let moreThan4 = count > max
            if  moreThan4 {
                // if there are more than 4 notes, take the first 3
                let slice = titles.prefix(max - 1)
                titles = slice.map({$0})
                // then in the 4th slot, display how many more notes remain. the idea is to never have more than 4 items in the popover
                titles.append("\(count - max + 1) more notes...")
            }
            let hitbox = view.subviews.first ?? TNViewFormatter.pinHitbox(view)
            view.layoutIfNeeded() // this crap is here because the pin annotation shadow throws off the FTPopOver, this adds a view corresponding to the pin itself
            FTPopOverMenu.showForSender(sender: hitbox, with: titles, done: { index in
                if index == 3 && moreThan4 {
                    self.performSegue(withIdentifier: "search", sender: notes)
                } else {
                    self.performSegue(withIdentifier: "note", sender: notes[index])
                }
            }, cancel: {})
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard mapView.userTrackingMode == .follow else {return}
        if let clLoc = locations.last {
            let center = clLoc.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion.init(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}

