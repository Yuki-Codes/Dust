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
            if self.game.coverUrl != nil {
                UrlImageView(url: self.game.coverUrl!)
                    .ignoresSafeArea()
                    .padding(-200)
            }

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
                    Spacer()

                    if self.game.releaseYear != nil {
                        Text(self.game.releaseYear!)
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
                    if !self.game.shortcuts.isEmpty {
                        ForEach(self.game.shortcuts) { shortcut in
                            Button( action: {
                                // TODO: shortcut
                                self.gameManager.launch(game: self.game)
                            },
                            label: {
                                HStack {
                                    if shortcut.iconUrl != nil {
                                        UrlImageView(url: shortcut.iconUrl!)
                                            .frame(width: 32, height: 32)
                                    }

                                    VStack(alignment: .leading) {
                                        Text(shortcut.title)

                                        if shortcut.subTitle != nil {
                                            Text(shortcut.subTitle!)
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                        }
                                    }

                                    Spacer()
                                }
                            })
                        }
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
