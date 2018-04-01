//
//  KeyboardFXView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/7/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

enum FX: Int {
    case vibratoDepth
    case vibratoRate
    case tremoloDepth
    case tremoloRate
    case delay
    case reverb
    case micVolume
    case keyVolume
    case drumVolume
    
    static let vibratoDepthMax: Double = 5
    static let vibratoDepthMin: Double = 0
    static let vibratoRateMax: Double = 60
    static let vibratoRateMin: Double = 0
    static let reverbMax: Double = 1
    static let reverbMin: Double = 0
    static let delayMax: Double = 0.8
    static let delayMin: Double = 0
    static let tremoloDepthMax: Double = 1
    static let tremoloDepthMin: Double = 0
    static let tremoloRateMax: Double = 120
    static let tremoloRateMin: Double = 0
    static let volumeMax: Double = 1
    static let volumeMin: Double = 0
}

class KeyboardFXView: UIView {
    @IBOutlet weak var recordToggleButton: RecordToggleButton!
    @IBOutlet weak var tapTempoButton: TapTempoButton!
    @IBOutlet weak var vibratoDepthSlider: CustomSlider!
    @IBOutlet weak var vibratoRateSlider: CustomSlider!
    @IBOutlet weak var tremoloDepthSlider: CustomSlider!
    @IBOutlet weak var tremoloRateSlider: CustomSlider!
    @IBOutlet weak var delaySlider: CustomSlider!
    @IBOutlet weak var reverbSlider: CustomSlider!
    
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
        
        tremoloDepthSlider.secondaryColor = .pastelBlue
        tremoloDepthSlider.borderColor = .pastelBlue
        tremoloDepthSlider.primaryColor = .black
        tremoloRateSlider.secondaryColor = .pastelOrange
        tremoloRateSlider.borderColor = .pastelOrange
        tremoloRateSlider.primaryColor = .black
        vibratoDepthSlider.secondaryColor = .pastelPurple
        vibratoDepthSlider.borderColor = .pastelPurple
        vibratoDepthSlider.primaryColor = .black
        vibratoRateSlider.secondaryColor = .pastelYellow
        vibratoRateSlider.borderColor = .pastelYellow
        vibratoRateSlider.primaryColor = .black
        reverbSlider.secondaryColor = .pastelRed
        reverbSlider.borderColor = .pastelRed
        reverbSlider.primaryColor = .black
        delaySlider.secondaryColor = .pastelGreen
        delaySlider.borderColor = .pastelGreen
        delaySlider.primaryColor = .black
        
        vibratoRateSlider.maxValue = FX.vibratoRateMax
        vibratoRateSlider.minValue = FX.vibratoRateMin
        vibratoDepthSlider.maxValue = FX.vibratoDepthMax
        vibratoDepthSlider.minValue = FX.vibratoDepthMin
        vibratoRateSlider.delegate = self
        vibratoDepthSlider.delegate = self
        vibratoDepthSlider.tag = FX.vibratoDepth.rawValue
        vibratoRateSlider.tag = FX.vibratoRate.rawValue
        
        reverbSlider.maxValue = FX.reverbMax
        reverbSlider.minValue = FX.reverbMin
        reverbSlider.delegate = self
        reverbSlider.tag = FX.reverb.rawValue
        
        delaySlider.maxValue = FX.delayMax
        delaySlider.minValue = FX.delayMin
        delaySlider.delegate = self
        delaySlider.tag = FX.delay.rawValue
        
        tremoloRateSlider.maxValue = FX.tremoloRateMax
        tremoloRateSlider.minValue = FX.tremoloRateMin
        tremoloRateSlider.delegate = self
        tremoloRateSlider.tag = FX.tremoloRate.rawValue
            
        tremoloDepthSlider.maxValue = FX.tremoloDepthMax
        tremoloDepthSlider.minValue = FX.tremoloDepthMin
        tremoloDepthSlider.delegate = self
        tremoloDepthSlider.tag = FX.tremoloDepth.rawValue
        
        recordToggleButton.delegate = self
        updateAudioUI()
    }
    
    func updateAudioUI() {
        recordToggleButton.isOn = AudioEngine.shared.shouldRecord
        recordToggleButton.isPlaying = AudioEngine.shared.isPlaying
        tapTempoButton.currentTempo = AudioEngine.shared.sequencer.tempo
    }
}

extension KeyboardFXView: CarouselViewDelegate {
    func willPresentView() {
        updateAudioUI()
    }
}

extension KeyboardFXView: CustomSliderDelegate {
    func didChangeValue(_ value: Double, tag: Int) {
        let fx = FX(rawValue: tag)!
        switch fx {
        case .vibratoDepth:
            AudioEngine.shared.keyboard.vibratoDepth = value
        case .vibratoRate:
            AudioEngine.shared.keyboard.vibratoRate = value
        case .reverb:
            AudioEngine.shared.keyboard.reverbDepth = value
        case .delay:
            AudioEngine.shared.keyboard.delayFX = value
        case .tremoloDepth:
            AudioEngine.shared.keyboard.tremoloDepth = value
        case .tremoloRate:
            AudioEngine.shared.keyboard.tremoloRate = value
        default:
            break
        }
    }
}

extension KeyboardFXView: ToggleButtonDelegate {
    func didChangeValue(_ isOn: Bool) {
        AudioEngine.shared.shouldRecord = isOn
    }
    
    func didTap(sender: UITapGestureRecognizer) {
        AudioEngine.shared.toggleIsPlaying()
    }
}
