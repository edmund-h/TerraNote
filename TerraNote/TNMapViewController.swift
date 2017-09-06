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
        if annotation is MKPlacemark {
            let identifier = "Placemark"
            var annotationView: MKPinAnnotationView
            if let rawAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView{
                annotationView = rawAnnotationView
                annotationView.annotation = annotation
            } else {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                //set up callout options etc here
            }
            // further setup here
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        GeoFireClient.queryLocations(within: mapView.region, response: { (id, loc) in
            let placemark = MKPlacemark(coordinate: loc.coordinate)
            self.mapView.addAnnotation(placemark)
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

