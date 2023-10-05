//
//  MainPageView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

struct BooksView: View {
    @EnvironmentObject var auth: Auth
    @ObservedObject var booksVM: BooksVM
    
    var body: some View {
        VStack {
            TitleView("Περιοδικά")
            Spacer()
            List {
                ForEach(booksVM.groupedBooks.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(booksVM.groupedBooks[key]!, id: \.title) { book in
                            HStack {
                                Text(book.title)
                                Spacer()
                                Button("Download") {
                                    booksVM.downloadBook(book)
                                }
                                .padding(.trailing)
                                Button("Show PDF") {
                                    booksVM.showPDF(for: book)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .onAppear() { Task { booksVM.fetchBooks } }
    }
}

























struct Main_Preview: PreviewProvider {
    static var auth = Auth()
    
    static var previews: some View {
        let booksVM = BooksVM(auth: auth)
        BooksView(booksVM: booksVM)
            .environmentObject(auth)
    }
}


