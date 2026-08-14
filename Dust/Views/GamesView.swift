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
    
    var coverWidth:Float = 128;
    
    var coverHeight:Float
    {
        return (coverWidth / 9) * 14;
    }
    
    var body: some View
    {
        ScrollView
        {
            LazyVGrid(columns: [.init(.adaptive(minimum: CGFloat(coverWidth + 16)))])
            {
                ForEach(self.games)
                { game in
                    
                    VStack(alignment: .leading)
                    {
                        ZStack
                        {
                            if (game.coverUrl != nil)
                            {
                                Rectangle()
                                    .fill(Color.black);
                                
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
                                .aspectRatio(contentMode: .fill)
                            }
                            else
                            {
                                Rectangle()
                                    .fill(Color.gray)
                                    .opacity(0.2)
                            }
                        }
                        .cornerRadius(6)
                        .frame(width: CGFloat(coverWidth), height: CGFloat(coverHeight))
                        .shadow(radius: 30)
                        
                        VStack(alignment: .leading, spacing: 2)
                        {
                            Text(game.title).lineLimit(1);
                            
                            if (game.platform != nil)
                            {
                                HStack(alignment: .center, spacing: 2)
                                {
                                   IconView(iconName: game.platform!.iconName)
                                        .frame(width:14, height: 14)
                                    
                                    Text(game.platform!.name)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1);
                                }
                            }
                        }
                    }
                    .frame(width: CGFloat(coverWidth))
                    .padding(.bottom, 16)
                }
            }
        }
        .padding(16)
        .frame(minWidth: 256)
    }
}

#Preview
{
    GamesView().withTestGames();
}
