//
//  EditGameConfigurationView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-09-01.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct EditGameConfigurationView: View {

    @Environment(SteamGridDbClient.self)
    var sgdbClient: SteamGridDbClient

    @Binding
    var configuration: Configuration

    @State
    var searchTerm: String = ""

    @State
    private var gameSearchResults: [SteamGridDbGame]?

    @State
    private var selectedSgdbGame: SteamGridDbGame?

    @State
    private var isPopoverPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading) {

            Form {
                Button(action: {
                    self.isPopoverPresented = true
                }, label: {
                    Label("Search for a game", systemImage: "magnifyingglass")
                })
                .popover(isPresented: self.$isPopoverPresented) {
                    VStack {
                        TextField("Search", text: self.$searchTerm)
                            .onSubmit(self.beginGameSearch)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .padding(.top, 16)

                        if gameSearchResults != nil {
                            List(self.gameSearchResults!, id: \.self, selection: self.$selectedSgdbGame) { sgdbGame in
                                HStack {
                                    Text(sgdbGame.name)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(sgdbGame.release_date?.formatted(.dateTime.year()) ?? "")
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .listStyle(.sidebar)
                        } else {
                            Spacer()
                        }

                        Button(action: {
                            self.isPopoverPresented = false
                            self.beginImportFromSgdb(sgdbGame: self.selectedSgdbGame!)
                        }, label: {
                            Label("Import Metadata", systemImage: "square.and.arrow.down")
                        })
                        .padding(.top, 16)
                        .disabled(self.selectedSgdbGame == nil)

                        Text("Metadata provided by Steam Grid DB")
                            .font(Font.caption)
                            .opacity(0.5)
                            .padding(4)
                            .padding(.bottom, 8)
                    }
                    .frame(width: 200, height: 350)
                    .onAppear {
                        self.beginGameSearch()
                    }
                }

                TextField("Display Title", text: self.$configuration.title)
                TextField("Sort Title", text: self.$configuration.sortTitle)
                TextField("Release Year", text: self.$configuration.releaseYear ?? "")

                HStack {
                    ArtworkSelectorView(
                        artUrl: self.$configuration.coverUrl,
                        type: .cover,
                        searchTerm: self.$searchTerm)

                    ArtworkSelectorView(
                        artUrl: self.$configuration.logoUrl,
                        type: .logo,
                        searchTerm: self.$searchTerm)

                    ArtworkSelectorView(
                        artUrl: self.$configuration.heroUrl,
                        type: .hero,
                        searchTerm: self.$searchTerm)

                    ArtworkSelectorView(
                        artUrl: self.$configuration.iconUrl,
                        type: .icon,
                        searchTerm: self.$searchTerm)
                }

                TextField("Arguments", text: self.$configuration.launchArgs ?? "")
            }

        }
        .onChange(of: self.configuration.title) {
            self.searchTerm = self.configuration.title
        }
        .onAppear {
            self.searchTerm = self.configuration.title
        }
    }

    func beginGameSearch() {
        _ = Task {
            return await self.searchGameSafe()
        }
    }

    func searchGameSafe() async {
        do {
            self.gameSearchResults = try await self.sgdbClient.search(term: self.searchTerm)
        } catch {
            print(error)
        }
    }

    func beginImportFromSgdb(sgdbGame: SteamGridDbGame) {
        _ = Task {
            await Services.SgdbClient.importMetadata(sgdbGame: sgdbGame, config: self.configuration)
        }
    }
}
