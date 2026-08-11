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
        
        var config:URLSessionConfiguration = URLSessionConfiguration.default;
        config.httpAdditionalHeaders = ["Bearer" : apiKey];
        self.session = URLSession(configuration: config);
    }
    
    func GetGameByIdAsync(id:Int) async throws
    {
        try await Get(uri: "games/id/\(id)");
    }
    
    private func Get(uri:String) async throws
    {
        guard let url = URL(string: "\(self.baseAddress)/\(uri)") else
        {
            return;
        }
        
        let (data, _) = try await self.session.data(from: url)
        
        //let iTunesResult = try JSONDecoder().decode(ITunesResult.self, from: data)
    }
}

extension EnvironmentValues
{
}
