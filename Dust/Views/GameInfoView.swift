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
        ZStack {
            VStack {
                if self.game.defaultConfiguration().logoUrl != nil {
                    UrlImageView(url: self.game.defaultConfiguration().logoUrl!)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .frame(minHeight: 64, maxHeight: 200)
                } else {
                    Text(self.game.defaultConfiguration().title)
                        .font(.title)
                        .padding(.horizontal, 16)
                        .padding(.top, )
                }

                VStack {
                    ForEach(self.game.configurations.sorted()) { configuration in

                        if configuration.canLaunch {
                            Button( action: {
                                self.gameManager.launch(game: self.game, configuration: configuration)
                            },
                            label: {
                                HStack {

                                    if configuration.iconUrl != nil {
                                        UrlImageView(url: configuration.iconUrl!)
                                            .frame(width: 48, height: 48)
                                            .cornerRadius(6)
                                    }

                                    VStack(alignment: .leading) {
                                        Text(configuration.title)
                                            .lineLimit(1)
                                            .frame(width: 200, alignment: .leading)

                                        if configuration.releaseYear != nil {
                                            Text(configuration.releaseYear!)
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                                .lineLimit(1)
                                        }
                                    }

                                    Spacer()
                                }
                            })
                        }
                    }

                }
                .padding(16)
                .padding(.bottom, 2)
            }
        }
        .frame(width: 300)
    }
}
