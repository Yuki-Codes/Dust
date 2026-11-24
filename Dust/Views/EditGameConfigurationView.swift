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

    var game: Game

    @State
    var searchTerm: String = ""

    @State
    private var gameSearchResults: [SteamGridDbGame]?

    @State
    private var selectedSgdbGame: SteamGridDbGame?

    @State
    private var isPopoverPresented: Bool = false

    @State
    private var selectedPage: Page = Page.Metadata

    enum Page: String, CaseIterable, Identifiable {
        case Launch, Metadata, Mods
        var id: Self { self }
    }

    var body: some View {
        VStack {

            // Hack tog et around macOs 27 tabs bug: https://github.com/siracusa/TabViewSheet
            Picker("", selection: self.$selectedPage) {
                Text("Launch").tag(Page.Launch)
                Text("Metadata").tag(Page.Metadata)
                Text("Mods").tag(Page.Mods)
            }.pickerStyle(.tabs)

            if (self.selectedPage == Page.Launch){
                Form {
                    if self.configuration.position == 0 {
                        Toggle("Include in launch list", isOn: self.$configuration.canLaunch)
                            .toggleStyle(.checkbox)
                    }

                    if self.configuration.canLaunch {
                        TextField("Additional Arguments", text: self.$configuration.launchArgs ?? "")
                    }
                }

                let argsString = Services.GameManager.getArgs(game: self.game, configuration: self.configuration)

                Text(argsString)
                    .font(.caption)
                    .frame(maxWidth: 400)

                Spacer();
            }

            if (self.selectedPage == Page.Metadata){
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
                            .frame(width: 350, height: 450)
                            .onAppear {
                                self.beginGameSearch()
                            }
                        }

                        // Text("Pos: \(self.configuration.position)")

                        TextField("Display Title", text: self.$configuration.title)

                        if self.configuration.position == -1 {
                            TextField("Sort Title", text: self.$configuration.sortTitle)
                        }

                        TextField("Release Year", text: self.$configuration.releaseYear ?? "")

                        HStack {
                            // Only the default config gets a cover.
                            if self.configuration.position == 0 {
                                ArtworkSelectorView(
                                    artUrl: self.$configuration.coverUrl,
                                    type: .cover,
                                    searchTerm: self.$searchTerm)
                            }

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
                    }

                }
                .onChange(of: self.configuration.title) {
                    self.searchTerm = self.configuration.title
                }
                .onAppear {
                    self.searchTerm = self.configuration.title
                }

                Spacer();
            }

            if (self.selectedPage == Page.Mods) {

                let mods = Services.GameManager.getAvailableMods(game: self.game);

                GroupBox {
                    ScrollView {
                        ForEach(mods, id: \.self) { modPath in
                            ModView(configuration: self.$configuration, modPath: modPath)
                        }
                    }

                    Spacer();
                }

                Button("Clear") {
                    self.configuration.modPaths = []
                }
            }
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


struct ModView: View {

    @Binding
    var configuration: Configuration

    var modPath: String

    @State
    var enabled: Bool = false

    var body: some View {
        HStack {
            Toggle((self.modPath as NSString).lastPathComponent, isOn: self.$enabled)
                .toggleStyle(.checkbox)
                .onChange(of: self.enabled) {
                    if (self.enabled) {
                        self.configuration.modPaths.append(self.modPath)
                    }
                    else
                    {
                        if let index = self.configuration.modPaths.firstIndex(of: self.modPath) {
                            self.configuration.modPaths.remove(at: index)
                        }
                    }
                }
                .help(self.modPath)

            Spacer()
        }
        .onAppear() {

            let modPaths: [String] = self.configuration.modPaths
            self.enabled = modPaths.contains(where: {
                $0.range(of: self.modPath, options: .caseInsensitive) != nil
            })
        }
    }
}