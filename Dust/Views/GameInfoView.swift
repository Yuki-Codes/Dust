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

    @State
    var hover: Configuration?

    var body: some View {
        ZStack {
            VStack {
                if self.game.defaultConfiguration().logoUrl != nil {
                    UrlImageView(url: self.game.defaultConfiguration().logoUrl!)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .frame(minHeight: 64, maxHeight: 128)
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

                                    ZStack {
                                        if configuration.iconUrl != nil {
                                            UrlImageView(url: configuration.iconUrl!)
                                                .frame(width: 48, height: 48)
                                                .background(.thinMaterial)
                                                .cornerRadius(6)
                                        }

                                        Image(systemName: "play.fill")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .opacity(self.hover == configuration ? 0.9 : 0.0)
                                            .shadow(color: Color.black, radius: 12)
                                            .animation(.easeInOut(duration: 0.25), value: self.hover)
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
                            .onHover { over in
                                if over {
                                    self.hover = configuration
                                } else if self.hover == configuration {
                                    self.hover = nil
                                }
                            }
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
