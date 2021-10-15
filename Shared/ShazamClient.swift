//
//  ShazamClient.swift
//  Lyricize
//
//  Created by Samuel McGarry on 2021. 10. 9..
//

import ShazamKit

struct ShazamMedia: Decodable {
    let title: String?
    let artistName: String?
    let albumArtURL: URL?
}

class ShazamClient: NSObject, ObservableObject {
    @Published var shazamMedia =  ShazamMedia(title: "",
                                              artistName: "",
                                              albumArtURL: URL(string: ""))
    @Published var isRecording = false
    @Published var songLyrics = SongLyrics(lyrics: "No lyrics found for this song.")
    
    private let audioEngine = AVAudioEngine()
    private let session = SHSession()
    private let signatureGenerator = SHSignatureGenerator()
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    func startListeningSession() {
        guard !audioEngine.isRunning else {
            stopListeningSession()
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { [self] granted in
            guard granted else { return }
            try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = self.audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0,
                                     bufferSize: 1024,
                                     format: recordingFormat) { (buffer: AVAudioPCMBuffer,
                                                                 when: AVAudioTime) in
                    self.session.matchStreamingBuffer(buffer, at: nil)
            }
            self.audioEngine.prepare()
            do {
                try self.audioEngine.start()
            } catch {
                AlertProvider.shared.showAlertWithTitle(message: "Unable to start audio engine.", title: "Audio Engine Error.", dismissButtonText: "Ok")
            }
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }
    
    func stopListeningSession() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: .zero)
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}

extension ShazamClient: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
    
        stopListeningSession()
        
        let mediaItems = match.mediaItems
        
        if let firstItem = mediaItems.first {
            let _shazamMedia = ShazamMedia(title: firstItem.title,
                                           artistName: firstItem.artist,
                                           albumArtURL: firstItem.artworkURL)
            
            DispatchQueue.main.async {
                self.shazamMedia = _shazamMedia
            }
            
            NetworkClient.shared.getLyrics(songTitle: firstItem.title!, artistName: firstItem.artist!) { [self] result in
                switch result {
                case .success(let lyrics):
                    DispatchQueue.main.async {
                        self.songLyrics = lyrics
                    }
                    
                case .failure:
                    DispatchQueue.main.async {
                        self.songLyrics = SongLyrics(lyrics: "No lyrics found for this song.")
                    }
                }
            }
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        
        stopListeningSession()
        
        AlertProvider.shared.showAlertWithTitle(message: "The audio engine was unable to find a match, your song may not be in the Shazam database. Please try again.", title: "No match found", dismissButtonText: "Ok")
    }
}
