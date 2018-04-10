//
//  TutorialManager.swift
//  MusicPanels
//
//  Created by Joshua Escribano on 4/1/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation

class TutorialManager {
    static func hasSeenTutorial() -> Bool {
        return UserDefaults.standard.bool(forKey: "IntroExperience-1.1")
    }
    
    static func setHasSeenTutorial() {
        UserDefaults.standard.set(true, forKey: "IntroExperience-1.1")
    }
}
