//
//  Microphone.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 3/19/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import AudioKit

class Microphone: NSObject {
    let akMicrophone = AKMicrophone()
    let mixer = AKMixer()
    var volume: Double = 0 {
        didSet {
            akMicrophone.volume = volume
            mixer.volume = volume
            if volume < 0.15 {
                stop()
            } else if !akMicrophone.isStarted {
                start()
            }
        }
    }
    var isStarted: Bool = false {
        didSet {
            if isStarted {
                start()
            } else {
                stop()
            }
        }
    }
    private var reverb = AKReverb()
    var reverbDepth: Double = 0 {
        didSet {
            reverb.dryWetMix = reverbDepth
        }
    }
    // for now to save slider space delay will be a mix of parameters
    private var delay = AKDelay()
    var delayFX: Double = 0 {
        didSet {
            delay.dryWetMix = delayFX
            delay.feedback = 0.5 * delayFX
            delay.time = 0.7 * delayFX
        }
    }
    
    override init() {
        super.init()

        akMicrophone >>> reverb
        akMicrophone >>> delay
        reverb >>> mixer
        delay >>> mixer
    }
    
    func start() {
        akMicrophone.start()
    }
    
    func stop() {
        akMicrophone.stop()
    }
}
