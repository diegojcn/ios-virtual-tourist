//
//  DataController.swift
//  ios-virtual-tourist
//
//  Created by Diego Neves on 30/12/18.
//  Copyright © 2018 dj. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil){
        
        persistentContainer.loadPersistentStores { storeDescription, error in
            
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
            
        }
    }
    
}

extension DataController {
    
    func autoSaveViewContext(interval : TimeInterval = 30){
        print("autosaving")
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext(interval: interval)
        }
    }
    
    func delete(obj : NSManagedObject){
        
        viewContext.delete(obj)
        
        try?  viewContext.save()
        
    }
    
    
}

extension DataController {
    
    
    func savePin(latitude: String, longitude: String) -> Pin {
        let pin = Pin(context: viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        pin.creationDate = Date()
        try?  viewContext.save()
        
        return pin
    }
    
    func findImages(pin : Pin) -> [Image]{
        
        var images: [Image] = []
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()

        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fetchRequest.predicate = predicate

        if let result = try? viewContext.fetch(fetchRequest){
           images = result
        }
        
        return images
    }
    
    func saveImage(pin : Pin, imageData : Data) -> Image{
        let image = Image(context: viewContext)
        image.pin = pin
        image.imageData = imageData
        
        try?  viewContext.save()
    
        return image
    }
    
    
}

