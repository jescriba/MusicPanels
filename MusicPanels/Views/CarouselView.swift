//
//  CarouselView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/2/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

protocol CarouselViewDelegate {
    func willPresentView()
}

class CarouselView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    private var views = [UIView]()
    private var _viewStrings: String = ""
    @IBInspectable var viewStrings: String {
        get {
            return _viewStrings
        } set {
            _viewStrings = newValue
        }
    }
    @IBInspectable var startIndex: Int = 0 {
        didSet {
            currentIndex = startIndex
        }
    }
    var offset: CGFloat = 0 {
        didSet {
            scrollView.contentOffset = CGPoint(x: offset, y: 0)
        }
    }
    var currentIndex: Int = 1 {
        didSet {
            guard self.contentView != nil else { return }
            
            (views[currentIndex] as? CarouselViewDelegate)?.willPresentView()
            centerView()
        }
    }
    var paneScrollDelegates = [PaneScrollDelegate]()
    
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
    
    func commonInit() {
        let view = loadXib()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        for vString in viewStrings.components(separatedBy: ",") {
            let klass = NSClassFromString("MusicPanels.\(vString)") as! UIView.Type
            views.append(klass.init(frame: bounds))
        }
        contentViewWidthConstraint.constant = CGFloat(views.count) * bounds.width
        for (i, v) in views.enumerated() {
            contentView.addSubview(v)

            v.translatesAutoresizingMaskIntoConstraints = false
            v.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            v.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            if i == 0 {
                v.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            } else {
                v.leftAnchor.constraint(equalTo: views[i - 1].rightAnchor).isActive = true
            }
            
            // forward pane scrolling delegates
            if let delegate = v as? PaneScrollDelegate {
                paneScrollDelegates.append(delegate)
            }
        }
        
        centerView()
    }
    
    func didRightEdgePan(xLocation: CGFloat) {
        let tempOffset = CGFloat(currentIndex + 1) * scrollView.bounds.width - xLocation
        guard tempOffset <= CGFloat(views.count - 1) * scrollView.bounds.width else { return }
        offset = tempOffset
    }
    
    func didLeftEdgePan(xLocation: CGFloat) {
        let tempOffset = CGFloat(currentIndex) * scrollView.bounds.width - xLocation
        guard tempOffset >= 0 else { return }
        offset = tempOffset
    }
    
    func openRightView() {
        guard currentIndex < views.count - 1 else { return }
        currentIndex += 1
    }
    
    func closeRightView() {
        // Recenter at currentIndex
        centerView()
    }
    
    func openLeftView() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
    
    func closeLeftView() {
        // Recenter at currentIndex
        centerView()
    }
    
    func centerView() {
        UIView.animate(withDuration: 0.6, animations: {
            self.offset = CGFloat(self.currentIndex) * self.scrollView.bounds.width
        })
    }
    
}
