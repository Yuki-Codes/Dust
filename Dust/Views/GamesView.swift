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
    
    @State var hover: Game? = nil;
    @State var background:String = "";
    @State var background2:String = "";
    @State var nextBackground:String = "";
    @State var backgroundLoaded:Bool = false;
    @State var background2Loaded:Bool = false;
    
    var coverWidth:Float = 128;
    

    
    var body: some View
    {
        ZStack
        {
            ForEach(self.games)
            { game in
                
                if (game.coverUrl != nil)
                {
                    CachedAsyncImage(url: URL(string: game.coverUrl!))
                    { phase in
                        switch phase
                        {
                        case .success(let image):
                            image.resizable();
                        default:
                            Rectangle();
                        }
                    }
                    .opacity(self.hover == game ? 1.0 : 0)
                    .animation(.easeInOut(duration: 1), value: self.hover)
                    .ignoresSafeArea()
                    .padding(-200)
                }
            }
            
            ScrollView
            {
                LazyVGrid(columns: [.init(.adaptive(minimum: CGFloat(coverWidth + 16)))])
                {
                    ForEach(self.games)
                    { game in
                        GameCoverView(game:game, coverWidth: coverWidth)
                        .onHover
                        { over in
                            if (over)
                            {
                                self.hover = game;
                            }
                            else if(self.hover == game)
                            {
                                self.hover = nil;
                            }
                        }
                    }
                }
            }
            .padding(16)
            .padding(.top, 32)
            .background(.regularMaterial)
        }
    }
}

#Preview
{
    GamesView()
        .withTestGames()
        .frame(width: 350);
}
