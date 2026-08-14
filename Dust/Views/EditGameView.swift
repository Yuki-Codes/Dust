//
//  EditGameView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct EditGameView: View
{
    @State
    var game:Game;
    
    @Environment(Scanner.self)
    var scanner:Scanner?;
    
    var body: some View
    {
        Form
        {
            Text(game.file)
                .font(.caption);
            
            TextField("Custom Launch Args", text: $game.customLaunch ?? "");
            
            HStack
            {
                TextField("SGDB Id", value: $game.sgdbId, formatter: NumberFormatter());
                Button("Find Title")
                {
                }
            }
            
            Button("Fetch data from SGDB")
            {
                scanner!.BeginGetMetadata(game: game, force: true);
            }
            
            if (self.scanner!.isScanning)
            {
                ProgressView();
            }
            else
            {
                TextField("Title", text: $game.title);
            }
        }
    }
}

#Preview
{
    EditGameView(game: Game.TestGame())
        .padding(12)
}
