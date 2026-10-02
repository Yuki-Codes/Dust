//
//  PlayingGameView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct PlayingGameView: View {
    var game: Game
    var config: Configuration

    var heroLoaded: Bool = false
    var logoLoaded: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .topLeading) {
                if self.config.heroUrl != nil {
                    UrlImageView(url: self.config.heroUrl!, contentMode: .fill)
                        .frame(width: 800, height: 280)
                } else if self.game.defaultConfiguration().heroUrl != nil {
                    UrlImageView(url: self.game.defaultConfiguration().heroUrl!, contentMode: .fill)
                        .frame(width: 800, height: 280)
                }

                if self.config.logoUrl != nil {
                    UrlImageView(url: self.config.logoUrl!, contentMode: .fit)
                        .padding(16)
                        .frame(width: 250, height: 250, alignment: .topLeading)
                        .shadow(color: Color.black, radius: 12)
                } else {
                    Text(self.config.title)
                        .font(.title)
                        .padding(16)
                        .frame(width: 250, height: 250, alignment: .topLeading)
                        .shadow(color: Color.black, radius: 12)
                }
            }

            HStack {
                Text("Now Playing")
                ProgressView()
                    .scaleEffect(0.5)
                    .shadow(color: Color.black, radius: 3)
            }
            .shadow(color: Color.black, radius: 12)
            .shadow(color: Color.black, radius: 6)
            .padding(16)
        }
    }
}
