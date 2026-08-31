//
//  GameInfoView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//

import SwiftUI
import SwiftData
import CachedAsyncImage

struct GameInfoView: View {
    var game: Game

    @Environment(GameManager.self)
    var gameManager: GameManager

    var body: some View {
        VStack {
            if self.game.logoUrl != nil {
                UrlImageView(url: self.game.logoUrl!)
                    .frame(maxHeight: 100)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            } else {
                Text(self.game.title)
                    .font(.title)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
            }

            HStack {
                if self.game.releaseYear != nil {
                    Text(self.game.releaseYear!)
                }

                if self.game.platform != nil {
                    IconView(iconName: self.game.platform!.iconName)
                        .frame(width: 18, height: 18)

                    Text(self.game.platform!.name)
                }
            }
            .padding(.bottom, 16)

            HStack {
                Rectangle()
                    .opacity(0)
                    .frame(height: 2)

                Button(action: {
                    self.gameManager.launch(game: self.game)
                }, label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .padding(6)
                    .padding(.horizontal, 16)
                })
                .buttonStyle(.borderedProminent)
                .padding(16)
            }
        }
        .frame(width: 300)
    }
}
