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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        mapView.isRotateEnabled = false
        mapView.showsPointsOfInterest = false
        mapView.setUserTrackingMode(.follow, animated: true)
        
        addButton.layer.cornerRadius = 19
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.title = "TerraNote"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == false {
            let signIn = TNSignInController(nibName: "TNSignInController", bundle: Bundle.main)
            self.present(signIn, animated: false, completion: nil)
        } else {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

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
        
        GeoFireClient.queryLocations(within: mapView.region, response: { (id, loc) in
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
        var list: [String] = []
        let moreThan4 = count > max
        if  moreThan4 {
            let slice = annotation.noteIDs.prefix(max)
            list = slice.map({$0})
        } else {
            list = annotation.noteIDs
        }
        FirebaseClient.queryList(ofIDs: list, completion: { notes in
            var titles = notes.map({$0.title})
            if moreThan4 {
                titles.removeLast()
                titles.append("\(count - max + 1) more notes...")
            }
            let hitbox = view.subviews.first ?? TNViewFormatter.pinHitbox(view)
            view.layoutIfNeeded()
            FTPopOverMenu.showForSender(sender: hitbox, with: titles, done: { index in
//                switch index {
//                case 0...3:
//                    self.performSegue(withIdentifier: "note", sender: notes[index])
//                default:
//                    self.performSegue(withIdentifier: "noteList", sender: annotation.noteIDs)
//                }
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

