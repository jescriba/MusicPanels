//
//  Drums.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 3/18/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import AudioKit

class Drums: NSObject {
    let mixer = AKMixer()
    let kick = AKSynthKick()
    let snare = AKSynthSnare(duration: 0.06, resonance: 0.3)
    let closedHH = AKMIDISampler()
    let openHH = AKMIDISampler()
    
    override init() {
        super.init()
    
        closedHH.volume = 0.8
        [kick, snare, closedHH, openHH] >>> mixer
    }
    
    func setupSamplers() {
        let closedHHPath = Bundle.main.path(forResource: "closedHH", ofType: "mp3")!
        let openHHPath = Bundle.main.path(forResource: "openHH", ofType: "mp3")!
        do {
            try closedHH.loadAudioFile(AKAudioFile(forReading:             URL(fileURLWithPath: closedHHPath)))
            try openHH.loadAudioFile(AKAudioFile(forReading:             URL(fileURLWithPath: openHHPath)))
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func play(type: SequenceType) {
        switch type {
            case .kick:
                kick.play(noteNumber: 0, velocity: 90)
            case .snare:
                snare.play(noteNumber: 0, velocity: 90)
            case .closedHH:
                closedHH.play(noteNumber: 60, velocity: 90, channel: 3)
            case .openHH:
                openHH.play(noteNumber: 60, velocity: 90, channel: 4)
        }
    }
}
