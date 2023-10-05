//
//  BooksRequest.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 5/10/23.
//

import Foundation

// Enum to represent potential errors when fetching books
enum BookServiceError: Error {
    case missingAccessToken
    case invalidURL
    case serverError
    case invalidData
    case unknown(Error)
}

// Handle authenticated requests for books
final class BookService {
    private let auth: Auth // Dependency for authentication details
    
    // Initializer which sets the auth dependency
    init(auth: Auth) {
        self.auth = auth
    }
    
    // Get all Books
    func getBooks() async throws -> [Book] {
        // URL string for the book service
        let resourceString = "https://3nt-demo-backend.azurewebsites.net/Access/Books"
        
        // Convert the string to a URL object
        guard let resourceURL = URL(string: resourceString) else {
            throw BookServiceError.invalidURL
        }
        
        // Ensure there's an access token available for the request
        guard let token = auth.accessToken else {
            throw BookServiceError.missingAccessToken
        }
        
        // Create the request object
        var urlRequest = URLRequest(url: resourceURL)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            // Make the asynchronous call to fetch data
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Ensure the server responded with a 200 OK status
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw BookServiceError.serverError
            }
            
            // Decode the data into an array of Book objects
            guard let books = try? JSONDecoder().decode([Book].self, from: data) else {
                throw BookServiceError.invalidData
            }
            
            // Return the fetched books
            return books
        } catch {
            throw BookServiceError.unknown(error)
        }
    }
}

// Model for the structure of a book from the API
struct Book: Codable {
    let id: Int
    let title: String
    let img_url: String
    let date_released: String
    let pdf_url: String
    
    // Convert String to Date
    var releaseDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: date_released)
    }
}

