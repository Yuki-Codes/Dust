//
//  ArtworkSelectorView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//

import SwiftUI

struct ArtworkSelectorView: View {
    @Binding
    var game: Game

    var type: ArtworkType

    @Environment(SteamGridDbClient.self)
    var sgdbClient: SteamGridDbClient

    @State
    private var searchResults: [SteamGridDbObject]?

    @State
    private var isPopoverPresented: Bool = false

    private var artUrl: String? {
        switch self.type {
        case ArtworkType.cover: return self.game.coverUrl
        case ArtworkType.hero: return self.game.heroUrl
        case ArtworkType.logo: return self.game.logoUrl
        }
    }

    private var label: String {
        switch self.type {
        case ArtworkType.cover: return "Cover"
        case ArtworkType.hero: return "Hero"
        case ArtworkType.logo: return "Logo"
        }
    }

    enum ArtworkType {
        case cover
        case logo
        case hero
    }

    func beginSearch() {
        _ = Task {
            return await self.searchSafe()
        }
    }

    func searchSafe() async {
        do {
            if self.game.sgdbId == nil {
                return
            }

            switch self.type {
            case .cover:
                self.searchResults = try await self.sgdbClient.getGrids(gameId: self.game.sgdbId!)
            case .logo:
                self.searchResults = try await self.sgdbClient.getLogos(gameId: self.game.sgdbId!)
            case .hero:
                self.searchResults = try await self.sgdbClient.getHeroes(gameId: self.game.sgdbId!)
            }
        } catch {
            print(error)
        }
    }

    var body: some View {
        Button(action: {
            self.isPopoverPresented = true
            self.beginSearch()
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
                Text("Artwork provided by Steam Grid DB")
                    .font(Font.caption)
                    .opacity(0.5)

                if self.searchResults != nil {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.fixed(100)),
                                GridItem(.fixed(100)),
                                GridItem(.fixed(100)),
                                GridItem(.fixed(100)),
                                GridItem(.fixed(100))
                            ],
                            alignment: .leading,
                            spacing: 10
                        ) {
                            ForEach(self.searchResults!, id: \.self) { result in
                                Button(action:
                                {
                                    self.setArtwork(value: result.thumb)
                                    self.isPopoverPresented = false
                                }, label: {
                                    UrlImageView(url: result.thumb)
                                })
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(height: 400)
                } else {
                    Spacer()
                        .frame(height: 400)
                }
            }
            .padding(16)
        }
        .frame(height: 150)
    }

    func setArtwork(value: String) {
        switch self.type {
        case .cover:
            self.game.coverUrl = value
        case .hero:
            self.game.heroUrl = value
        case .logo:
            self.game.logoUrl = value
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
