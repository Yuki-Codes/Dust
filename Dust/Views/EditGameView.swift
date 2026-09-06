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

    @Query
    var platforms: [Platform]

    init(game: Game) {
        self.game = game
        self.selectedConfiguration = game.defaultConfiguration()
        self.selectedConfigurationId = game.defaultConfiguration().position
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
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

                    EditGameConfigurationView(
                        configuration: self.$selectedConfiguration)
                }

                Form {
                    Picker("Platform", selection: self.$game.platform) {
                        ForEach(self.platforms) { platform in
                            Text(platform.name)
                                .tag(platform)
                        }
                    }
                    .buttonSizing(.flexible)

                    HStack {
                        TextField("Path", text: self.$game.path)
                        Button("...") {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            if panel.runModal() == .OK {
                                self.game.path = panel.url?.path() ?? ""
                                self.game.foundInScan = true
                            }
                        }
                    }

                    /*if self.game.platform?.type == .emulator {
                        TextField("Executable", text: self.game.platform?.executablePath ?? "")
                    }*/

                    TextField("Mods Directory", text: self.$game.modsDirectory ?? "")
                    TextField("Configuration File", text: self.$game.configurationPath ?? "")
                }
            }
        }

        .frame(width: 600, height: 450)
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
