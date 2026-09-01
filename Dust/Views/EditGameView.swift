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
    @State
    var game: Game

    @State
    var selectedConfigurationId: Int

    @State
    var selectedConfiguration: Configuration

    @State
    var searchTerm: String = ""

    init(game: Game) {
        self.game = game
        self.selectedConfiguration = game.defaultConfiguration()
        self.selectedConfigurationId = game.defaultConfiguration().position
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                /*Text("Library")
                HStack {
                    Form {
                        TextField("Title", text: self.$game.title)
                        TextField("Sort Title", text: self.$game.sortTitle)
                        TextField("Release Year", text: self.$game.releaseYear ?? "")
                        Spacer()
                    }

                    ArtworkSelectorView(
                        artUrl: self.$game.coverUrl,
                        type: .cover,
                        searchTerm: self.$searchTerm)
                        .frame(width: 120)

                    ArtworkSelectorView(
                        artUrl: self.$game.logoUrl,
                        type: .logo,
                        searchTerm: self.$searchTerm)
                        .frame(width: 150)
                }
                .frame(height: 150)

                Divider()

                Text("Launch Configurations")*/

                HStack {
                    GroupBox {
                        List(self.game.configurations.sorted(), id: \.position, selection: self.$selectedConfigurationId) { configuration in
                            HStack {

                                if configuration.position == -1 {
                                    Image(systemName: "star.fill")
                                }

                                Text(configuration.title)
                                    .lineLimit(1)
                            }
                        }
                        .onChange(of: self.selectedConfigurationId) {
                            for config in self.game.configurations where config.position == self.selectedConfigurationId {
                                self.selectedConfiguration = config
                                break
                            }
                        }
                        .padding(.bottom, 24)
                        .padding(.top, -4)
                        .padding(.horizontal, -4)
                        .listStyle(.plain)
                        .overlay(alignment: .bottomLeading, content:
                        {
                            HStack(spacing: 0) {
                                Button(action: self.addConfiguration) {
                                    ZStack {
                                        Rectangle().opacity(0)
                                        Image(systemName: "plus")
                                    }
                                }
                                .frame(width: 22, height: 22)

                                Divider().frame(height: 14)

                                Button(action: self.removeConfiguration) {
                                    ZStack {
                                        Rectangle().opacity(0)
                                        Image(systemName: "minus")
                                    }
                                }
                                .frame(width: 22, height: 22)
                                .disabled(self.selectedConfigurationId == -1)

                                Spacer()

                                Button(action: self.moveConfigurationUp) {
                                    ZStack {
                                        Rectangle()
                                            .opacity(0)
                                        Image(systemName: "chevron.up")
                                    }
                                }
                                .frame(width: 22, height: 22)
                                .disabled(self.selectedConfigurationId == -1)

                                Divider().frame(height: 14)

                                Button(action: self.moveConfigurationDown) {
                                    ZStack {
                                        Rectangle()
                                            .opacity(0)
                                        Image(systemName: "chevron.down")
                                    }
                                }
                                .frame(width: 22, height: 22)
                                .disabled(self.selectedConfigurationId == -1)
                            }
                            .buttonStyle(.borderless)
                        })
                    }
                    .formStyle(.grouped)
                    .scrollDisabled(true)
                    .frame(width: 200)

                    Form {
                        // Toggle("Hidden from library", isOn: $game.hidden).toggleStyle(.checkbox);

                        EditGameConfigurationView(
                            configuration: self.$selectedConfiguration)

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
            }
        }

        .frame(width: 600, height: 350)
    }

    func addConfiguration() {

        let config: Configuration = Configuration()
        config.title = "New Configuration"
        config.position = self.game.configurations.count
        self.game.configurations.append(config)
        self.selectedConfigurationId = config.position
        setPositions()
    }

    func removeConfiguration() {
        if self.game.configurations.count <= 1 {
            return
        }

        // Cant remove the default config
        if self.selectedConfiguration.position == -1 {
            return
        }

        let fromIndex: Int = self.game.configurations.firstIndex(of: self.selectedConfiguration)!
        self.game.configurations.remove(at: fromIndex)
        setPositions()

        self.selectedConfigurationId = -1
    }

    func moveConfigurationUp() {
        // Cant move the default config
        if self.selectedConfiguration.position == -1 {
            return
        }

        let config: Configuration = self.selectedConfiguration
        let targetPosition: Int = config.position - 1

        if targetPosition < 0 {
            return
        }

        for otherConfig in self.game.configurations where otherConfig.position >= targetPosition {
            otherConfig.position += 1
        }
        config.position = targetPosition

        setPositions()
        self.selectedConfigurationId = config.position
    }

    func moveConfigurationDown() {
        // Cant move the default config
        if self.selectedConfiguration.position == -1 {
            return
        }

        let config: Configuration = self.selectedConfiguration
        let targetPosition: Int = config.position + 1
        for otherConfig in self.game.configurations where otherConfig.position <= targetPosition {
            otherConfig.position -= 1
        }
        config.position = targetPosition

        setPositions()
        self.selectedConfigurationId = config.position
    }

    func setPositions() {
        var index: Int = 0
        for config in self.game.configurations.sorted() {
            if config.position == -1 {
                continue
            }

            config.position = index
            index += 1
        }
    }
}
