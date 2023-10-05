//
//  NavigationView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 5/10/23.
//

import SwiftUI

enum NavigationTab: String, CaseIterable {
    // Icons for each navigation tab
    case books = "ic_book"
    case misc = "ic_misc"
    case profile = "ic_link"
    case settings = "ic_settings"
}

struct NavigationView: View {
    // Current active navigation tab
    @State private var currentNavTab: NavigationTab = .books
    
    @EnvironmentObject var auth: Auth
    var bookService: BookService
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    var body: some View {
        VStack {
            mainContent
            tabBar
        }
        .ignoresSafeArea(edges: .bottom) // Make sure the tab bar is placed to the bottom of the screen
    }
    
    // View Content based on the selected tab
    private var mainContent: some View {
        TabView(selection: $currentNavTab) {
            AvailableBooksView(bookService: bookService).tag(NavigationTab.books)
            MiscView().tag(NavigationTab.misc)
            ProfileView().tag(NavigationTab.profile)
            SettingsView().tag(NavigationTab.settings)
        }
    }
    
    // Custom tab bar view
    private var tabBar: some View {
        ZStack {
            Image("tabs_bg")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.bottom)
            Image("tabs_wave")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.bottom)
            HStack(spacing: 0) {
                // First half of the tabs
                ForEach(NavigationTab.allCases.prefix(2), id: \.rawValue) { tab in
                    tabButton(for: tab)
                }
                // Middle button
                Button { }
                label: {
                    Image("btn_play")
                        .resizable()
                        .frame(width: 76, height: 76)
                        .padding(.horizontal, 12)
                }
                // Second half of the tabs
                ForEach(NavigationTab.allCases.dropFirst(2), id: \.rawValue) { tab in
                    tabButton(for: tab)
                }
            }
        }
    }
    
    // Generates a button view for each navigation tab
    private func tabButton(for tab: NavigationTab) -> some View {
        TabButton(
            imageName: tab.rawValue,
            isSelected: currentNavTab == tab,
            action: { currentNavTab = tab }
        )
    }
}

// Represents a button in the custom tab bar
struct TabButton: View {
    let imageName: String // Image for the button
    let isSelected: Bool // Indicates if this tab is currently active
    let action: () -> Void // Action to perform when this tab button is tapped
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundStyle(isSelected ? Color("forest_green") : .black)
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .onTapGesture(perform: action) // Handle tab selection
    }
}

struct Navigation_Preview: PreviewProvider {
    static var auth = Auth()
    static var bookService = BookService(auth: auth)
    
    static var previews: some View {
        NavigationView(bookService: bookService)
            .environmentObject(auth)
    }
}
