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

                                Spacer()

                                Button(action: self.moveConfigurationUp) {
                                    ZStack {
                                        Rectangle()
                                            .opacity(0)
                                        Image(systemName: "chevron.up")
                                    }
                                }
                                .frame(width: 22, height: 22)

                                Divider().frame(height: 14)

                                Button(action: self.moveConfigurationDown) {
                                    ZStack {
                                        Rectangle()
                                            .opacity(0)
                                        Image(systemName: "chevron.down")
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

        .frame(width: 750, height: 300)
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

        let fromIndex: Int = self.game.configurations.firstIndex(of: self.selectedConfiguration)!
        self.game.configurations.remove(at: fromIndex)
        self.selectedConfigurationId = self.game.configurations[fromIndex - 1].position
        setPositions()
    }

    func moveConfigurationUp() {
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
            config.position = index
            index += 1
        }
    }
}
