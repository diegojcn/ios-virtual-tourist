//
//  PhotoView.swift
//  ios-virtual-tourist
//
//  Created by Diego Neves on 06/01/19.
//  Copyright © 2019 dj. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoView: UIView {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionBtn: UIButton!
    
    @IBOutlet weak var removeCollectionBtn: UIButton!
    
    func switchbuttons(){
        
        if (removeCollectionBtn.isHidden){
            removeCollectionBtn.isHidden = false
            newCollectionBtn.isHidden = true
        } else {
            removeCollectionBtn.isHidden = true
            newCollectionBtn.isHidden = false
        }
        
        
    }
    
}
