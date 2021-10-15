//
//  SongInfoView.swift
//  Lyricize
//
//  Created by Samuel McGarry on 2021. 10. 15..
//

import SwiftUI

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
