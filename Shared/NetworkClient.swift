//
//  NetworkClient.swift
//  Lyricize
//
//  Created by Samuel McGarry on 2021. 10. 9..
//

import Foundation
import SwiftUI

struct SongLyrics: Codable {
    var lyrics: String
}

enum NetworkError: Error {
    case genericError
    case invalidData
    case invalidResponse
    case decodingError(String)
}

class NetworkClient {
    static let shared = NetworkClient()
    
    private init() { }
    
    func getLyrics(songTitle: String, artistName: String, completed: @escaping  (Result<SongLyrics, NetworkError>) -> Void) {
        
        let safeArtistName = artistName.getURLSafeString()
        let safeSongTitle = songTitle.getURLSafeString()
        
        let urlString = "https://api.lyrics.ovh/v1/\(safeArtistName)/\(safeSongTitle)"
        
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                print(data)
                let songLyrics = try decoder.decode(SongLyrics.self, from: data)
                completed(.success(songLyrics))
                
            } catch {
                completed(.failure(.decodingError(error.localizedDescription)))
            }
        }
        
        task.resume()
    }
}

extension String {
    func getURLSafeString() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
