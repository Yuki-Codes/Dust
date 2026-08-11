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
    
    @Environment(\.colorScheme)
    var colorScheme;
    
    @Query(sort: \Game.title)
    var games: [Game];
    
    var body: some View
    {
        let columns = [
            GridItem(.fixed(120), spacing: 20),
            GridItem(.fixed(120), spacing: 20),
            GridItem(.fixed(120), spacing: 20),
            GridItem(.fixed(120), spacing: 20)
        ]
        
        LazyVGrid(columns:columns)
        {
            ForEach(self.games)
            { game in
                
                VStack(alignment: .leading)
                {
                    Group
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
                        }
                        else
                        {
                            Rectangle()
                                .fill(Color.gray)
                                .opacity(0.2)
                        }
                    }
                    .cornerRadius(10)
                    .frame(height: 170)
                    .shadow(radius: 30)

                    VStack(alignment: .leading, spacing: 2)
                    {
                        Text(game.title).lineLimit(1);
                        
                        if (game.platform != nil)
                        {
                            HStack(spacing: 2)
                            {
                                if (game.platform!.iconUrl != "")
                                {
                                    CachedAsyncImage(url: URL(string: game.platform!.iconUrl))
                                    { phase in
                                        switch phase
                                        {
                                        case .success(let image):
                                            if colorScheme == ColorScheme.dark
                                            {
                                                image.resizable().colorInvert();
                                            }
                                            else
                                            {
                                                image.resizable();
                                            }
                                        default:
                                            ProgressView().scaleEffect(0.5);
                                        }
                                    }
                                    .frame(width:14, height: 14)
                                }
                                
                                Text(game.platform!.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary);
                            }
                        }
                    }
                }
                
                
            }
        }
        .frame(idealWidth: 1024, minHeight: 256);
    }
}

#Preview
{
    GamesView().withTestGames();
}
