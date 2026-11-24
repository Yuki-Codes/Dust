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
        var args: String = getArgs(game: game, configuration: configuration)

        if game.platform!.type == .emulator {
            executable = game.platform!.executablePath
        }

        var proc: Process? = Shell.execute("open -n -W \"\(executable)\" --args \(args)")

        if proc != nil {
            self.beginWatching(game: game, process: proc!)
        }
    }

    func getArgs(game: Game, configuration: Configuration) -> String {
        var args: String = ""

        if game.platform!.type == .emulator {
            args += game.platform?.launchArgs ?? ""
        }

        args += " " + (game.launchArgs ?? "")
        args += " " + (configuration.launchArgs ?? "")

        let fileName = (game.path as NSString).lastPathComponent
        let directory = game.path.replacingOccurrences(of: fileName, with: "")
        let directoryName = (directory as NSString).lastPathComponent

        var safeTitle = configuration.title
        safeTitle = safeTitle.replacingOccurrences(of: " ", with: "_")

        args = args.replacingOccurrences(of: "{path}", with: "\"\(game.path)\"")
        args = args.replacingOccurrences(of: "{file}", with: "\"\(fileName)\"")
        args = args.replacingOccurrences(of: "{title}", with: "\"\(configuration.title)\"")
        args = args.replacingOccurrences(of: "{title_safe}", with: "\"\(safeTitle)\"")
        args = args.replacingOccurrences(of: "{directory}", with: "\"\(directory)\"")
        args = args.replacingOccurrences(of: "{directoryName}", with: "\"\(directoryName)\"")

        args = args + getModsArguments(game: game, configuration: configuration)

        return args
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

    func addGame() {
        let config: Configuration = Configuration()
        config.title = "New Game"
        let game: Game = Game(path: "", defaultConfiguration: config)
        Services.Container.mainContext.insert(game)
        self.editingGame = game
        self.isEditingGame = true
    }

    func getAvailableMods(game: Game) -> [String] {
        var mods: [String] = []

        do
        {
            if (game.platform != nil && game.platform!.modsDirectory != "") {
                let files: [String] = try FileManager.default.contentsOfDirectory(atPath: game.platform!.modsDirectory)
                for file in files {
                    var path: String = game.platform!.modsDirectory
                    if !path.hasSuffix("/") && !file.hasPrefix("/") {
                        path = path.appending("/")
                    }

                    path = path.appending(file)
                    mods.append(path);
                }
            }
        } catch {
            print(error)
        }

        do
        {
            if (game.modsDirectory != "") {
                let files: [String] = try FileManager.default.contentsOfDirectory(atPath: game.modsDirectory)
                for file in files {
                    var path: String = game.modsDirectory
                    if !path.hasSuffix("/") && !file.hasPrefix("/") {
                        path = path.appending("/")
                    }

                    path = path.appending(file)
                    mods.append(path);
                }
            }
        } catch {
            print(error)
        }

        return mods.sorted()
    }

    func getModsArguments(game: Game, configuration: Configuration) -> String {

        var args :String = ""
        var format :String = ""

        if (game.modsLaunchArgsFormat != nil && game.modsLaunchArgsFormat != "") {
            format = game.modsLaunchArgsFormat!
        } else if (game.platform != nil && game.platform!.modsLaunchArgsFormat != "") {
            format = game.platform!.modsLaunchArgsFormat
        }

        if (format == "") {
            return ""
        }

        for modPath in configuration.modPaths {
            var str: String = format

            let modFile = (modPath as NSString).lastPathComponent
            let modTitle = (modFile as NSString).deletingPathExtension
            var safeTitle = configuration.title
            safeTitle = safeTitle.replacingOccurrences(of: " ", with: "_")

            str = str.replacingOccurrences(of: "{path}", with: "\"\(modPath)\"")
            str = str.replacingOccurrences(of: "{file}", with: "\"\(modFile)\"")
            str = str.replacingOccurrences(of: "{title}", with: "\"\(modTitle)\"")
            str = str.replacingOccurrences(of: "{title_safe}", with: "\"\(safeTitle)\"")

            args = args + " " + str
        }

        return args
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
