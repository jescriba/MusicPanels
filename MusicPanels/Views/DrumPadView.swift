//
//  DrumPadView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/8/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

class DrumPadView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update CollectionViewCell ItemSize if the Pane changes
    collectionView.collectionViewLayout.invalidateLayout()
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
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DrumPad")
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.layer.cornerRadius = 5
        collectionView.backgroundColor = .black
    }
    
    @objc func didTapOnCell(sender: UILongPressGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        guard let type = SequenceType(rawValue: tag) else { return }
        
        switch sender.state {
        case .began:
            sender.view?.backgroundColor = .pastelPurple
            AudioEngine.shared.drums.play(type: type)
        case .ended, .cancelled:
            sender.view?.backgroundColor = .lightPurple
        default:
            break
        }
    }
}

extension DrumPadView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didTapOnCell(sender:)))
        recognizer.minimumPressDuration = 0
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrumPad", for: indexPath)
        cell.tag = indexPath.row
        cell.backgroundColor = .lightPurple
        cell.layer.cornerRadius = 15
        cell.addGestureRecognizer(recognizer)
        return cell
    }
    
}

extension DrumPadView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / CGFloat(4) - 8.0
        let height = collectionView.frame.height - 2.0
        return CGSize(width: width, height: height)
    }
}
