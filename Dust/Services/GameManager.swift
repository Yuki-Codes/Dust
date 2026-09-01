//
//  GameManager.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import SwiftData
import SwiftUI

@Observable
class GameManager {
    var isEditingGame: Bool = false
    var editingGame: Game?

    var isPlayingGame: Bool = false
    var playingGame: Game?
    var playingConfig: Configuration?

    init() {
    }

    func launch(game: Game, configuration: Configuration) {
        if game.platform == nil {
            return
        }

        playingConfig = configuration

        var executable: String = game.path

        if game.platform!.type == .emulator {
            executable = game.platform!.executablePath
        }

        var args = game.platform!.launchArgs

        if configuration.launchArgs != nil {
            args = configuration.launchArgs!
        }

        let fileName = (game.path as NSString).lastPathComponent
        let directory = game.path.replacingOccurrences(of: fileName, with: "")
        let directoryName = (directory as NSString).lastPathComponent

        args = args.replacingOccurrences(of: "{path}", with: "\"\(game.path)\"")
        args = args.replacingOccurrences(of: "{file}", with: "\"\(fileName)\"")
        args = args.replacingOccurrences(of: "{title}", with: "\"\(configuration.title)\"")
        args = args.replacingOccurrences(of: "{directory}", with: "\"\(directory)\"")
        args = args.replacingOccurrences(of: "{directoryName}", with: "\"\(directoryName)\"")

        if game.platform!.retroArchCore != nil && game.platform!.retroArchCore != "" {
            args = args.replacingOccurrences(of: "{core}", with: "\"\(game.platform!.retroArchCore!)\"")
        }

        var proc: Process? = Shell.execute("open -n -W \"\(executable)\" --args \(args)")

        if proc != nil {
            self.beginWatching(game: game, process: proc!)
        }
    }

    func edit(game: Game) {
        self.isEditingGame = true
        self.editingGame = game
    }

    func openDir(game: Game) {
        if game.platform == nil {
            return
        }

        let dir = (game.path as NSString).deletingLastPathComponent
        _ = Shell.execute("open \(dir)")
    }

    func hide(game: Game) {
        game.hidden = true
    }

    func unHide(game: Game) {
        game.hidden = false
    }

    func delete(game: Game) {
        Services.Container.mainContext.delete(game)
    }

    private func beginWatching(game: Game, process: Process) {
        _ = Task {
            return await self.watch(game: game, process: process)
        }
    }

    private func watch(game: Game, process: Process) async {
        self.playingGame = game
        self.isPlayingGame = true

        do {
            while process.isRunning {
                try await Task.sleep(for: .seconds(1))
            }
        } catch {
            print(error)
        }

        self.isPlayingGame = false
        self.playingGame = nil
        self.playingConfig = nil
    }
}
