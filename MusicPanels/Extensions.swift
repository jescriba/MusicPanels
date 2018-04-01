//
//  Extensions.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 12/22/17.
//  Copyright © 2017 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let keyOn = UIColor(red:0.41, green:0.50, blue:0.97, alpha:1.0)
    static let octaveBorder = UIColor(red:0.80, green:0.63, blue:0.80, alpha:1.0)
    static let octaveBorderSelected = UIColor(red:0.90, green:0.63, blue:0.80, alpha:1.0)
    static let sequencerCell = UIColor(red:1.00, green:0.58, blue:0.12, alpha:1.0)
    static let sequencerCellSelected = UIColor(red:1.00, green:0.43, blue:0.33, alpha:1.0)
    static let sequencerCellPartialSelected = UIColor(red:1.00, green:0.48, blue:0.33, alpha:1.0)
    static let sequencerCellBorder = UIColor(red:1.00, green:0.43, blue:0.13, alpha:1.0)
    static let paneBorder = UIColor(red:0.60, green:0.29, blue:0.60, alpha:1.0)
    static let paneBorderSelected = UIColor(red:0.70, green:0.29, blue:0.60, alpha:1.0)
    static let playOn = UIColor(red:1.00, green:0.39, blue:0.43, alpha:1.0)
    static let playOff = UIColor(red:0.8, green:0.39, blue:0.43, alpha:1.0)
    static let tapTempo = UIColor(red:0.40, green:0.78, blue:0.55, alpha:1.0)
    static let tapTempoSelected = UIColor(red:0.40, green:0.69, blue:0.55, alpha:1.0)
    static let pastelYellow = UIColor(red:1.00, green:1.00, blue:0.60, alpha:1.0)
    static let pastelOrange = UIColor(red:1.00, green:0.43, blue:0.13, alpha:1.0)
    static let pastelBlue =  UIColor(red:0.62, green:0.79, blue:0.93, alpha:1.0)
    static let pastelPurple = UIColor(red:0.78, green:0.72, blue:0.89, alpha:1.0)
    static let pastelRed = UIColor(red:1.00, green:0.41, blue:0.38, alpha:1.0)
    static let pastelGreen = UIColor(red:0.47, green:0.87, blue:0.47, alpha:1.0)
    static let lightPurple = UIColor(red:1.00, green:0.81, blue:0.91, alpha:1.0)

    func hexString() -> String {
        let colorRef = self.cgColor.components
        
        let r:CGFloat = colorRef![0]
        let g:CGFloat = colorRef![1]
        let b:CGFloat = colorRef![2]
        
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}

extension Collection where Iterator.Element == TimeInterval
{
    func average() -> TimeInterval {
        return self.reduce(0, +) / Double(self.count as! Int)
    }
}

extension Collection where Iterator.Element == SequenceEvent {
    func indexPathsFor(timeDivision: TimeDivision) -> [GenericIndexPath] {
        var indexPaths = [GenericIndexPath]()
        let stepSize = Double(timeDivision.numberOfSteps()) / 4.0
        for event in self {
            let possibleRow = event.position * stepSize
            // Check if integer
            if floor(possibleRow) == possibleRow {
                let indexPath = IndexPath(row: Int(possibleRow), section: event.sequenceType.rawValue)
                indexPaths.append(indexPath)
            } else {
                let indexPath = PartialIndexPath(row: possibleRow, section: event.sequenceType.rawValue)
                indexPaths.append(indexPath)
            }
        }
        
        return indexPaths
    }
}

extension UIView {
    func loadXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}

extension String {
    
    func fileSafeName() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    }
    
    static func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: Date())
    }
}
