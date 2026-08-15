//
//  GameInfoView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-15.
//

import SwiftUI;
import SwiftData;
import CachedAsyncImage;

struct GameInfoView: View
{
    var game:Game;
    
    @Environment(GameManager.self)
    var gameManager:GameManager;
    
    var body: some View
    {
        VStack
        {
            if (game.logoUrl != nil)
            {
                UrlImageView(url: game.logoUrl!)
                    .frame(height: 100)
            }
            else
            {
                Text(game.title).font(.title);
            }
            
            HStack
            {
                if (game.releaseYear != nil)
                {
                    Text(game.releaseYear!);
                }
                
                if(game.platform != nil)
                {
                    IconView(iconName: game.platform!.iconName)
                        .frame(width:18, height: 18);
                    
                    Text(game.platform!.name);
                }
            }
            .padding(.bottom, 16)
            
            HStack
            {
                Rectangle().opacity(0);
                
                Button(action:
                {
                    gameManager.Launch(game: self.game);
                })
                {
                    HStack
                    {
                        Image(systemName: "play.fill");
                        Text("Play");
                    }
                    .padding(6)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(.borderedProminent)
                .padding(6);
            }
        }
    }
}
