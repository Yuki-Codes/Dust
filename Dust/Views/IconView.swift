//
//  IconView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import SwiftUI
import CachedAsyncImage

struct IconView: View
{
    var iconName:String;
    
    @Environment(\.colorScheme)
    var colorScheme;
    
    @Environment(IconifyClient.self)
    var iconifyClient:IconifyClient;
    
    var iconUrl:URL?
    {
        return iconifyClient.GetIconUrl(name: self.iconName);
    }
    
    var body: some View
    {
        CachedAsyncImage(url: self.iconUrl)
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
    }
}
