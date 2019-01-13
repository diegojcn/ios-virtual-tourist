//
//  PhotosColletctionViewController
//  ios-virtual-tourist
//
//  Created by Diego Neves on 24/12/18.
//  Copyright © 2018 dj. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotosColletctionViewController: UIViewController {
    
    @IBOutlet var photoView: PhotoView!
    
    var pin: Pin!
    
    var dataController: DataController!
    
    var flickrService :  FlickrService!
    
    var photos : [[String:AnyObject]]?

    var images : [Int : Image] = [:]
    
    var selectedIndex : [Int : IndexPath] = [:]
    
    let imageCache = NSCache<AnyObject, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recoverListOfImages(pin: self.pin)
        let annotations = populateMap(pinsArray: [self.pin])
        self.photoView.photosCollectionView.allowsMultipleSelection = true
        self.photoView.mapView.delegate = self
        self.photoView.mapView.addAnnotations(annotations)
        self.photoView.mapView.reloadInputViews()
        
    }
    
    
    @IBAction func newCollection(_ sender: Any) {
        
        for (_, image) in images{
        
            dataController.delete(obj: image)
        }
        images.removeAll()
        newPhotoCollection(selectedPin: self.pin)
        self.photoView.photosCollectionView.reloadData()
        
    }
    
    
    @IBAction func removeSelectedPics(_ sender: Any) {
        
        var values : [IndexPath] = []
        for (key, value) in selectedIndex{
            
            let imageToDelete : Image! = self.images[key]
            self.dataController.delete(obj: imageToDelete)
            self.images.removeValue(forKey: key)
            values.append(value)
            
        }
        
        self.photoView.photosCollectionView.deleteItems(at: values)
        self.images.removeAll()
        self.recoverListOfImages(pin: self.pin)
        self.selectedIndex.removeAll()
        self.photoView.switchbuttons()

    }
    
    private func recoverListOfImages(pin: Pin) {
        let imageList : [Image] = dataController.findImages(pin: pin)
        
        for (index, item) in imageList.enumerated() {
           images[index] = item
        }
        
        if (images.count > 0) {
            self.photoView.photosCollectionView.reloadData()
        }else {
            newPhotoCollection(selectedPin: self.pin)
        }
    }

    private func newPhotoCollection(selectedPin : Pin){
    
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.SafeSearch : Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.BoundingBox: selectedPin.generateMaxMinLatLog(),
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Page: Int(arc4random_uniform(UInt32(200))),
            Constants.FlickrParameterKeys.PerPage: 20
            ] as [String:AnyObject]
        
        
            flickrService.searchPhotosImages(methodParameters) { (result, error) in
            
                /* GUARD: Are the "photos" and "photo" keys in our result? */
                 guard let photoArray = result?[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                   displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(result)")
                  return
                 }
                 self.photos = photoArray
                 performUIUpdatesOnMain {
                    self.photoView.photosCollectionView.reloadData()
                 }
            
            }
    
    }


}

extension PhotosColletctionViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: (collectionViewSize/2))
    }

}

extension PhotosColletctionViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let count = self.photos?.count else {
            if self.images.count > 0 {
                
                return self.images.count
            }
            
            return 0
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (selectedIndex.count == 0){
            self.photoView.switchbuttons()
        }
        selectedIndex[indexPath.row] = indexPath
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
      
        selectedIndex.removeValue(forKey: indexPath.row)
        
        if (selectedIndex.count == 0){
            self.photoView.switchbuttons()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCellView
        cell.customCell()
        cell.clearCellView()
        cell.activityIndicator.startAnimating()
        
       
        if let photos = self.photos {
            
            let photoDictionary : [String:AnyObject] = photos[indexPath.row]
            
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                return cell
            }
            let imageURL = URL(string : imageUrlString)
            
            
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, respones, error) in
                
                if error != nil {
                    displayError(error.debugDescription)
                    return
                }
                performUIUpdatesOnMain {
                    
                    let imageToCache = UIImage(data: data!)
                    let imageData = imageToCache!.jpegData(compressionQuality: 0.75)
                    let imageEntity = self.dataController.saveImage(pin: self.pin, imageData : imageData!)
                    cell.imageEntity = imageEntity
                    cell.image.image = imageToCache
                    self.imageCache.setObject(imageToCache!, forKey: imageUrlString as AnyObject)
                    cell.activityIndicator.stopAnimating()
                
                }
                
            }).resume()
            
        } else {
            
            guard let imageEntity : Image = images[indexPath.row] else {
                return cell
            }
            cell.imageEntity = imageEntity
            let uiImage = UIImage(data: imageEntity.imageData!)
            cell.image.image = uiImage
            cell.activityIndicator.stopAnimating()
        }
       
        return cell
    }
    
}

extension PhotosColletctionViewController: MKMapViewDelegate{
    
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
    
}




