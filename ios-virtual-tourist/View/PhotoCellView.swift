//
//  PhotoCellView.swift
//  ios-virtual-tourist
//
//  Created by Diego Neves on 27/12/18.
//  Copyright © 2018 dj. All rights reserved.
//

import Foundation
import UIKit




class PhotoCellView : UICollectionViewCell{
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imageEntity : Image?
    
    func clearCellView(){
        self.image.image = nil
        self.imageEntity = nil
    }
    
    func customCell () {
        
        let bcolor : UIColor = UIColor( red: 0.2, green: 0.2, blue:0.2, alpha: 0.3 )
        self.layer.borderColor = bcolor.cgColor
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
        self.backgroundColor=UIColor.gray
        
    }
    
    
}

extension PhotoCellView {
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.blue : UIColor.yellow
            self.image.alpha = isSelected ? 0.75 : 1.0
        }
    }
    
    
}

