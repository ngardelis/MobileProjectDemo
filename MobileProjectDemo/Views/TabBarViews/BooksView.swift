//
//  MainPageView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

struct BooksView: View {
    // Access to the shared auth object
    @EnvironmentObject var auth: Auth
    // The view model responsible for fetching and managing book data
    @ObservedObject var booksVM: BooksVM
    
    // Grid columns layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            TitleView("Περιοδικά")
            Spacer()
            ScrollView {
                // Iterates through each year of books
                ForEach(booksVM.groupedBooks.keys.sorted(), id: \.self) { key in
                    Section(header:
                        HStack {
                            Text(key).bold() // // Display the year/month as a header
                            Spacer()
                        }.padding(.leading, 20))
                    {
                        LazyVGrid(columns: columns, spacing: 20) {
                            // Iterate through each book in the current year/month
                            ForEach(booksVM.groupedBooks[key]!, id: \.title) { book in
                                VStack {
                                    ZStack(alignment: .bottom) {
                                        // Load and display book image asynchronously
                                        AsyncImage(url: URL(string: book.secureImageUrl)) { image in
                                            image.resizable()
                                        } placeholder: { ProgressView().font(.largeTitle) }
                                        .frame(width: 130, height: 170)
                                        // Display the download state of the book
                                        Text(downloadStateText(for: book))
                                            .font(.title3)
                                            .foregroundStyle(downloadStateColor(for: book))
                                            .padding(3)
                                            .background(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(.white)
                                            )
                                            .padding(5)
                                    }
                                    // Display the title of the book
                                    Text(book.title)
                                        .foregroundStyle(.white)
                                        .font(.subheadline)
                                }
                                // Download and view the selected PDF
                                .onTapGesture{ booksVM.downloadPDF(for: book) }
                                    .sheet(isPresented: $booksVM.isSavePresented){
                                        ActivityViewController(activityItems: [booksVM.pdfData!])
                                }
                            }
                        }
                    }
                }
            }
        }
        // Set the background color for the entire view
        .background(Color("dark"))
        // Upon appearing, fetch the list of books
        .onAppear() { Task { booksVM.fetchBooks } }
    }
    
    // Return the textual representation of the download state of a book
    func downloadStateText(for book: Book) -> String {
        let state = booksVM.bookDownloadStates[book.id] ?? .pending
        switch state {
        case .pending:
            return "Pending"
        case .inProgress:
            return "Downloading"
        case .completed:
            return "Downloaded"
        }
    }

    // Return the color representation of the download state of a book
    func downloadStateColor(for book: Book) -> Color {
        let state = booksVM.bookDownloadStates[book.id] ?? .pending
        switch state {
        case .pending:
            return .red
        case .inProgress:
            return .orange
        case .completed:
            return .green
        }
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


