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
            if self.game.defaultConfiguration().coverUrl != nil {
                UrlImageView(url: self.game.defaultConfiguration().coverUrl!)
                    .ignoresSafeArea()
                    .padding(-200)
            }

            VStack {
                if self.game.defaultConfiguration().logoUrl != nil {
                    UrlImageView(url: self.game.defaultConfiguration().logoUrl!)
                        .frame(maxHeight: 100)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                } else {
                    Text(self.game.defaultConfiguration().title)
                        .font(.title)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                }

                HStack {
                    Spacer()

                    if self.game.defaultConfiguration().releaseYear != nil {
                        Text(self.game.defaultConfiguration().releaseYear!)
                    }

                    if self.game.platform != nil {
                        IconView(iconName: self.game.platform!.iconName)
                            .frame(width: 18, height: 18)

                        Text(self.game.platform!.name)
                    }

                    Spacer()
                }
                .padding(.bottom, 16)

                VStack {
                    ForEach(self.game.configurations.sorted()) { configuration in
                        Button( action: {
                            self.gameManager.launch(game: self.game, configuration: configuration)
                        },
                        label: {
                            HStack {
                                if configuration.iconUrl != nil {
                                    UrlImageView(url: configuration.iconUrl!)
                                        .frame(width: 32, height: 32)
                                }

                                VStack(alignment: .leading) {
                                    Text(configuration.title)

                                    if configuration.releaseYear != nil {
                                        Text(configuration.releaseYear!)
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                    }
                                }

                                Spacer()
                            }
                        })
                    }

                }
                .padding(6)
                .padding(.bottom, 16)

                Spacer()
            }
            .background(.regularMaterial)
        }
        .frame(width: 300)
    }
}
