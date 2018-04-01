//
//  ToggleButton.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/6/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

protocol ToggleButtonDelegate {
    func didChangeValue(_ isOn: Bool)
    func didTap(sender: UITapGestureRecognizer)
}

class RecordToggleButton: UIView {
    var delegate: ToggleButtonDelegate?
    private var primaryView: UIView!
    private var secondaryView: UIView!
    private var topOffsetConstraint: NSLayoutConstraint!
    var isOn: Bool = false {
        didSet {
            updateIsOnConstraints()
            delegate?.didChangeValue(isOn)
        }
    }
    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                primaryView.backgroundColor = .playOn
            } else {
                primaryView.backgroundColor = .playOff
            }
        }
    }
    var cornerRadius: CGFloat = 10.0 {
        didSet {
            primaryView.layer.cornerRadius = cornerRadius
            secondaryView.layer.cornerRadius = cornerRadius
        }
    }
    var primaryColor: UIColor = .playOff {
        didSet {
            primaryView.backgroundColor = primaryColor
            
        }
    }
    var secondaryColor: UIColor = .playOn {
        didSet {
            secondaryView.backgroundColor = secondaryColor
        }
    }
    var borderColor: UIColor = .playOn {
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
        updateIsOnConstraints()
    }
    
    func commonInit() {
        primaryView = self
        secondaryView = UIView(frame: .zero)
        addSubview(secondaryView)
        translatesAutoresizingMaskIntoConstraints = false
        secondaryView.translatesAutoresizingMaskIntoConstraints = false
        topOffsetConstraint = secondaryView.topAnchor.constraint(equalTo: primaryView.topAnchor, constant: 0)
        NSLayoutConstraint.activate([
            secondaryView.leftAnchor.constraint(equalTo: primaryView.leftAnchor),
            secondaryView.rightAnchor.constraint(equalTo: primaryView.rightAnchor),
            secondaryView.heightAnchor.constraint(equalTo: primaryView.heightAnchor, multiplier: 0.5),
            topOffsetConstraint
            ])
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanOnSecondaryView(sender:)))
        secondaryView.addGestureRecognizer(recognizer)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        secondaryView.addGestureRecognizer(tapRecognizer)
        primaryView.addGestureRecognizer(tapRecognizer)
        isOn = false
        updateUI()
    }
    
    func updateUI() {
        primaryView.layer.borderWidth = borderWidth
        primaryView.layer.borderColor = borderColor.cgColor
        primaryView.backgroundColor = primaryColor
        secondaryView.backgroundColor = secondaryColor
        primaryView.layer.cornerRadius = cornerRadius
        secondaryView.layer.cornerRadius = cornerRadius
    }
    
    func updateIsOnConstraints() {
        if isOn {
            topOffsetConstraint.constant = 0
        } else {
            topOffsetConstraint.constant = bounds.height * 0.5
        }
    }
    
    @objc func didPanOnSecondaryView(sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: primaryView).y
        if velocity < 0 {
            isOn = true
        } else {
            isOn = false
        }
    }
    
    @objc func didTap(sender: UITapGestureRecognizer) {
        delegate?.didTap(sender: sender)
        if isPlaying {
            isPlaying = false
        } else {
            isPlaying = true
        }
    }
}
