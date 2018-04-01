//
//  ADSRView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 1/30/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit
import AudioKitUI

class ADSRView: UIView {
    @IBOutlet weak var akadsrView: AKADSRView!
    
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
        
        akadsrView.bgColor = .black
        akadsrView.attackColor = .pastelRed
        akadsrView.decayColor = .pastelYellow
        akadsrView.sustainColor = .pastelBlue
        akadsrView.releaseColor = .pastelGreen
        akadsrView.callback = { attack, decay, sustain, release in
            let bank = AudioEngine.shared.keyboard.bank
            bank.attackDuration = attack
            bank.decayDuration = decay
            bank.sustainLevel = sustain
            bank.releaseDuration = release
        }
        
    }
    
}
