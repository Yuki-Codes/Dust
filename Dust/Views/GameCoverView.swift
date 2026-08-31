//
//  GameCoverView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import SwiftUI
import SwiftData
import CachedAsyncImage

struct GameCoverView: View {
    var game: Game

    var coverWidth: Float

    @State
    var popupOpen: Bool = false

    @State
    var hover: Bool = false

    var coverHeight: Float {
        return (self.coverWidth / 9) * 14
    }

    @Environment(GameManager.self)
    var gameManager: GameManager

    var body: some View {
        return ZStack {
            Rectangle()
                .background(.black)
                .opacity(0.001)

            VStack(alignment: .leading) {
                ZStack {
                    if self.game.coverUrl != nil {
                        UrlImageView(url: self.game.coverUrl!)
                            .opacity(self.game.foundInScan ? 1.0 : 0.5)
                    } else {
                        Rectangle()
                            .opacity(0)
                            .background(.thinMaterial)
                    }

                    IconView(iconName: "material-symbols-light:disc-full")
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.black, radius: 12)
                        .opacity(self.game.foundInScan ? 0.0 : 1.0)
                }
                .cornerRadius(6)
                .frame(width: CGFloat(self.coverWidth), height: CGFloat(self.coverHeight))
                .shadow(radius: 6)
                .shadow(color: .black.opacity(self.hover || self.popupOpen ? 0.5 : 0), radius: 12)
                .scaleEffect(self.hover || self.popupOpen ? 1.05 : 1)
                .animation(.easeInOut(duration: 0.15), value: self.hover)

                .popover(isPresented: self.$popupOpen, arrowEdge: .trailing) {
                    GameInfoView(game: self.game)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(self.game.title).lineLimit(2)

                    if self.game.platform != nil {
                        HStack(alignment: .center, spacing: 2) {
                            IconView(iconName: self.game.platform!.iconName)
                                .frame(width: 14, height: 14)

                            Text(self.game.platform!.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)

                            Spacer()

                            if self.game.releaseYear != nil {
                                Text(self.game.releaseYear!)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }

                    Spacer()
                }
            }
        }
        .frame(width: CGFloat(self.coverWidth))
        .padding(.bottom, 16)

        .onHover { over in
            if !self.gameManager.isEditingGame && !self.gameManager.isPlayingGame {
                self.hover = over
            }
        }
        .onTapGesture {
            self.popupOpen = true
        }

        .contextMenu {
            if self.game.platform != nil {
                Button {
                    self.gameManager.launch(game: self.game)
                }
                label: {
                    Label("Play", systemImage: "play")
                }

                Divider()

                Button {
                    self.gameManager.edit(game: self.game)
                }
                label: {
                    Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                }

                Button {
                    self.gameManager.openDir(game: self.game)
                }
                label: {
                    Label("Open Location", systemImage: "folder")
                }

                Divider()
            }

            if !self.game.hidden {
                Button {
                    self.gameManager.hide(game: self.game)
                }
                label: {
                    Label("Hide", systemImage: "eye.slash")
                }
            } else {
                Button {
                    self.gameManager.unHide(game: self.game)
                }
                label: {
                    Label("Show", systemImage: "eye")
                }
            }

            if !self.game.foundInScan {
                Button {
                    self.gameManager.delete(game: self.game)
                }
                label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
