//
//  ContentView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-07-27.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.modelContext)
    private var modelContext

    @Environment(Scanner.self)
    var scanner: Scanner?

    @Environment(GameManager.self)
    var gameManager: GameManager

    @State
    private var search: String = ""

    @State
    private var includeHidden: Bool = false

    var body: some View {
        @Bindable
        var bindableGameManager = self.gameManager

        GamesView(searchTerm: self.search, includeHidden: self.includeHidden)
            .ignoresSafeArea(edges: .top)

        .overlay(alignment: .bottomTrailing) {
            ZStack {
                ZStack {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.75)
                        VStack(alignment: .leading) {
                            Text("Scanning for games")
                            Text(self.scanner?.status ?? "No Scanner")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 256, alignment: .leading)
                                .lineLimit(1)
                        }
                    }
                    .padding(6)
                }
                .background(.thinMaterial)
                .cornerRadius(6)
            }
            .padding(16)
            .opacity(self.scanner?.isScanning != false ? 1.0 : 0)
            .animation(.easeInOut(duration: 0.25), value: self.scanner?.isScanning)
        }

        .sheet(isPresented: $bindableGameManager.isEditingGame) {
            VStack {
                EditGameView(game: bindableGameManager.editingGame!)

                Button("Done") {
                    self.gameManager.isEditingGame = false
                }
            }
            .padding(12)
        }

        .sheet(isPresented: $bindableGameManager.isPlayingGame) {
            PlayingGameView(game: bindableGameManager.playingGame!)
        }

        .toolbar {
             Menu {
                Toggle("Show hidden games", isOn: $includeHidden)
            } label: {
                Label("Filters", systemImage: "line.3.horizontal.decrease")
            }
        }

        .searchable(text: self.$search)

        .onAppear {
            Services.Scanner.beginScan()
        }
    }
}

#Preview
{
    return MainView().withTestPlatforms()
}
