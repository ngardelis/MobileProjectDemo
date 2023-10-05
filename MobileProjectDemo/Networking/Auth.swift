//
//  Auth.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

enum AuthError: Error {
    case invalidURL
    case unexpectedStatusCode
    case decodingError
}

final class Auth: ObservableObject {
    
    // Keep track if the user is logged in or not
    @Published private(set) var isLoggedIn = false
    
    // Keep track of the current accessToken to make authenticated requests
    @Published private(set) var accessToken: String?
    
    func login(username: String, password: String) async throws {
        let path = "https://3nt-demo-backend.azurewebsites.net/Access/Login"
        
        guard let url = URL(string: path) else { throw AuthError.invalidURL }
        
        var loginRequest = URLRequest(url: url)
        
        // Set the method to POST
        loginRequest.httpMethod = "POST"
        
        // Set Content-Type header
        loginRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Convert username and password into JSON data and set as the request's HTTP body
        let credentials = ["UserName": username, "Password": password]
        loginRequest.httpBody = try? JSONSerialization.data(withJSONObject: credentials)
        
        // Create a dataTask on the URL session, using the login request
        let (data, response) = try await URLSession.shared.data(for: loginRequest)
        
        // Ensure we get a 200 OK response
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw AuthError.unexpectedStatusCode
        }
        
        // Decode the JSON response using the LoginResponse model
        guard let loginData = try? JSONDecoder().decode(LoginResponse.self, from: data) else { throw AuthError.decodingError }
        
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.accessToken = loginData.access_token
        }
    }
}

// We use the Codable protocol so we can encode and decode everything
struct LoginResponse: Codable {
    let expires_in: Int
    let token_type: String
    let refresh_token: String
    let access_token: String
}
