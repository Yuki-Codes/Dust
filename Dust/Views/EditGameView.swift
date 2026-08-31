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
    var searchTerm: String = ""

    @State
    private var searchResults: [SteamGridDbGame]?

    @State
    var isPopoverPresented: Bool = false

    @State
    var selectedSgdbGame: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                HStack {
                    TextField("SteamGridDB.com/game/", value: self.$game.sgdbId, formatter: NumberFormatter())

                    Button(action: {
                        self.isPopoverPresented = true
                        self.beginSearch()
                    }, label: {
                        Image(systemName: "magnifyingglass")
                    })

                    Button(action: {
                        self.scanner!.beginGetMetadata(game: self.game, force: true)
                    }, label: {
                        if self.scanner!.isScanning {
                            ProgressView().scaleEffect(0.4)
                        } else {
                            Image(systemName: "square.and.arrow.down")
                        }
                    })
                }
                .popover(isPresented: self.$isPopoverPresented) {
                    VStack {
                        TextField("Search", text: self.$searchTerm)
                            .onSubmit(self.beginSearch)

                        Text("Metadata and artwork provided by the Steam Grid Database")
                            .font(Font.caption)
                            .opacity(0.5)

                        if self.searchResults != nil {
                            List(self.searchResults!, selection: self.$game.sgdbId) { sgdbGame in
                                HStack {
                                    Text(sgdbGame.name).lineLimit(1)

                                    let releaseYear: String = sgdbGame.release_date?.formatted(.dateTime.year()) ?? ""
                                    Text(releaseYear)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(height: 200)
                            .listStyle(.plain)
                        } else {
                            Spacer()
                                .frame(height: 200)
                        }
                    }
                    .frame(width: 400)
                    .padding(16)
                }
            }

            Text("Find this game on the Steam Grid Database to download artwork and metadata.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer().frame(height: 32)

            Form {
                TextField("Display Title", text: self.$game.title)
                TextField("Sort Title", text: self.$game.sortTitle)
                TextField("Release Year", text: self.$game.releaseYear ?? "")
                // Toggle("Hidden from library", isOn: $game.hidden).toggleStyle(.checkbox);

                HStack {
                    ArtworkSelectorView(game: self.$game, type: .cover)
                    ArtworkSelectorView(game: self.$game, type: .logo)
                    ArtworkSelectorView(game: self.$game, type: .hero)
                }

                TextField("Arguments", text: self.$game.customLaunch ?? "", prompt: Text(self.game.platform?.launchArgs ?? ""))
                Text("Override the default launch arguments for this game.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
                .frame(height: 32)

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
    }

    func beginSearch() {
        if self.searchTerm == "" {
            self.searchTerm = self.game.title
        }

        _ = Task {
            return await self.searchSafe()
        }
    }

    func searchSafe() async {
        do {
            self.searchResults = try await self.sgdb.search(term: self.searchTerm)
        } catch {
            print(error)
        }
    }
}

#Preview
{
    EditGameView(game: Game.testGame())
        .padding(12)
}
