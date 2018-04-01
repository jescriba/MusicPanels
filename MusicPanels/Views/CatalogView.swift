//
//  CatalogView.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/2/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

protocol CatalogViewDelegate {
    func didExport(song: Song)
}

class CatalogView: UIView {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var catalogTableView: UITableView!
    
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
        
        catalogTableView.backgroundColor = .black
        catalogTableView.tableFooterView = UIView()
        catalogTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CatalogTableViewCell")
        catalogTableView.dataSource = self
        catalogTableView.delegate = self
        catalogTableView.separatorColor = .pastelRed
        saveButton.tintColor = .pastelBlue
        exportButton.tintColor = .pastelBlue
        newButton.setTitleColor(.pastelBlue, for: .normal)
    }
    
    @IBAction func didTapNew(_ sender: Any) {
        let s = CatalogManager.newSong()
        CatalogManager.loadSong(s)
        catalogTableView.reloadData()
    }
    
    @IBAction func didSave(_ sender: Any) {
        guard let s = CatalogManager.orderedSongs.first else { return }
        CatalogManager.saveSong(s)
    }
    
    @IBAction func didExport(_ sender: Any) {
        guard let s = CatalogManager.orderedSongs.first else { return }
        CatalogManager.exportSong(s)
    }
    
}

extension CatalogView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CatalogManager.orderedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogTableViewCell", for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 23.0)!
        cell.textLabel?.text = CatalogManager.orderedSongs[indexPath.row].name
        cell.textLabel?.textColor = .pastelRed
        cell.backgroundColor = .black
        return cell
    }
}

extension CatalogView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let firstIndexPath = IndexPath(row: 0, section: 0)
        tableView.moveRow(at: indexPath, to: firstIndexPath)
        let s = CatalogManager.orderedSongs[indexPath.row]
        CatalogManager.loadSong(s)
        tableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
        tableView.deselectRow(at: firstIndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // If current song reset
            if indexPath.row == 0 {
                try? AudioEngine.shared.recorder?.reset()
                AudioEngine.shared.updateTapePlayer()
            } else {
                let s = CatalogManager.orderedSongs[indexPath.row]
                CatalogManager.deleteSong(s)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
