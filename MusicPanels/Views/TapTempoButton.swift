//
//  TapTempoButton.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/7/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

class TapTempoButton: UIView {
    private var primaryView: UIView!
    private var secondaryView: UIView!
    private var topOffsetConstraint: NSLayoutConstraint!
    private var lastTapTempoTime: TimeInterval!
    private var tapTempoTimes = [TimeInterval]()
    var currentTempo: Double = AudioEngine.shared.sequencer.tempo {
        didSet {
            AudioEngine.shared.sequencer.setTempo(currentTempo)
            updateTempoMeter()
        }
    }
    var cornerRadius: CGFloat = 10.0 {
        didSet {
            primaryView.layer.cornerRadius = cornerRadius
            secondaryView.layer.cornerRadius = cornerRadius
        }
    }
    var primaryColor: UIColor = .tapTempo {
        didSet {
            primaryView.backgroundColor = primaryColor
            
        }
    }
    var secondaryColor: UIColor = .tapTempoSelected {
        didSet {
            secondaryView.backgroundColor = secondaryColor
        }
    }
    var borderColor: UIColor = .tapTempoSelected {
        didSet {
            primaryView.layer.borderColor = borderColor.cgColor
        }
    }
    var borderWidth: CGFloat = 2.0 {
        didSet {
            primaryView.layer.borderWidth = borderWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTempoMeter()
    }
    
    func commonInit() {
        primaryView = self
        secondaryView = UIView(frame: .zero)
        addSubview(secondaryView)
        translatesAutoresizingMaskIntoConstraints = false
        secondaryView.translatesAutoresizingMaskIntoConstraints = false
        topOffsetConstraint = secondaryView.topAnchor.constraint(equalTo: primaryView.topAnchor)
        NSLayoutConstraint.activate([
            secondaryView.leftAnchor.constraint(equalTo: primaryView.leftAnchor),
            secondaryView.rightAnchor.constraint(equalTo: primaryView.rightAnchor),
            secondaryView.bottomAnchor.constraint(equalTo: primaryView.bottomAnchor),
            topOffsetConstraint
            ])
        // todo update these recognizers
        // and add layoutSubviews for updating the constraints on tempo
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didSlide(sender:)))
        secondaryView.addGestureRecognizer(recognizer)
        primaryView.addGestureRecognizer(recognizer)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        secondaryView.addGestureRecognizer(tapRecognizer)
        primaryView.addGestureRecognizer(tapRecognizer)
        updateUI()
        
        lastTapTempoTime = Date.timeIntervalSinceReferenceDate
    }
    
    func updateUI() {
        primaryView.layer.borderWidth = borderWidth
        primaryView.layer.borderColor = borderColor.cgColor
        primaryView.backgroundColor = primaryColor
        secondaryView.backgroundColor = secondaryColor
        primaryView.layer.cornerRadius = cornerRadius
        secondaryView.layer.cornerRadius = cornerRadius
    }
    
    func updateTempoMeter() {
        let ratio = currentTempo / Sequencer.maxTempo
        topOffsetConstraint.constant = CGFloat(ratio) * frame.height
    }
    
    @objc func didTap(sender: UITapGestureRecognizer) {
        // Determine if tapping is quick enough for tap tempo
        let timeDifference = Date.timeIntervalSinceReferenceDate - lastTapTempoTime
        if timeDifference < 60.0 / Sequencer.minTempo {
            tapTempoTimes.append(timeDifference)
            // Average is beats / second so convert to beats / minute
            currentTempo = 1 / tapTempoTimes.average() * 60
            updateTempoMeter()
        } else {
            tapTempoTimes.removeAll()
        }
        
        // Update last tap tempo time
        lastTapTempoTime = Date.timeIntervalSinceReferenceDate
    }
    
    @objc func didSlide(sender: UIPanGestureRecognizer) {
        let yLocation = sender.location(in: self).y
        topOffsetConstraint.constant = yLocation
        let ratio = yLocation / frame.height
        currentTempo = Double(ratio) * (Sequencer.maxTempo - Sequencer.minTempo) + Sequencer.minTempo
        updateTempoMeter()
    }
}
