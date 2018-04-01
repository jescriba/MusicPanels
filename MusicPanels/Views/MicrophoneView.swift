//
//  MicrophoneView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/2/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

class MicrophoneView: UIView {
    @IBOutlet weak var volumeSlider: CustomSlider!
    @IBOutlet weak var reverbSlider: CustomSlider!
    @IBOutlet weak var delaySlider: CustomSlider!
    @IBOutlet weak var micImageView: UIImageView!
    @IBOutlet weak var recordButton: RecordToggleButton!
    @IBOutlet weak var tapTempoButton: TapTempoButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        let view = loadXib()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        micImageView.tintColor = .pastelYellow
        volumeSlider.secondaryColor = .pastelYellow
        volumeSlider.borderColor = .pastelYellow
        volumeSlider.primaryColor = .black
        volumeSlider.delegate = self
        volumeSlider.tag = FX.micVolume.rawValue
        reverbSlider.secondaryColor = .pastelBlue
        reverbSlider.borderColor = .pastelBlue
        reverbSlider.primaryColor = .black
        reverbSlider.delegate = self
        reverbSlider.minValue = FX.reverbMin
        reverbSlider.maxValue = FX.reverbMax
        reverbSlider.tag = FX.reverb.rawValue
        delaySlider.secondaryColor = .pastelOrange
        delaySlider.borderColor = .pastelOrange
        delaySlider.primaryColor = .black
        delaySlider.delegate = self
        delaySlider.maxValue = FX.delayMax
        delaySlider.minValue = FX.delayMin
        delaySlider.tag = FX.delay.rawValue
        
        recordButton.delegate = self
        updateAudioUI()
    }
    
    func updateAudioUI() {
        recordButton.isOn = AudioEngine.shared.shouldRecord
        recordButton.isPlaying = AudioEngine.shared.isPlaying
        tapTempoButton.currentTempo = AudioEngine.shared.sequencer.tempo
    }
}

extension MicrophoneView: CarouselViewDelegate {
    func willPresentView() {
        updateAudioUI()
    }
}

extension MicrophoneView: ToggleButtonDelegate {
    func didChangeValue(_ isOn: Bool) {
        AudioEngine.shared.shouldRecord = isOn
    }
    
    func didTap(sender: UITapGestureRecognizer) {
        AudioEngine.shared.toggleIsPlaying()
    }
}

extension MicrophoneView: CustomSliderDelegate {
    func didChangeValue(_ value: Double, tag: Int) {
        let fx = FX(rawValue: tag)!
        switch fx {
        case .reverb:
            AudioEngine.shared.keyboard.reverbDepth = value
        case .delay:
            AudioEngine.shared.keyboard.delayFX = value
        case .micVolume:
            AudioEngine.shared.microphone.volume = value
        default:
            break
        }
    }
}

