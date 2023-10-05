//
//  MainPageView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

struct AvailableBooksView: View {
    @EnvironmentObject var auth: Auth
    @State var books: [Book] = []
    var bookService: BookService
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    var body: some View {
        VStack {
            TitleView("Περιοδικά")
            Spacer()
            List(books, id: \.title) { book in
                Text("\(book.title)")
            }
        }
        .onAppear() { Task { loadData() } }
    }
    
    func loadData() {
        Task {
            let response = try await bookService.getBooks()
            if response.isEmpty { DispatchQueue.main.async { self.books = [] } }
            else { DispatchQueue.main.async { self.books = response } }
        }
    }
}





















struct Main_Preview: PreviewProvider {
    static var auth = Auth()
    static var bookService = BookService(auth: auth)
    
    static var previews: some View {
        AvailableBooksView(bookService: bookService)
            .environmentObject(auth)
    }
}


