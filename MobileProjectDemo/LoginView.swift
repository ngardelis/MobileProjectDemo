//
//  LoginView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

enum LanguageMode {
    case greek, english
}

struct LoginView: View {
    @ObservedObject var auth = Auth()
    @State var username: String = ""
    @State var password: String = ""
    @State var currentLanguage: LanguageMode = .greek
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 40) {
                CustomTextField(placeHolder: "UserID",
                                value: $username,
                                currentLanguage: $currentLanguage
                )
                CustomTextField(placeHolder: currentLanguage == .greek ? "Κωδικός" : "Password",
                                value: $password,
                                isPasswordField: true,
                                currentLanguage: $currentLanguage
                )
            }
            Spacer()
            ChangeLanguageView(currentLanguage: $currentLanguage)
            Spacer()
            Spacer()
            signInButton
        }
    }
    
    var signInButton: some View {
        Button { login() }
        label: {
            ZStack {
                Image("btn_rounded")
                Text(currentLanguage == .greek ? "Σύνδεση" : "Sign In")
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
    @Binding var currentLanguage: LanguageMode
    
    var body: some View {
        VStack {
            HStack {
                Text("\(placeHolder)").font(.title)
                Image("ic_info").padding(.horizontal, 5)
                Spacer()
                if isPasswordField {
                    Button {
                        showPassword.toggle()
                    } label: { 
                        Text(currentLanguage == .greek ? "Προβολή" : "Show")
                            .fontWeight(.semibold) }
                            .foregroundColor(Color("forest_green"))
                            .font(.title3)
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

struct ChangeLanguageView: View {
    @Binding var currentLanguage: LanguageMode
    @State var showLanguageOptions: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    if currentLanguage == .greek {
                        FlagAndLanguage(flagImage: "greece_flag_icon", languageText: "Greek")
                    } else if currentLanguage == .english {
                        FlagAndLanguage(flagImage: "usa_flag_icon", languageText: "English")
                    }
                    Spacer()
                    arrowButton
                }
                .padding(.horizontal)
                .frame(width: 200, height: 70)
                .background(Capsule().foregroundColor(Color("onyx")))
                .overlay(
                    VStack {
                        if showLanguageOptions {
                            Spacer(minLength: 70)
                            ZStack {
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(width: 200, height: 140)
                                    .foregroundColor(Color("onyx"))
                                VStack {
                                    FlagAndLanguage(flagImage: "usa_flag_icon", languageText: "English")
                                        .onTapGesture { 
                                            currentLanguage = .english
                                            showLanguageOptions.toggle()
                                        }
                                    FlagAndLanguage(flagImage: "greece_flag_icon", languageText: "Greek")
                                        .onTapGesture { 
                                            currentLanguage = .greek
                                            showLanguageOptions.toggle()
                                        }
                                }.padding(.leading)
                            }.offset(y: 5)
                        }
                    }.animation(.smooth(duration: 0.1)), alignment: .topLeading
                )
            }.padding(.horizontal, 35)
        }
    }
    
    var arrowButton: some View {
        Button { withAnimation { withAnimation { showLanguageOptions.toggle() } } }
        label: { Image("arrow_down") }
    }
}

struct FlagAndLanguage: View {
    var flagImage: String
    var languageText: String
    
    var body: some View {
        HStack {
           Image("\(flagImage)")
           Text("\(languageText)").foregroundColor(.white).font(.title2).offset(x: 5)
           Spacer()
        }
    }
}



















struct Login_Preview: PreviewProvider {
    static var previews: some View {
        let auth = Auth()
        LoginView(auth: auth)
    }
}


