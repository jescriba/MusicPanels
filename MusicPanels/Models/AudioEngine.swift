//
//  AudioEngine.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 12/21/17.
//  Copyright © 2017 Joshua Escribano. All rights reserved.
//

import Foundation
import AudioKit

protocol AudioEngineDelegate {
    func didUpdateIsPlaying(_ isPlaying: Bool)
}

class AudioEngine: NSObject {
    static let shared = AudioEngine()
    let keyboard = Keyboard()
    let microphone = Microphone()
    let drums = Drums()
    let sequencer = Sequencer()
    var delegate: AudioEngineDelegate?
    var recorder: AKNodeRecorder?
    var player: AKAudioPlayer?
    var tape: AKAudioFile?
    var shouldRecord = false
    var isRecording = false {
        didSet {
            if isRecording {
                try? recorder?.record()
                return
            }
            
            recorder?.stop()
        }
    }
    var isPlaying = false {
        didSet {
            guard isPlaying else {
                AudioEngine.shared.sequencer.stop()
                player?.stop()
                updateTapePlayer()
                
                if shouldRecord {
                    isRecording = false
                }
                delegate?.didUpdateIsPlaying(isPlaying)
                return
            }
            
            player?.play()
            AudioEngine.shared.sequencer.play()
            if shouldRecord {
                isRecording = true
            }
            delegate?.didUpdateIsPlaying(isPlaying)

        }
    }
    var trackTimeRatio: Double {
        get {
            guard let p = player else { return 0 }
            guard p.endTime > 0 else { return 0 }
            let ratio = p.currentTime / p.endTime
            if isRecording && ratio > 1 { return 1 }
            if ratio > 1 { return ratio.truncatingRemainder(dividingBy: floor(ratio)) }
            return ratio
        }
    }
    private let mixer = AKMixer()
    private let instrumentMixer = AKMixer()
    
    override init() {
        super.init()
        
        // Set up sequencer routing
        sequencer.setupTracks(instrument: drums)
        
        // Audio settings
        AKSettings.audioInputEnabled = true
        AKSettings.defaultToSpeaker = true
        let audioSession = AVAudioSession.sharedInstance()
        _ = try? audioSession.setActive(true)
        _ = try? AKSettings.setSession(category: .playAndRecord, with: .mixWithOthers)
        
        // TODO Global effects?
        [drums.mixer, keyboard.mixer, microphone.mixer] >>> instrumentMixer
        
        // Set up recorder and player
        recorder = try? AKNodeRecorder(node: mixer)
        if let file = recorder?.audioFile {
            player = try? AKAudioPlayer(file: file)
            player?.looping = true
        }
        
        [instrumentMixer, AKMixer(player)] >>> mixer
        AudioKit.output = mixer

        // Initial Values
        microphone.volume = 0.0
        keyboard.delayFX = 0
        try? AudioKit.start()
        
        // Enabled after starting audio kit
        drums.setupSamplers()
    }
    
    func toggleIsPlaying() {
        if isPlaying {
            isPlaying = false
        } else {
            isPlaying = true
        }
    }
    
    func updateTapePlayer() {
        tape = recorder?.audioFile
        guard let t = tape else { return }
        try? player?.replace(file: t)
        player?.looping = true
    }
    
}
