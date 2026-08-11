//
//  GamesView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-11.
//

import SwiftUI;
import SwiftData;
import CachedAsyncImage;

struct GamesView: View
{
    var platform:Platform?;
    
    @Environment(\.modelContext)
    private var modelContext;
    
    @Query(sort: \Game.title)
    var games: [Game];
    
    var body: some View
    {
        Grid
        {
            ForEach(self.games)
            { game in
                
                VStack
                {
                    if (game.coverUrl != nil)
                    {
                        CachedAsyncImage(url: URL(string: game.coverUrl!))
                        { phase in
                            switch phase
                            {
                            case .success(let image):
                                image.resizable();
                            default:
                                ProgressView().scaleEffect(0.5);
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(6)
                        .frame(width: 90, height: 160)
                        .shadow(radius: 30)
                    }
                    
                    Text(game.title);
                }
                
                
            }
        }
        .frame(minWidth: 256, minHeight: 256);
    }
}

#Preview
{
    GamesView().withTestGames();
}
