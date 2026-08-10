//
//  ContentView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-07-27.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct MainView: View
{
    @State
    private var platformId: UUID?;

    @Environment(\.colorScheme)
    var colorScheme;
    
    @Query(sort: \Platform.sortName)
    var platforms: [Platform];

    var body: some View
    {
        NavigationSplitView
        {
            VStack
            {
                List(platforms, selection: $platformId)
                { platform in
                    HStack
                    {
                        if (platform.iconUrl != nil)
                        {
                            CachedAsyncImage(url: URL(string: platform.iconUrl!))
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
                            .frame(width: 20, height: 20)
                            Text(platform.name);
                        }
                        else
                        {
                            Text(platform.name).padding(Edge.Set.leading, 30);
                        }
                    }
                };
            }
        }
    
        detail:
        {
            Text(platformId?.uuidString ?? "No Selection");
        }
    }
}

#Preview
{
    return MainView().withTestPlatforms();
}
