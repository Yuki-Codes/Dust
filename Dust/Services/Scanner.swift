//
//  Scanner.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import SwiftData
import SwiftUI

@Observable
class Scanner {
    var isScanning: Bool = false
    var status: String = "Initializing..."

    func beginScan() {
        _ = Task {
            return await self.scanSafe()
        }
    }

    private func scanSafe() async {
        if self.isScanning {
            return
        }

        self.isScanning = true
        do {
            try await self.scan()
        } catch {
            print(error)
        }

        self.isScanning = false
    }

    func beginGetMetadata(game: Game, force: Bool) {
        _ = Task {
            return await self.getMetadataSafe(game: game, force: force)
        }
    }

    private func getMetadataSafe(game: Game, force: Bool) async {
        if self.isScanning {
            return
        }

        self.isScanning = true
        do {
            try await self.getMetadata(game: game, force: force)
        } catch {
            print(error)
        }

        self.isScanning = false
    }

    private func scan() async throws {
        let games: [Game] = try Services.Container.mainContext.fetch(FetchDescriptor<Game>())
        for game in games {
            game.foundInScan = false
        }

        let platforms: [Platform] = try Services.Container.mainContext.fetch(FetchDescriptor<Platform>())

        for platform in platforms {
            try await self.scan(platform: platform)
        }

        self.status = "Done"
        try await Task.sleep(for: .seconds(1))
    }

    private func scan(platform: Platform) async throws {
        self.status = platform.name

        print(platform.name)

        for directory in platform.directories {
            let url: URL = URL(filePath: directory)
            if !url.startAccessingSecurityScopedResource() {
                print("Failed to get security scoped resource for path: \(url.absoluteString)")
                return
            }

            do {
                try await self.scan(platform: platform, dir: directory)
            } catch {
                print("error: \(error)")
            }

            url.stopAccessingSecurityScopedResource()
        }
    }

    private func scan(platform: Platform, dir: String) async throws {
        let files: [String] = try FileManager.default.contentsOfDirectory(atPath: dir)
        let pattern = try Regex(platform.searchPattern)

        for file in files {
            var path: String = dir
            if !path.hasSuffix("/") && !file.hasPrefix("/") {
                path = path.appending("/")
            }

            path = path.appending(file)

            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: path, isDirectory: &isDir)

            if file.contains(pattern) {
                try await self.scan(platform: platform, path: path)
            } else if isDir.boolValue {
                try await self.scan(platform: platform, dir: path)
            }
        }
    }

    private func scan(platform: Platform, path: String) async throws {
        let fileName = (path as NSString).lastPathComponent

        self.status = "\(platform.name) - \(fileName)"

        // not ideal, but fast enough for now.
        let games: [Game] = try Services.Container.mainContext.fetch(FetchDescriptor<Game>())
        var existingGame: Game?
        for game in games where game.path == path {
            game.path = path
            existingGame = game
            break
        }

        // Try get SGDB game
        if existingGame == nil && Services.SgdbClient.connected {
            let results = try await Services.SgdbClient.search(term: fileName)

            if results != nil && !results!.isEmpty {
                let sgdbGame = results![0]
                print("Found: \"\(sgdbGame.name)\" for \"\(fileName)\"")

                existingGame = Game(title: sgdbGame.name, path: path)
                existingGame!.sgdbId = sgdbGame.id
                existingGame!.platform = platform

                // save
                Services.Container.mainContext.insert(existingGame!)
            }
        }

        // fallback to direct game
        if existingGame == nil {
            existingGame = Game(title: fileName, path: path)
            existingGame!.platform = platform
        }

        // automatic metadata update
        if existingGame != nil {
            existingGame?.foundInScan = true
            try await self.getMetadata(game: existingGame!, force: false)
        }
    }

    private func getMetadata(game: Game, force: Bool) async throws {
        // Don't bother updating games that are hidden.
        if game.hidden {
            return
        }

        if Services.SgdbClient.connected == true && game.sgdbId != nil {
            try await self.updateSgdbGame(game: game, force: force)
        }
    }

    private func updateSgdbGame(game: Game, force: Bool) async throws {
        let updataMetadata = force || game.title == "" || game.releaseYear == nil
        if updataMetadata {
            let sgdbGame = try await Services.SgdbClient.getGame(id: game.sgdbId)

            if force || game.title == "" {
                game.title = sgdbGame!.name
            }

            if sgdbGame!.release_date != nil && (force || game.releaseYear == nil) {
                game.releaseYear = sgdbGame!.release_date!.formatted(.dateTime.year())
            }
        }

        if force || game.coverUrl == nil {
            let grids: [SteamGridDbObject]? = try await Services.SgdbClient.getGrids(gameId: game.sgdbId!)
            if grids != nil && !grids!.isEmpty {
                game.coverUrl = grids![0].thumb
            }
        }

        if force || game.logoUrl == nil {
            let logos: [SteamGridDbObject]? = try await Services.SgdbClient.getLogos(gameId: game.sgdbId!)
            if logos != nil && !logos!.isEmpty {
                game.logoUrl = logos![0].thumb
            }
        }

        if force || game.heroUrl == nil {
            let heroes: [SteamGridDbObject]? = try await Services.SgdbClient.getHeroes(gameId: game.sgdbId!)
            if heroes != nil && !heroes!.isEmpty {
                game.heroUrl = heroes![0].thumb
            }
        }
    }
}
