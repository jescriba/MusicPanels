//
//  KeyboardPlayer.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 12/21/17.
//  Copyright © 2017 Joshua Escribano. All rights reserved.
//

import Foundation
import AudioKit
import AudioKitUI

class Keyboard: NSObject, AKKeyboardDelegate {
    let mixer = AKMixer()
    let bank: AKOscillatorBank
    var vibratoRate: Double = 0 {
        didSet {
            bank.vibratoRate = vibratoRate
        }
    }
    var vibratoDepth: Double = 0 {
        didSet {
            bank.vibratoDepth = vibratoDepth
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
    private var tremolo = AKTremolo()
    var tremoloDepth: Double = 0 {
        didSet {
            tremolo.depth = tremoloDepth
        }
    }
    var tremoloRate: Double = 0 {
        didSet {
            tremolo.frequency = tremoloRate
        }
    }
    
    override init() {
        bank = AKOscillatorBank()
        super.init()
        bank >>> delay
        bank >>> reverb
        bank >>> tremolo
        delay >>> mixer
        reverb >>> mixer
        tremolo >>> mixer
        mixer.volume = 0.6
    }
    
    func noteOn(note: MIDINoteNumber) {
        // TODO Way to get velocity?
        bank.play(noteNumber: note, velocity: 60)
    }
    
    func noteOff(note: MIDINoteNumber) {
        bank.stop(noteNumber: note)
    }
}
