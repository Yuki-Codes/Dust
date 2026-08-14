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
    var game:Game?;
    
    var body: some View
    {
        Form
        {
            Text("Hello World");
        }
    }
}

#Preview
{
    let testGame:Game = Game(title: "Doom", file:"test");
    EditGameView(game: testGame)
        .padding(12)
}
