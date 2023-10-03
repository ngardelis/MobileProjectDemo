//
//  LoginView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var auth = Auth()
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            TextField("username", text: $username)
            TextField("password", text: $password)
            
            Button(action: {
                login()
            }, label: {
                Text("Sign in")
            })
        }
    }
    
    func login() {
        Task {
            guard (try? await auth.login(username: username, password: password)) != nil 
            else { fatalError("Wrong Credentials") }
        }
    }
}

struct Login_Preview: PreviewProvider {
    static var previews: some View {
        let auth = Auth()
        LoginView(auth: auth)
    }
}


