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
        return self.coverWidth * 1.5
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
                    Rectangle()
                        .opacity(0)
                        .background(.black)

                    if self.game.defaultConfiguration().coverUrl != nil {
                        UrlImageView(url: self.game.defaultConfiguration().coverUrl!, contentMode: .fill)
                            .opacity(self.game.foundInScan ? 1.0 : 0.5)
                    } else {
                        Rectangle()
                            .opacity(0)
                            .background(.gray.gradient)

                        Text(self.game.defaultConfiguration().title)
                            .lineLimit(5)
                            .font(.title)
                            .shadow(color: Color.black, radius: 4)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: CGFloat(self.coverWidth), height: CGFloat(self.coverHeight))
                .clipped()
                .cornerRadius(6)
                .shadow(radius: 6)
                .shadow(color: .black.opacity(self.hover || self.popupOpen ? 0.5 : 0), radius: 12)
                .scaleEffect(self.hover || self.popupOpen ? 1.05 : 1)
                .animation(.easeInOut(duration: 0.15), value: self.hover)

                .popover(isPresented: self.$popupOpen, arrowEdge: .trailing) {
                    GameInfoView(game: self.game)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(self.game.defaultConfiguration().title).lineLimit(2)
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

            Button {
                self.gameManager.launch(game: self.game, configuration: self.game.defaultConfiguration())
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

            Button {
                self.gameManager.delete(game: self.game)
            }
            label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
