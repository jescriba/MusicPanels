//
//  CatalogManager.swift
//  MusicPanes
//
//  Created by Joshua Escribano on 2/25/18.
//  Copyright © 2018 Joshua Escribano. All rights reserved.
//

import Foundation
import AudioKit

protocol CatalogManagerDelegate {
    func didExport(song: Song, filePath: String)
}

class CatalogManager: NSObject {
    static var delegate: CatalogManagerDelegate?
    
    private static var baseURL: URL? {
        get {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        }
    }
    
    private static var _orderedSongs = [Song]()
    static var orderedSongs: [Song] {
        get {
            if _orderedSongs.count == 0 {
                _orderedSongs = songs
                return _orderedSongs
            }
            return _orderedSongs
        } set {
            _orderedSongs = newValue
        }
    }
    
    static var songs: [Song] {
        get {
            return loadSongsFromDisk()
        }
    }
    
    private static func loadSongsFromDisk() -> [Song] {
        var songs = [Song]()
        guard let baseURL = baseURL,
            let contents = try? FileManager.default.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return [newSong()] }
        
        let urls = contents.filter { $0.pathExtension == "json" }
        for url in urls {
            guard let data = try? Data(contentsOf: url) else { continue }
            guard let song = try? JSONDecoder().decode(Song.self, from: data) else { continue }
            songs.append(song)
        }
        guard songs.count == 0 else { return songs }

        // If no songs create a song
        return [newSong()]
    }
    
    static func newSong(name: String? = nil) -> Song {
        try? AudioEngine.shared.recorder?.reset()
        AudioEngine.shared.updateTapePlayer()
        
        guard _orderedSongs.count > 0 else {
            return Song(name: String.currentDate())
        }
        
        let possibleName = String.currentDate()
        if orderedSongs.contains(where: { $0.name == possibleName }) {
            // create guid
            let s = Song(name: "\(possibleName) \(UUID().uuidString.prefix(8))")
            orderedSongs.insert(s, at: 0)
            return s
        } else {
            let s = Song(name: possibleName)
            orderedSongs.insert(s, at: 0)
            return s
        }
    }
    
    static func exportSong(_ song: Song) {
        guard let fileName = song.fileName, let filePath = baseURL?.appendingPathComponent("\(fileName).aif") else { return }
        
        delegate?.didExport(song: song, filePath: filePath.path)
    }
    
    static func saveSong(_ song: Song) {
        let fileName = song.name.fileSafeName()
        song.fileName = "\(fileName)"
        let songData = try? JSONEncoder().encode(song)
        guard let s = songData, let u = baseURL else { return }
        
        _ = try? s.write(to: u.appendingPathComponent("\(fileName).json"))
        AudioEngine.shared.tape?.exportAsynchronously(name: fileName, baseDir: .documents, exportFormat: .aif, callback: {_,_ in })
    }
    
    static func loadSong(_ song: Song) {
        // Load file from storage
        guard let fileName = song.fileName, let filePath = baseURL?.appendingPathComponent("\(fileName).aif") else { return }
        guard let tape = try? AKAudioFile(forReading: filePath) else { return }
        
        // Update audio file
        AudioEngine.shared.tape = tape
        try? AudioEngine.shared.player?.replace(file: tape)
        
        // Reorder loaded song to top of ordered list
        guard let firstSong = orderedSongs.first, let currentSongIndex = orderedSongs.index(of: song) else {
            return
        }

        orderedSongs[0] = song
        orderedSongs[currentSongIndex] = firstSong
    }
    
    static func deleteSong(_ song: Song) {
        guard let index = orderedSongs.index(of: song) else { return }
        orderedSongs.remove(at: index)
        
        guard let fileName = song.fileName,
            let filePath = baseURL?.appendingPathComponent("\(fileName).json"),
            let songFilePath = baseURL?.appendingPathComponent("\(fileName).aif") else { return }
        
        try? FileManager.default.removeItem(at: filePath)
        try? FileManager.default.removeItem(at: songFilePath)
    }
}
