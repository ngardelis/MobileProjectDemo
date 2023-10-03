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
            Spacer()
            VStack(spacing: 40) {
                CustomTextField(placeHolder: "UserID", value: $username)
                CustomTextField(placeHolder: "Κωδικός", value: $password, isPasswordField: true)
            }
            Spacer()
            signInButton
        }
    }
    
    var signInButton: some View {
        Button { login() }
        label: {
            ZStack {
                Image("btn_rounded")
                Text("Σύνδεση")
                    .font(.title)
                    .foregroundColor(Color("dollar_bill"))
            }
        }
    }
    
    func login() {
        Task {
            guard (try? await auth.login(username: username, password: password)) != nil 
            else { fatalError("Wrong Credentials") }
        }
    }
}

struct CustomTextField: View {
    var placeHolder: String
    @Binding var value: String
    var isPasswordField: Bool = false
    @State var showPassword: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("\(placeHolder)").font(.title)
                Image("ic_info").padding(.horizontal, 5)
                Spacer()
                if isPasswordField {
                    Button {
                        showPassword.toggle()
                    } label: { Text("Προβολή").fontWeight(.semibold) }
                    .foregroundColor(Color("forest_green")).font(.title3)
                }
            }
            if isPasswordField && showPassword {
                TextField("", text: $value).font(.title3).frame(height: 20)
            } else if isPasswordField {
                SecureField("", text: $value).font(.title3).frame(height: 20)
            } else {
                TextField("", text: $value).font(.title3).frame(height: 20)
            }
            Divider()
             .frame(height: 2)
             .background(Color("50a235_green"))
             .offset(y: -2)
        }.frame(width: 300)
    }
}

















struct Login_Preview: PreviewProvider {
    static var previews: some View {
        let auth = Auth()
        LoginView(auth: auth)
    }
}


