//
//  ShazamClient.swift
//  Lyricize
//
//  Created by Samuel McGarry on 2021. 10. 9..
//

import ShazamKit

struct ShazamMedia: Decodable {
    let title: String?
    let subtitle: String?
    let artistName: String?
    let albumArtURL: URL?
    let genres: [String]
}

class ShazamClient: NSObject, ObservableObject {
    @Published var shazamMedia =  ShazamMedia(title: "",
                                              subtitle: "",
                                              artistName: "",
                                              albumArtURL: URL(string: "https://google.com"),
                                              genres: [""])
    @Published var isRecording = false
    @Published var songLyrics = SongLyrics(lyrics: "")
    
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
                print("START RECORDING SESSION")
            } catch (let error) {
                assertionFailure(error.localizedDescription)
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
        
        print("FOUND MATCH")
        
        stopListeningSession()
        
        let mediaItems = match.mediaItems
        
        if let firstItem = mediaItems.first {
            let _shazamMedia = ShazamMedia(title: firstItem.title,
                                           subtitle: firstItem.subtitle,
                                           artistName: firstItem.artist,
                                           albumArtURL: firstItem.artworkURL,
                                           genres: firstItem.genres)
            
            NetworkClient.shared.getLyrics(songTitle: firstItem.title!, artistName: firstItem.artist!) { [self] result in
                switch result {
                case .success(let lyrics):
                    DispatchQueue.main.async {
                        self.songLyrics = lyrics
                    }
                    print("Success")
                    print(lyrics)
                    
                case .failure(let error):
                    print(error)
                }
                
                DispatchQueue.main.async {
                    self.shazamMedia = _shazamMedia
                }
            }
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("DID NOT FIND MATCH")
    }
}
