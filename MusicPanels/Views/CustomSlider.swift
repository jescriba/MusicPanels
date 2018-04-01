//
//  CustomSlider.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/6/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

protocol CustomSliderDelegate {
    func didChangeValue(_ value: Double, tag: Int)
}

class CustomSlider: UIView {
    var delegate: CustomSliderDelegate?
    private var primaryView: UIView!
    private var secondaryView: UIView!
    private var offsetConstraint: NSLayoutConstraint!
    var maxValue: Double = 1
    var minValue: Double = 0
    var range: Double {
        get {
            return maxValue - minValue
        }
    }
    var value: Double = 0 {
        didSet {
            offset = bounds.width * CGFloat(1.0 - value / range)
        }
    }
    private var offset: CGFloat = 20.0 {
        didSet {
            offsetConstraint.constant = -1 * offset
        }
    }
    var cornerRadius: CGFloat = 10.0 {
        didSet {
            primaryView.layer.cornerRadius = cornerRadius
            secondaryView.layer.cornerRadius = cornerRadius
        }
    }
    var primaryColor: UIColor = .red {
        didSet {
            primaryView.backgroundColor = primaryColor
        }
    }
    var secondaryColor: UIColor = .blue {
        didSet {
            secondaryView.backgroundColor = secondaryColor
        }
    }
    var borderColor: UIColor = .black {
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
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        value = { self.value }()
    }
    
    func commonInit() {
        primaryView = self
        secondaryView = UIView(frame: .zero)
        addSubview(secondaryView)
        translatesAutoresizingMaskIntoConstraints = false
        secondaryView.translatesAutoresizingMaskIntoConstraints = false
        offsetConstraint = secondaryView.rightAnchor.constraint(equalTo: primaryView.rightAnchor, constant: -1 * offset)
        NSLayoutConstraint.activate([
            secondaryView.leftAnchor.constraint(equalTo: primaryView.leftAnchor),
            offsetConstraint,
            secondaryView.topAnchor.constraint(equalTo: primaryView.topAnchor),
            secondaryView.bottomAnchor.constraint(equalTo: primaryView.bottomAnchor)
            ])
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanOnSecondaryView(sender:)))
        secondaryView.addGestureRecognizer(recognizer)
        primaryView.addGestureRecognizer(recognizer)
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
    
    @objc func didPanOnSecondaryView(sender: UIPanGestureRecognizer) {
        let translation = primaryView.bounds.width - sender.location(in: primaryView).x
        if abs(translation) < primaryView.bounds.width {
            value = (1.0 - Double(abs(translation) / bounds.width)) * range
        }

        delegate?.didChangeValue(Double(secondaryView.frame.width / primaryView.frame.width) * range, tag: self.tag)
    }
}
