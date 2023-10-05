//
//  AvailableBooksVM.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 5/10/23.
//

import SwiftUI
import QuickLook

enum BookDownloadState {
    case pending, inProgress, completed
}

class BooksVM: ObservableObject {
    @Published var groupedBooks: [String: [Book]] = [:]

    // Private Properties
    private let auth: Auth
    private let bookService: BookService
    
    init(auth: Auth) {
        self.auth = auth
        self.bookService = BookService(auth: auth)
        fetchBooks()
    }

    // The objects must be sorted by date
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
            } catch {
                // Handle error
            }
        }
    }

    func downloadBook(_ book: Book) {
        
    }

    func showPDF(for book: Book) {
        // Implement functionality to show the PDF using QuickLook
    }
}

