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
        mapView.map.delegate = self
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinToMap(longGesture:)))
        mapView.map.addGestureRecognizer(longGesture)
        
        
        let fetchREquest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchREquest.sortDescriptors = [sort]
        if let result = try? dataController.viewContext.fetch(fetchREquest){
            pins = result
        }
        let annotations = populateMap(pinsArray: pins)
        self.mapView.map.addAnnotations(annotations)
        self.mapView.map.reloadInputViews()
        print("Recovering Pins \(pins)")
       
        
    }

    @objc func addPinToMap(longGesture: UILongPressGestureRecognizer) {
        
        
        if (longGesture.state == .ended) {
            let locationInView = longGesture.location(in: mapView)
            let locationOnMap: CLLocationCoordinate2D = mapView.map.convert(locationInView, toCoordinateFrom: mapView)
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
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    
        print("add pin")
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
        
        guard let lat : String = view.annotation?.coordinate.latitude.description, let long : String = view.annotation?.coordinate.longitude.description else{
            return
        }
        
        print("tapped on pin latidute:\(lat), longidute: \(long)")
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let predicate = NSPredicate(format: "latitude == %@ && longitude == %@", argumentArray: [lat, long])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
          self.tappedPin = result[0]
        }
        performSegue(withIdentifier: "photoSegue", sender: nil)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let doSomething = view.annotation?.title! {
                print("do something")
            }
        }
    }
}
