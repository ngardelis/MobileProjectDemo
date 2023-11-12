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
                            // Display the year/month as a header
                            Text(key).bold().foregroundStyle(.white)
                            Spacer()
                        }.padding(.leading, 20))
                    {
                        LazyVGrid(columns: columns, spacing: 20) {
                            // Iterate through each book in the current year/month
                            ForEach(booksVM.groupedBooks[key]!, id: \.title) { book in
                                VStack {
                                    ZStack(alignment: alignment(for: book)) {
                                        // Load and display book image asynchronously
                                        AsyncImage(url: URL(string: book.secureImageUrl)) { image in
                                            image.resizable()
                                        } placeholder: { ProgressView().font(.largeTitle) }
                                        .frame(width: 130, height: 170)
                                        // Display the download state of the book
                                        if downloadState(for: book) == .pending { Image("ic_download").resizable().frame(width: 50, height: 50)
                                        } else if downloadState(for: book) == .inProgress {
                                            ProgressView(value: 70, total: 100).frame(width: 130)
                                        } else if downloadState(for: book) == .completed {
                                            CompletedCheckImage()
                                        }
                                        
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
    func downloadState(for book: Book) -> BookDownloadState {
        return booksVM.bookDownloadStates[book.id] ?? .pending
    }

    func alignment(for book: Book) -> Alignment {
        let state = downloadState(for: book)
        switch state {
            case .pending:
                return .center
            case .inProgress:
                return .bottom
            case .completed:
                return .bottomTrailing
            }
    }
}

struct CompletedCheckImage: View {
    var body: some View {
        ZStack(alignment: .center) {
            RightTriangle()
                .fill(.green)
            Image("ic_check")
                .resizable()
                .frame(width: 20, height: 20)
                .offset(x: 10, y: 10)
        }
        .frame(width: 50, height: 50)
    }
}

struct RightTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// Sample data to use in preview
extension Book {
    static let sampleBooks: [Book] = [
        Book(id: 1,
             title: "Physician, The",
             img_url: "http://dummyimage.com/250x250.png/5fa2dd/ffffff",
             date_released: "2020-07-23T00:42:35Z",
             pdf_url: "https://www.learningcontainer.com/wp-content/uploads/2019/09/sample-pdf-download-10-mb.pdf"),
        
        Book(id: 2,
             title: "Bakeneko: A",
             img_url: "http://dummyimage.com/250x250.png/ff4444/ffffff",
             date_released: "2020-01-15T09:16:36Z",
             pdf_url: "https://www.learningcontainer.com/wp-content/uploads/2019/09/sample-pdf-with-images.pdf")
    ]
}

struct BooksView_Previews: PreviewProvider {
    static var previews: some View {
        BooksView(booksVM: mockedBooksVM())
            .environmentObject(Auth())
    }
    
    static func mockedBooksVM() -> BooksVM {
        let vm = BooksVM(auth: Auth())
        vm.groupedBooks = ["2020": Book.sampleBooks]
       // vm.bookDownloadStates = [1: .completed, 2: .inProgress]
        return vm
    }
}


