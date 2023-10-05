//
//  MobileProjectDemoApp.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

@main
struct AppEntry: App {
    @StateObject var auth = Auth()

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                let booksVM = BooksVM(auth: auth)
                NavigationView(booksVM: booksVM)
                    .environmentObject(auth)
           } else {
               LoginView()
                   .environmentObject(auth)
           }
        }
    }
}




