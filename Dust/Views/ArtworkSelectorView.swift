//
//  ArtworkSelectorView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//

import SwiftUI

struct ArtworkSelectorView: View {
    @Binding
    var artUrl: String?

    var type: ArtworkType

    @Environment(SteamGridDbClient.self)
    var sgdbClient: SteamGridDbClient

    @State
    private var selectedSgdbId: Int = 0

    @State
    private var isPopoverPresented: Bool = false

    @Binding
    var searchTerm: String

    @State
    private var gameSearchResults: [SteamGridDbGame]?

    @State
    private var artSearchResults: [SteamGridDbObject]?

    private var label: String {
        switch self.type {
        case ArtworkType.cover: return "Cover"
        case ArtworkType.hero: return "Hero"
        case ArtworkType.logo: return "Logo"
        case ArtworkType.icon: return "Icon"
        }
    }

    enum ArtworkType {
        case cover
        case logo
        case hero
        case icon
    }

    func beginGameSearch() {
        _ = Task {
            return await self.searchGameSafe()
        }
    }

    func searchGameSafe() async {
        do {
            self.gameSearchResults = try await self.sgdbClient.search(term: self.searchTerm)

            if self.gameSearchResults != nil && !self.gameSearchResults!.isEmpty {
                self.selectedSgdbId = self.gameSearchResults![0].id
                await self.searchArtSafe()
            }
        } catch {
            print(error)
        }
    }

    func beginArtSearch() {
        _ = Task {
            return await self.searchArtSafe()
        }
    }

    func searchArtSafe() async {
        do {
            switch self.type {
            case .cover:
                self.artSearchResults = try await self.sgdbClient.getGrids(gameId: self.selectedSgdbId)
            case .logo:
                self.artSearchResults = try await self.sgdbClient.getLogos(gameId: self.selectedSgdbId)
            case .hero:
                self.artSearchResults = try await self.sgdbClient.getHeroes(gameId: self.selectedSgdbId)
            case .icon:
                self.artSearchResults = try await self.sgdbClient.getIcons(gameId: self.selectedSgdbId)
            }
        } catch {
            print(error)
        }
    }

    var body: some View {
        Button(action: {
            self.isPopoverPresented = true
        }, label: {
            VStack {
                ZStack {
                    Rectangle().opacity(0)

                    if self.artUrl != nil {
                        UrlImageView(url: self.artUrl!)
                    }
                }

                Text(self.label)
            }
        })
        .popover(isPresented: self.$isPopoverPresented) {
            VStack {
                TextField("Search", text: self.$searchTerm)
                    .onSubmit(self.beginGameSearch)
                    .padding(16)

                HStack {
                    if gameSearchResults != nil {
                        List(self.gameSearchResults!, selection: self.$selectedSgdbId) { sgdbGame in
                            HStack {
                                Text(sgdbGame.name)
                                    .lineLimit(1)
                                Spacer()
                                Text(sgdbGame.release_date?.formatted(.dateTime.year()) ?? "")
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(width: 200)
                        .listStyle(.sidebar)
                        .onChange(of: selectedSgdbId) {
                            self.beginArtSearch()
                        }
                    }

                    if self.artSearchResults != nil {
                        ScrollView {
                            LazyVGrid(
                                columns: [
                                    GridItem(.fixed(100)),
                                    GridItem(.fixed(100)),
                                    GridItem(.fixed(100)),
                                    GridItem(.fixed(100))
                                ],
                                alignment: .leading,
                                spacing: 10
                            ) {
                                ForEach(self.artSearchResults!, id: \.self) { result in
                                    Button(action:
                                    {
                                        self.artUrl = result.thumb
                                        self.isPopoverPresented = false
                                    }, label: {
                                        UrlImageView(url: result.thumb)
                                            .cornerRadius(6)
                                    })
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    } else {
                        Rectangle()
                            .opacity(0)
                    }

                    Spacer()
                }

                Text("Artwork provided by Steam Grid DB")
                    .font(Font.caption)
                    .opacity(0.5)
                    .padding(4)
            }
            .frame(width: 666, height: 350)
            .onAppear {
                self.beginGameSearch()
            }
        }
    }
}

#Preview
{
    let testPlatform = Platform(name: "MacOS", iconName: "wpf:mac-os")
    PlatformSettingsView(platform: testPlatform)
        .frame(minWidth: 300, minHeight: 250)
        .padding(16)
}
