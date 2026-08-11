//
//  SteamGridDbClient.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import System;
import Foundation;
import SwiftData;
import SwiftUI;

// Based on SteamGridDb.NET
// https://github.com/craftersmine/SteamGridDB.NET/

class SteamGridDbClient
{
    let baseAddress:String = "https://www.steamgriddb.com/api/v2/";
    var apiKey:String = "";
    
    let session:URLSession;
    
    init(apiKey:String)
    {
        self.apiKey = apiKey;
        
        let config:URLSessionConfiguration = URLSessionConfiguration.default;
        ////config.httpAdditionalHeaders = ["Bearer" : apiKey];
        config.httpAdditionalHeaders = ["Authorization": "Bearer \(apiKey)"];
        
        
        self.session = URLSession(configuration: config);
    }
    
    func Search(term:String) async throws -> [SteamGridDbGame]?
    {
        let escapedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);
        if (escapedTerm == nil)
        {
            return nil;
        }
        
        return try await Get(uri: "search/autocomplete/\(escapedTerm!)");
    }
    
    private func Get<T:Decodable>(uri:String) async throws -> [T]?
    {
        guard let url = URL(string: "\(self.baseAddress)\(uri)") else
        {
            return nil;
        }
        
        let (data, _) = try await self.session.data(from: url);
        let result = try JSONDecoder().decode(SteamGridDbResponse<T>.self, from: data);
        if (!result.success)
        {
            throw SteamGridDbError(message: result.errors![0]);
        }
        
        return result.data;
    }
}

struct SteamGridDbError: Error
{
    let message: String;
}

struct SteamGridDbResponse<T : Decodable> : Decodable
{
    var success:Bool;
    var data:[T]?
    var errors:[String]?;
}

// {"id":37452,"name":"Jak and Daxter: The Precursor Legacy","verified":true,"types":[],"release_date":1007510400}
struct SteamGridDbGame : Decodable
{
    var id:Int;
    var name:String;
    var verified:Bool;
    //var types[]
    var release_date:Int;
}
