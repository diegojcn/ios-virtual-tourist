//
//  Utils.swift
//  ios-virtual-tourist
//
//  Created by Diego Neves on 29/12/18.
//  Copyright © 2018 dj. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}


func displayError(_ error: String) {
    print(error)
}






