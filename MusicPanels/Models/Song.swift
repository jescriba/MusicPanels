//
//  Song.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/25/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation

class Song: NSObject, Codable {
    var name: String
    var date: Date
    var fileName: String?
    
    init(name: String) {
        self.name = name
        self.date = Date()
        
        super.init()
    }
}
