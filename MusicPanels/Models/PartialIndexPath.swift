//
//  PartialIndexPath.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 3/15/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation

protocol GenericIndexPath {}

struct PartialIndexPath: GenericIndexPath {
    let row: Double
    let section: Int
    
    init(row: Double, section: Int) {
        self.row = row
        self.section = section
    }
}

extension IndexPath: GenericIndexPath {}
