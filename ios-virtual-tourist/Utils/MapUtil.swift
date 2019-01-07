//
//  MapUtil.swift
//  ios-virtual-tourist
//
//  Created by Diego Neves on 31/12/18.
//  Copyright © 2018 dj. All rights reserved.
//

import Foundation
import MapKit

public func populateMap(pinsArray: [Pin]) -> [MKAnnotation]{
    
    var annotations = [MKPointAnnotation]()
    
    for pin  in pinsArray {
        
        let annotation = MKPointAnnotation()
        
        if let latitude = pin.latitude, let longitude =  pin.longitude {
            
            let lat = CLLocationDegrees(Double(latitude)!)
            let long = CLLocationDegrees(Double(longitude)!)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            annotation.coordinate = coordinate
            annotations.append(annotation)
            
        }
        
    }
    return annotations
    
}
