//
//  ContentView.swift
//  Shared
//
//  Created by Samuel McGarry on 2021. 10. 9..
//

import SwiftUI
import CoreData
import ShazamKit

let numberOfSamples = 20
struct BarView: View {
    var value: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.blue)
                .frame(width: 5, height: value)
        }
    }
}

struct SongInfoView: View {
    @ObservedObject var shazamClient: ShazamClient
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    AsyncImage(url: shazamClient.shazamMedia.albumArtURL) { image in
                                image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.width * 0.85, alignment: .center)
                                .cornerRadius(10)
                        } placeholder: {
                            Image(systemName: "heart.text.square")
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.width * 0.85, alignment: .center)
                            .opacity(0)
                        }
                    Text(shazamClient.shazamMedia.title ?? "")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .font(.title)
                        .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                        .padding(.top, 5)
                    Text(shazamClient.shazamMedia.artistName ?? "")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
                if shazamClient.songLyrics.lyrics != "" {
                    VStack {
                        Text(shazamClient.songLyrics.lyrics)
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(width: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                    }
                    .padding()
                    .background(
                        Color.blue
                            .opacity(0.2)
                    )
                    .cornerRadius(10)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, alignment: .center)
    }
}

struct ContentView: View {
    
    @StateObject var shazamClient = ShazamClient()
    @StateObject var mic = AudioInputMonitor(numberOfSamples: numberOfSamples)
    
    @State var isRecording = false
    @State var songInfoViewIsPresented = false
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
            let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
            
            return CGFloat(level * (300 / 25)) // scaled to max at 300 (our height of our bar)
        }

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Button {
                    shazamClient.shazamMedia = ShazamMedia(title: "",
                                                           subtitle: "",
                                                           artistName: "",
                                                           albumArtURL: URL(string: "https://google.com"),
                                                           genres: [""])
                    shazamClient.songLyrics.lyrics = ""
                    shazamClient.startListeningSession()
                } label: {
                    Text(shazamClient.isRecording ? "Lyricizing..." : "Lyricize")
                        .font(.headline)
                }
                .tint(.green)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 10))
                .controlSize(.large)
                .padding()
            }.zIndex(1)
            VStack {
                if isRecording {
                    HStack(spacing: 10) {
                        ForEach(mic.soundSamples, id: \.self) { level in
                            BarView(value: self.normalizeSoundLevel(level: level))
                        }
                    }
                }
                if shazamClient.shazamMedia.title != "" {
                    SongInfoView(shazamClient: shazamClient)
                }
            }
        }
        .onChange(of: shazamClient.isRecording) { _ in
            isRecording.toggle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
  
