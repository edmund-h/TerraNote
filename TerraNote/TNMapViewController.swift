//
//  ViewController.swift
//  TerraNote
//
//  Created by Edmund Holderbaum on 9/5/17.
//  Copyright © 2017 Bozo Design Labs. All rights reserved.
//

import UIKit

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
                //set up callout options etc here
                annotationView.canShowCallout = true
                let btn = UIButton(type: .detailDisclosure)
                //let label = UILabel()
                annotationView.rightCalloutAccessoryView = btn
                //annotationView.leftCalloutAccessoryView = label
            }
            // further setup here
            annotationView.pinTintColor = UIColor.chocolate
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if let label = view.rightCalloutAccessoryView as? UILabel,
//            let annotation = view.annotation as? TNAnnotation {
//            var noun = "Note"
//            if annotation.count == 1 { noun += "s" }
//            label.text = "\(annotation.count) \(noun)"
//        }
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

