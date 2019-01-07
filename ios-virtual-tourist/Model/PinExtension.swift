//
//  PinExtension.swift
//  ios-virtual-tourist
//
//  Created by Diego Neves on 29/12/18.
//  Copyright © 2018 dj. All rights reserved.
//

import Foundation

extension Pin {

    
    public func generateMaxMinLatLog() -> String{
        
        
        if let latitudeDouble = Double (latitude!), let longitudeDouble = Double (longitude!){
            
            let minimumLon = max(longitudeDouble - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitudeDouble - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitudeDouble + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitudeDouble + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
           
            
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        }else{
            
            return "0,0,0,0"
        }
        
    }
    
    
}
