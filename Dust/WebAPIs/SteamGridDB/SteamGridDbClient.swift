//
//  SteamGridDbClient.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import System
import Foundation
import SwiftData
import SwiftUI

// Based on SteamGridDb.NET
// https://github.com/craftersmine/SteamGridDB.NET/

class SteamGridDbClient: Observable {
    public var connected: Bool = false

    private let baseAddress: String = "https://www.steamgriddb.com/api/v2/"
    private var apiKey: String?
    private var session: URLSession?

    init() {
        let storage = UserDefaults()
        self.apiKey = storage.string(forKey: "sgdbApiKey")

        if self.apiKey != nil {
            let config: URLSessionConfiguration = URLSessionConfiguration.default
            config.httpAdditionalHeaders = ["Authorization": "Bearer \(self.apiKey!)"]
            self.session = URLSession(configuration: config)
            self.connected = true
        }
    }

    func search(term: String) async throws -> [SteamGridDbGame]? {
        let escapedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if escapedTerm == nil {
            return nil
        }

        return try await self.get(uri: "search/autocomplete/\(escapedTerm!)")
    }

    func getGame(id: Int?) async throws -> SteamGridDbGame? {
        return try await self.get(uri: "games/id/\(id!)")
    }

    func getGrids(gameId: Int) async throws -> [SteamGridDbObject]? {
        return try await self.get(uri: "grids/game/\(gameId)?nsfw=false&humor=false&epilepsy=false&limit=50")
    }

    func getLogos(gameId: Int) async throws -> [SteamGridDbObject]? {
        return try await self.get(uri: "logos/game/\(gameId)?nsfw=false&humor=false&epilepsy=false&limit=50")
    }

    func getHeroes(gameId: Int) async throws -> [SteamGridDbObject]? {
        return try await self.get(uri: "heroes/game/\(gameId)?nsfw=false&humor=false&epilepsy=false&limit=50")
    }

    private func get<T: Decodable>(uri: String) async throws -> T? {
        if self.session == nil {
            return nil
        }

        guard let url = URL(string: "\(self.baseAddress)\(uri)") else {
            return nil
        }

        let (data, _) = try await self.session!.data(from: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        let result = try decoder.decode(SteamGridDbResponse<T>.self, from: data)
        if !result.success {
            throw SteamGridDbError(message: result.errors![0])
        }

        return result.data
    }
}

struct SteamGridDbError: Error {
    let message: String
}

struct SteamGridDbResponse<T: Decodable>: Decodable {
    var success: Bool
    var data: T?
    var errors: [String]?
}

struct SteamGridDbGame: Decodable, Hashable, Identifiable {
    var id: Int
    var name: String
    var verified: Bool
    // swiftlint:disable:next identifier_name
    var release_date: Date?
}

struct SteamGridDbObject: Decodable, Hashable {
    var id: Int
    var score: Int
    // var style
    var width: Int
    var height: Int
    var nsfw: Bool
    var humor: Bool
    var notes: String?
    // var mime;
    var language: String
    var url: String
    var thumb: String
    var epilepsy: Bool
    // var author
}
