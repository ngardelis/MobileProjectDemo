//
//  AvailableBooksVM.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 5/10/23.
//

import SwiftUI

// Enum to represent the state of book download
enum BookDownloadState {
    case pending, inProgress, completed
}

class BooksVM: ObservableObject {
    // Group books by date
    @Published var groupedBooks: [String: [Book]] = [:]
    // Keep track of the download states of the books
    @Published var bookDownloadStates: [Int: BookDownloadState] = [:]
    // Keep track of the selected PDF
    @Published var pdfData: Data?
    // If true, displays a share sheet to save or view the selected PDF
    @Published var isSavePresented = false

    private let auth: Auth
    private let bookService: BookService
    
    // Initializes the auth and book service, then fetches the books
    init(auth: Auth) {
        self.auth = auth
        self.bookService = BookService(auth: auth)
        fetchBooks()
    }

    // After being fetched, books are sorted by date
    func fetchBooks() {
        Task {
            do {
                var books = try await bookService.getBooks()
                books.sort {
                    guard let date1 = $0.releaseDate, let date2 = $1.releaseDate else {
                        return false
                    }
                    return date1 < date2
                }
                
                // Group books by month and year
                let newGroupedBooks = Dictionary(grouping: books) { book in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMMM yyyy"
                    return formatter.string(from: book.releaseDate ?? Date())
                }
                
                // Update the property on the main thread
                DispatchQueue.main.async {
                    self.groupedBooks = newGroupedBooks
                }
            }
        }
    }

    // Downloads the PDF for a given book
    func downloadPDF(for book: Book) {
        guard let url = URL(string: book.pdf_url) else { return }

        bookDownloadStates[book.id] = .inProgress

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    self.pdfData = data
                    self.bookDownloadStates[book.id] = .completed
                    self.isSavePresented = true
                } else {
                    print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                    self.bookDownloadStates[book.id] = .pending
                }
            }
        }.resume()
    }
}

//  This view controller displays a share sheet that provides users with various options for sharing content, such as messaging, email, saving to files, and more. Because SwiftUI does not natively offer a "share sheet", this structure acts as a bridge between SwiftUI and UIKit
struct ActivityViewController: UIViewControllerRepresentable {
//  An array of items that you want to share or perform actions on. This can include strings, images, URLs, and other types. These items will be passed to the apps and services in the share sheet
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

//  This function tells SwiftUI how to create the UIKit view controller. It is required by UIViewControllerRepresentable
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
