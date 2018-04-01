//
//  MasterMixerView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/7/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

class MasterMixerView: UIView {
    @IBOutlet weak var mixerImageView: UIImageView!
    @IBOutlet weak var keysSlider: CustomSlider!
    @IBOutlet weak var keysImageView: UIImageView!
    @IBOutlet weak var micImageView: UIImageView!
    @IBOutlet weak var micSlider: CustomSlider!
    @IBOutlet weak var drumImageView: UIImageView!
    @IBOutlet weak var drumSlider: CustomSlider!
    @IBOutlet weak var tapTempoButton: TapTempoButton!
    @IBOutlet weak var recordButton: RecordToggleButton!
    
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
        
        keysSlider.secondaryColor = .pastelBlue
        keysSlider.borderColor = .pastelBlue
        keysSlider.primaryColor = .black
        keysSlider.delegate = self
        keysSlider.tag = FX.keyVolume.rawValue
        keysImageView.tintColor = .pastelBlue
        mixerImageView.tintColor = .pastelBlue
        micSlider.secondaryColor = .pastelYellow
        micSlider.borderColor = .pastelYellow
        micSlider.primaryColor = .black
        micSlider.delegate = self
        micSlider.tag = FX.micVolume.rawValue
        micImageView.tintColor = .pastelYellow
        drumSlider.secondaryColor = .pastelOrange
        drumSlider.borderColor = .pastelOrange
        drumSlider.primaryColor = .black
        drumSlider.delegate = self
        drumSlider.tag = FX.drumVolume.rawValue
        drumImageView.tintColor = .pastelOrange
        
        recordButton.delegate = self
        updateAudioUI()
    }
    
    func updateAudioUI() {
        // Initialize UI-audio binding
        keysSlider.value = AudioEngine.shared.keyboard.mixer.volume
        // + 0.01 hack to get slider ui working in autolayout with imageview
        micSlider.value = AudioEngine.shared.microphone.mixer.volume + 0.01
        drumSlider.value = AudioEngine.shared.drums.mixer.volume
        recordButton.isPlaying = AudioEngine.shared.isPlaying
        recordButton.isOn = AudioEngine.shared.shouldRecord
        tapTempoButton.currentTempo = AudioEngine.shared.sequencer.tempo
    }
}

extension MasterMixerView: CarouselViewDelegate {
    func willPresentView() {
        updateAudioUI()
    }
}

extension MasterMixerView: CustomSliderDelegate {
    func didChangeValue(_ value: Double, tag: Int) {
        let fx = FX(rawValue: tag)!
        switch fx {
        case .micVolume:
            AudioEngine.shared.microphone.mixer.volume = value
        case .drumVolume:
            AudioEngine.shared.drums.mixer.volume = value
        case .keyVolume:
            AudioEngine.shared.keyboard.mixer.volume = value
        default:
            break
        }
    }
}

extension MasterMixerView: ToggleButtonDelegate {
    func didChangeValue(_ isOn: Bool) {
        AudioEngine.shared.shouldRecord = isOn
    }
    
    func didTap(sender: UITapGestureRecognizer) {
        AudioEngine.shared.toggleIsPlaying()
    }
}
