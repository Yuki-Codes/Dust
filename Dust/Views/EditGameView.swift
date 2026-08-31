//
//  EditGameView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct EditGameView: View {
    @Environment(Scanner.self)
    var scanner: Scanner?

    @Environment(SteamGridDbClient.self)
    var sgdb: SteamGridDbClient

    @State
    var game: Game

    @State
    var isPopoverPresented: Bool = false

    @State
    var selectedSgdbGame: Int = 0

    @State
    var selectedShortcutIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Form {
                    TextField("Display Title", text: self.$game.title)
                    TextField("Sort Title", text: self.$game.sortTitle)
                    TextField("Release Year", text: self.$game.releaseYear ?? "")
                    // Toggle("Hidden from library", isOn: $game.hidden).toggleStyle(.checkbox);

                    HStack {
                        ArtworkSelectorView(game: self.$game, type: .cover)
                            .frame(height: 150)
                        ArtworkSelectorView(game: self.$game, type: .logo)
                            .frame(height: 150)
                        ArtworkSelectorView(game: self.$game, type: .hero)
                            .frame(height: 150)
                    }

                    TextField("Arguments", text: self.$game.customLaunch ?? "", prompt: Text(self.game.platform?.launchArgs ?? ""))
                    Text("Override the default launch arguments for this game.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("Path: ")
                            .font(.caption)
                        Text(self.game.path)
                            .font(.caption)
                    }

                    if self.game.platform?.type == .emulator {
                        HStack {
                            Text("Executable: ")
                                .font(.caption)

                            Text(self.game.platform?.executablePath ?? "")
                                .font(.caption)
                        }
                    }
                }
                .frame(width: 400)

                if self.game.platform?.type == .applications {
                    VStack {
                        GroupBox {
                            Text("Shortcuts")
                            List(selection: self.$selectedShortcutIndex) {
                                 ForEach(self.game.shortcuts.enumerated(), id: \.offset) { (_, shortcut) in
                                    Text(shortcut.title)
                                 }
                            }
                            .padding(.bottom, 24)
                            .padding(.top, -4)
                            .padding(.horizontal, -4)
                            .listStyle(.plain)
                            .overlay(alignment: .bottomLeading, content:
                            {
                                HStack(spacing: 0) {
                                    Button(action: self.addShortcut) {
                                        ZStack {
                                            Rectangle().opacity(0)
                                            Image(systemName: "plus")
                                        }
                                    }
                                    .frame(width: 22, height: 22)

                                    Divider().frame(height: 14)

                                    Button(action: self.removeShortcut) {
                                        ZStack {
                                            Rectangle().opacity(0)
                                            Image(systemName: "minus")
                                        }
                                    }
                                    .frame(width: 22, height: 22)
                                }
                                .buttonStyle(.borderless)
                                })
                        }
                        .formStyle(.grouped)
                        .scrollDisabled(true)
                        .frame(width: 200)

                        if !self.game.shortcuts.isEmpty {
                            EditShortcutView(
                                game: self.$game,
                                shortcut: self.$game.shortcuts[self.selectedShortcutIndex])
                        }
                    }
                }
            }
        }
    }

    func addShortcut() {
        self.game.shortcuts.append(Shortcut(title: "New shortcut"))
        self.selectedShortcutIndex += 1
    }

    func removeShortcut() {
        self.game.shortcuts.remove(at: self.selectedShortcutIndex)
        self.selectedShortcutIndex -= 1
    }
}

struct EditShortcutView: View {
    @Binding
    var game: Game

    @Binding
    var shortcut: Shortcut

    var shortcutIndex: Int {
        self.game.shortcuts.firstIndex(of: self.shortcut) ?? 0
    }

    var body: some View {
        Form {
            TextField("Title", text: $shortcut.title)
            TextField("Subtitle", text: $shortcut.subTitle ?? "")
            ArtworkSelectorView(game: self.$game, shortcutIndex: shortcutIndex, type: .icon)
                .frame(height: 64)
        }
    }
}

#Preview
{
    EditGameView(game: Game.testGame())
        .padding(12)
}
