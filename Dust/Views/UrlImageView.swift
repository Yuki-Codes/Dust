//
//  UrlImageView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct UrlImageView: View
{
    var url: String;
    var contentMode: ContentMode = .fit;
    
    @State
    var loaded:Bool = false;
    
    var body: some View
    {
        CachedAsyncImage(url: URL(string: self.url))
        { phase in
            switch phase
            {
            case .success(let image):
                image.resizable()
                    .onAppear()
                {
                    self.loaded = true;
                }
            default:
                Rectangle();
            }
        }
        .opacity(self.loaded ? 1.0 : 0)
        .animation(.easeInOut(duration: 0.25), value: self.loaded)
        .aspectRatio(contentMode: self.contentMode);
    }
}
