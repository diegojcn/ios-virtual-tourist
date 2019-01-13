//
//  ViewController.swift
//  ios-virtual-tourist
//
//  Created by Diego Neves on 16/12/18.
//  Copyright © 2018 dj. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewViewController: UIViewController {


    @IBOutlet weak var mapView: MapView!
    
    var dataController: DataController!
    
    var flickrService :  FlickrService!
    
    var tappedPin: Pin?
    
    var pins: [Pin] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.map.delegate = self
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinToMap(longGesture:)))
        self.mapView.map.addGestureRecognizer(longGesture)
        iniciateMapWithPins()
       
    }
    
    private func iniciateMapWithPins() {
        
        self.pins = dataController.searchPin(key: "creationDate", ascending: false, format: nil, argumementArray: nil)
        
        let annotations = populateMap(pinsArray: pins)
        self.mapView.map.removeAnnotations(mapView.map.annotations)
        self.mapView.map.addAnnotations(annotations)
        self.mapView.map.reloadInputViews()
    }
    
    @IBAction func editMap(_ sender: Any) {
        
        self.mapView.deletePinBtn.isHidden = !self.mapView.deletePinBtn.isHidden
        
    }
    
    private func deletePin(pin : Pin) {
    
        dataController.delete(obj: pin)
        iniciateMapWithPins()
       
    }
    
    @objc func addPinToMap(longGesture: UILongPressGestureRecognizer) {
        
        
        if longGesture.state == .ended {
            let locationInView = longGesture.location(in: self.mapView)
            let locationOnMap: CLLocationCoordinate2D = self.mapView.map.convert(locationInView, toCoordinateFrom: self.mapView)
            addAnnotation(location: locationOnMap)
            dataController.savePin(latitude: locationOnMap.latitude.description, longitude: locationOnMap.longitude.description)
       }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoSegue" {
            
            if let photoController = segue.destination as? PhotosColletctionViewController {
                
                photoController.pin = tappedPin
                photoController.flickrService = flickrService
                photoController.dataController = dataController
                
            }
          
        }
    }
}


extension MapViewViewController: MKMapViewDelegate{

    func addAnnotation(location: CLLocationCoordinate2D){
        var annotations : [MKPointAnnotation] = []
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotations.append(annotation)
        self.mapView.map.addAnnotations(annotations)
        self.mapView.map.reloadInputViews()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let lat : String = view.annotation?.coordinate.latitude.description, let long : String = view.annotation?.coordinate.longitude.description else {
            return
        }
        
        let result : [Pin] = dataController.searchPin(key: "creationDate", ascending: false, format: "latitude == %@ && longitude == %@", argumementArray: [lat, long])
        self.tappedPin = result[0]
        
        if self.mapView.deletePinBtn.isHidden {
            
            performSegue(withIdentifier: "photoSegue", sender: nil)
            
        } else{
        
            self.deletePin(pin : self.tappedPin!)
            
        }
    }
    
}
