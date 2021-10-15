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

struct ContentView: View {
    
    @StateObject var shazamClient = ShazamClient()
    @StateObject var audioInputMonitor = AudioInputMonitor(numberOfSamples: numberOfSamples)
    
    @State var isRecording = false
    @State var songInfoViewIsPresented = false
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2
        return CGFloat(level * (300 / 25))
    }

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Button {
                    lyricizeButtonTapped()
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
                        ForEach(audioInputMonitor.soundSamples, id: \.id) { level in
                            BarView(value: self.normalizeSoundLevel(level: level))
                        }
                    }
                } else if shazamClient.shazamMedia.title != "" {
                    SongInfoView(shazamClient: shazamClient)
                } else {
                    Text("Tap the Lyricize button to start detecting your song!")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onChange(of: shazamClient.isRecording) { _ in
            isRecording.toggle()
        }
        .alertProvider()
    }
    
    func lyricizeButtonTapped() {
        shazamClient.shazamMedia = ShazamMedia(title: "", artistName: "", albumArtURL: URL(string: ""))
        shazamClient.songLyrics.lyrics = ""
        shazamClient.startListeningSession()
    }
}

extension Float {
    var id: UUID {
        return UUID()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
  
