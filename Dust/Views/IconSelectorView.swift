//
//  IconSelectorView.swift
//  Dust
//
//  Created by Yuki Walsh on 2026-08-14.
//

import SwiftUI

struct IconSelectorView: View
{
    @Binding
    var iconName: String;
    
    @Environment(IconifyClient.self)
    var iconifyClient:IconifyClient;
    
    @State
    private var searchTerm: String = "game console";

    @State
    private var searchResults: [String]?;
    
    @State
    private var isPopoverPresented: Bool = false;
    
    func BeginSearch()
    {
        _ = Task
        {
            return await self.SearchSafe();
        }
    }
    
    func SearchSafe() async
    {
        do
        {
            self.searchResults = try await iconifyClient.Search(term: searchTerm);
        }
        catch
        {
            print(error);
        }
    }
    
    var body: some View
    {
        HStack
        {
            TextField("Icon", text: $iconName);
            
            IconView(iconName: iconName)
                .frame(width: 16, height: 16);
            
            Button(action:
            {
                self.isPopoverPresented = true;
                self.BeginSearch();
            })
            {
                Image(systemName: "magnifyingglass");
            }
        }
        .popover(isPresented: $isPopoverPresented)
        {
            VStack
            {
                TextField("Search", text: $searchTerm)
                    .onSubmit(BeginSearch);
                
                Text("Icons provided by Iconify")
                    .font(Font.caption)
                    .opacity(0.5)
                
                if (self.searchResults != nil)
                {
                    ScrollView
                    {
                        LazyVGrid(columns: [.init(.adaptive(minimum: CGFloat(32)))])
                        {
                            ForEach(searchResults!, id: \.self)
                            { iconName in
                                Button(action:
                                {
                                    self.iconName = iconName;
                                    self.isPopoverPresented = false;
                                })
                                {
                                    IconView(iconName: iconName)
                                        .frame(width:32, height: 32);
                                }
                                .buttonStyle(.plain);
                            }
                        }
                    }
                    .frame(height: 100)
                }
                else
                {
                    Spacer()
                        .frame(height: 100)
                }
            }
            .frame(width: 300)
            .padding(16);
        }
    }
}

#Preview
{
    let testPlatform = Platform(name: "MacOS", iconName: "wpf:mac-os");
    PlatformSettingsView(platform: testPlatform)
        .frame(minWidth: 300, minHeight: 250)
        .padding(16);
}
