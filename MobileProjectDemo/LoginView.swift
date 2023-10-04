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

enum TextFieldMode {
    case userID, password, unowned
}

struct LoginView: View {
    @ObservedObject var auth = Auth()
    
    // User input states
    @State var username: String = ""
    @State var password: String = ""
    
    @State var currentLanguage: LanguageMode = .greek
    @State var textFieldMode: TextFieldMode = .unowned
    
    @State var showInfo: Bool = false
    @State var isValidUserID: Bool = true
    @State var isValidPassword: Bool = true
    @State private var showLoginAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    title
                    UserIDAndPasswordTextFieldsView(
                        username: $username,
                        password: $password,
                        currentLanguage: $currentLanguage,
                        showInfo: $showInfo,
                        textFieldMode: $textFieldMode,
                        isValidUserID: $isValidUserID,
                        isValidPassword: $isValidPassword,
                        size: geometry.size
                    )
                    Spacer()
                    ChangeLanguageView(currentLanguage: $currentLanguage)
                    Spacer()
                    Spacer()
                    signInButton
                }
                .background( Image("bg_gradient") )
                .ignoresSafeArea(.keyboard)
                .alert(isPresented: $showLoginAlert, content: loginAlert)
                if showInfo {
                    ShowInfoView(
                        showInfo: $showInfo,
                        currentLanguage: $currentLanguage,
                        textFieldMode: $textFieldMode
                    )
                }
            }
        }
    }
    
    private var title: some View {
        Rectangle()
            .frame(height: 120)
            .foregroundColor(.black)
            .overlay(
                Text(currentLanguage == . greek ? "Σύνδεση" : "Sign In")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .offset(y: 10)
            )
            .ignoresSafeArea()
    }
    
    // Don't allow the user to sign in if text fields are empty
    private var canSignIn: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    private var signInButton: some View {
        Button { 
            if !isValidUserID || !isValidPassword {
                showLoginAlert = true
            } else {
                login()
            }
        }
        label: {
            ZStack {
                Image("btn_rounded")
                Text(currentLanguage == .greek ? "Σύνδεση" : "Sign In")
                    .font(.title)
                    .foregroundColor(Color("dollar_bill"))
            }
        }
        .disabled(!canSignIn)
    }
    
    private func loginAlert() -> Alert {
        let titleText = currentLanguage == .greek ? "Λανθασμένα στοιχεία" : "Wrong credentials"
        let messageText = currentLanguage == .greek ? "Έχετε υποβάλει λάθος στοιχεία." : "You have submitted incorrect details."
        let buttonText = currentLanguage == .greek ? "Επιστροφή" : "Dismiss"
        
        return Alert(title: Text(titleText),
                     message: Text(messageText),
                     dismissButton: .default(Text(buttonText)))
    }
    
    func login() {
        Task {
            do { try await auth.login(username: username, password: password) }
            catch { print("Login Error") }
        }
    }
}

struct UserIDAndPasswordTextFieldsView: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var currentLanguage: LanguageMode
    @Binding var showInfo: Bool
    @Binding var textFieldMode: TextFieldMode
    @Binding var isValidUserID: Bool
    @Binding var isValidPassword: Bool
    var size: CGSize

    var body: some View {
        VStack(spacing: 40) {
            CustomTextField(placeHolder: "UserID",
                            value: $username,
                            currentLanguage: $currentLanguage,
                            showInfo: $showInfo,
                            textFieldMode: $textFieldMode,
                            isValidUserID: $isValidUserID,
                            isValidPassword: $isValidPassword,
                            size: size
            )
            CustomTextField(placeHolder: currentLanguage == .greek ? "Κωδικός" : "Password",
                            value: $password,
                            isPasswordField: true,
                            currentLanguage: $currentLanguage,
                            showInfo: $showInfo,
                            textFieldMode: $textFieldMode,
                            isValidUserID: $isValidUserID,
                            isValidPassword: $isValidPassword,
                            size: size
            )
        }
    }
}

struct CustomTextField: View {
    var placeHolder: String
    @Binding var value: String
    var isPasswordField: Bool = false
    @State var showPassword: Bool = false
    @Binding var currentLanguage: LanguageMode
    @Binding var showInfo: Bool
    @Binding var textFieldMode: TextFieldMode
    @Binding var isValidUserID: Bool
    @Binding var isValidPassword: Bool
    
    var size: CGSize
    
    // Declared as static so they aren't recreated every time the body renders
    private static let userIDRegex = "^[A-Z]{2}\\d{4}$"
    private static let passwordRegex = "^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*\\d.*\\d)(?=.*[a-z].*[a-z].*[a-z]).{8}$"
    
    var body: some View {
            VStack {
                header
                ZStack(alignment: .trailing) {
                    inputField
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(height: 20)
                    errorIcon
                }
                dividerBasedOnValidation
            }
            .frame(width: size.width * 0.8)
    }
    
    private var header: some View {
        HStack {
            Text("\(placeHolder)").font(.title).foregroundColor(.white)
            infoButton
            Spacer()
            if isPasswordField {
                showPasswordButton
            }
        }
    }
    
    private var errorIcon: some View {
        Group {
            if (isPasswordField && !isValidPassword) || (!isPasswordField && !isValidUserID) {
                Image("ic_error")
            }
        }
    }
    
    private var infoButton: some View {
        Button {
            if isPasswordField {
                textFieldMode = .password
            } else {
                textFieldMode = .userID
            }
            showInfo.toggle()
        } label: {
            Image("ic_info").padding(.horizontal, 5)
        }
    }
    
    @ViewBuilder
    private var inputField: some View {
        if isPasswordField {
            if showPassword {
                TextField("", text: $value)
                    .onChange(of: value, perform: validatePassword)
            } else {
                SecureField("", text: $value)
                    .onChange(of: value, perform: validatePassword)
            }
        } else {
            TextField("", text: $value)
                .onChange(of: value, perform: validateUserID)
        }
    }
    
    private var dividerBasedOnValidation: some View {
        Divider()
            .frame(height: 2)
            .background(dividerColor)
            .offset(y: -2)
    }
    
    private var dividerColor: Color {
        if isPasswordField {
            return isValidPassword ? Color("50a235_green") : .red
        } else {
            return isValidUserID ? Color("50a235_green") : .red
        }
    }
    
    private func validatePassword(_ password: String) {
        isValidPassword = password.isEmpty ? true : NSPredicate(format: "SELF MATCHES %@", CustomTextField.passwordRegex).evaluate(with: password)
    }

    private func validateUserID(_ userID: String) {
        isValidUserID = userID.isEmpty ? true : NSPredicate(format: "SELF MATCHES %@", CustomTextField.userIDRegex).evaluate(with: userID)
    }
    
    private var showPasswordButton: some View {
        Button {
            showPassword.toggle()
        } label: {
            Text(currentLanguage == .greek ? "Προβολή" : "Show")
                .fontWeight(.semibold)
        }
        .foregroundColor(Color("forest_green"))
        .font(.title3)
    }
}

struct ShowInfoView: View {
    @Binding var showInfo: Bool
    @Binding var currentLanguage: LanguageMode
    @Binding var textFieldMode: TextFieldMode
    
    var body: some View {
        ZStack(alignment: .center) {
            backgroundShape
            contentDisplay
        }
        .opacity(0.8)
        .background( Image("bg_gradient").opacity(0.1) )
        .ignoresSafeArea()
        .onTapGesture { showInfo.toggle() }
    }
    
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.black.opacity(0.7))
    }
    
    private var contentDisplay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 310, height: 80)
            if textFieldMode == .userID {
                userIDText
            } else if textFieldMode == .password {
                passwordText
            }
        }
    }
    
    private var userIDText: some View {
        VStack {
            if currentLanguage == .greek {
                Text("Πρέπει να ξεκινά")
                Text("με δύο κεφαλαία γράμματα")
                Text("και στη συνέχεια 4 αριθμούς.")
            } else {
                Text("Must start with two capital letters")
                Text("and afterwards 4 numbers.")
            }
        }
        .foregroundColor(.white)
        .font(.subheadline)
    }
    
    private var passwordText: some View {
        VStack {
            if currentLanguage == .greek {
                Text("τουλάχιστον 8 χαρακτήρες (2 κεφαλαία, ")
                Text("3 πεζά, 1 ειδικός χαρακτήρας, 2 νούμερα)")
            } else {
                Text("at least 8 characters")
                Text("(2 uppercase, 3 lowercase,")
                Text("1 special character, 2 numbers)")
            }
        }
        .foregroundColor(.white)
        .font(.subheadline)
    }
}

struct ChangeLanguageView: View {
    @Binding var currentLanguage: LanguageMode
    @State var showLanguageOptions: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                currentFlagAndLanguage
                    .padding(.horizontal)
                    .frame(width: 200, height: 70)
                    .background(Capsule().foregroundColor(Color("onyx")))
                    .overlay(
                        languageOptions.animation(.smooth(duration: 0.1), value: showLanguageOptions),
                        alignment: .topLeading
                    )
            }.padding(.horizontal, 35).offset(y: -5)
        }
    }
    
    private var currentFlagAndLanguage: some View {
        HStack {
            switch currentLanguage {
            case .greek:
                FlagAndLanguage(flagImage: "greece_flag_icon", languageText: "Greek")
            case .english:
                FlagAndLanguage(flagImage: "usa_flag_icon", languageText: "English")
            }
            Spacer()
            arrowButton
        }
    }
    
    private var languageOptions: some View {
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
        }
    }
    
    private var arrowButton: some View {
        Button { withAnimation { showLanguageOptions.toggle() } }
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


