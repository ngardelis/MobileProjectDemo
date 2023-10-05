//
//  LoginView.swift
//  MobileProjectDemo
//
//  Created by nikos gardelis on 3/10/23.
//

import SwiftUI

// Represents the current language mode for the app
enum LanguageMode {
    case greek, english
}

// Represents which text field the user is currently interacting with
enum TextFieldMode {
    case userID, password, unowned
}

struct LoginView: View {
    @EnvironmentObject var auth: Auth
    
    // User input states
    @State var username: String = ""
    @State var password: String = ""
    
    // Current app's language
    @State var currentLanguage: LanguageMode = .greek
    // Which text field the user is currently interacting with
    @State var textFieldMode: TextFieldMode = .unowned
    
    @State var showInfo: Bool = false
    @State var isValidUserID: Bool = true
    @State var isValidPassword: Bool = true
    @State private var showLoginAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    TitleView(currentLanguage == .greek ? "Σύνδεση" : "Sign In")
                    // User Input fields
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
                    // Language toggle view
                    ChangeLanguageView(currentLanguage: $currentLanguage)
                    Spacer()
                    Spacer()
                    signInButton
                }
                .background( Image("bg_gradient") )
                .ignoresSafeArea(.keyboard)
                .alert(isPresented: $showLoginAlert, content: loginAlert)
                // Display regex hints
                if showInfo {
                    ShowInfoView(
                        showInfo: $showInfo,
                        currentLanguage: $currentLanguage,
                        textFieldMode: $textFieldMode,
                        size: geometry.size
                    )
                }
            }
        }
    }
    
    // Don't allow the user to sign in if text fields are empty
    private var canSignIn: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    private var signInButton: some View {
        Button { 
            // Display alert if userID or password is invalid, else proceed to login
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
                    .foregroundStyle(Color("dollar_bill"))
            }
        }
        .disabled(!canSignIn)
    }
    
    // Construct the alert that's shown when invalid login details are provided
    private func loginAlert() -> Alert {
        let titleText = currentLanguage == .greek ? "Λανθασμένα στοιχεία" : "Wrong credentials"
        let messageText = currentLanguage == .greek ? "Έχετε υποβάλει λάθος στοιχεία" : "You have submitted incorrect details"
        let buttonText = currentLanguage == .greek ? "Επιστροφή" : "Dismiss"
        
        return Alert(title: Text(titleText),
                     message: Text(messageText),
                     dismissButton: .default(Text(buttonText)))
    }
    
    // Asynchronous function to authenticate the user using the provided credentials
    func login() {
        Task { do { try await auth.login(username: username, password: password) } }
    }
}

// A View displaying both user ID and password text fields
struct UserIDAndPasswordTextFieldsView: View {
    // Binding properties to manage the text field data and states
    @Binding var username: String
    @Binding var password: String
    @Binding var currentLanguage: LanguageMode
    @Binding var showInfo: Bool
    @Binding var textFieldMode: TextFieldMode
    @Binding var isValidUserID: Bool
    @Binding var isValidPassword: Bool
    var size: CGSize // Size of the parent view

    var body: some View {
        VStack(spacing: 40) {
            // Text field for the username input
            CustomTextField(
                placeHolder: "UserID",
                value: $username,
                currentLanguage: $currentLanguage,
                showInfo: $showInfo,
                textFieldMode: $textFieldMode,
                isValidUserID: $isValidUserID,
                isValidPassword: $isValidPassword,
                size: size
            )
            // Text field for the password input
            CustomTextField(
                placeHolder: currentLanguage == .greek ? "Κωδικός" : "Password",
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

// A Customized TextField view with built-in validation, show password, and info functionalities
struct CustomTextField: View {
    var placeHolder: String
    @Binding var value: String
    var isPasswordField: Bool = false // Indicates if this is a password field
    @State var showPassword: Bool = false
    @Binding var currentLanguage: LanguageMode
    @Binding var showInfo: Bool
    @Binding var textFieldMode: TextFieldMode
    @Binding var isValidUserID: Bool
    @Binding var isValidPassword: Bool
    
    var size: CGSize // Size of the parent view
    
    // Regex patterns for user ID and password validations
    // Declared as static so they aren't recreated every time the body renders
    private static let userIDRegex = "^[A-Z]{2}\\d{4}$"
    private static let passwordRegex = "^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*\\d.*\\d)(?=.*[a-z].*[a-z].*[a-z]).{8}$"
    
    var body: some View {
            VStack {
                header // The header section containing the placeholder and the info button
                ZStack(alignment: .trailing) {
                    inputField
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(height: 20)
                    errorIcon
                }
                dividerBasedOnValidation
            }
            .frame(width: size.width * 0.8)
    }
    
    private var header: some View {
        HStack {
            Text("\(placeHolder)").font(.title).foregroundStyle(.white)
            infoButton // Button to display regex information
            Spacer()
            if isPasswordField {
                showPasswordButton // Button to toggle password visibility
            }
        }
    }
    
    // Display the error icon based on the validation results
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
        // Display either a secure or regular text field based on the `isPasswordField` property
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
            .background(dividerColor) // Color based on validation state
            .offset(y: -2)
    }
    
    private var dividerColor: Color {
        // Determine the divider color based on validation state
        if isPasswordField {
            return isValidPassword ? Color("50a235_green") : .red
        } else {
            return isValidUserID ? Color("50a235_green") : .red
        }
    }
    
    // Function to validate password based on the regex pattern
    private func validatePassword(_ password: String) {
        // If the password is empty, consider it valid. Else, use the regex to validate
        isValidPassword = password.isEmpty ? true : NSPredicate(format: "SELF MATCHES %@", CustomTextField.passwordRegex).evaluate(with: password)
    }

    // Function to validate user ID based on the regex pattern
    private func validateUserID(_ userID: String) {
        // If the userID is empty, consider it valid. Else, use the regex to validate
        isValidUserID = userID.isEmpty ? true : NSPredicate(format: "SELF MATCHES %@", CustomTextField.userIDRegex).evaluate(with: userID)
    }
    
    // View for the "show password" button, with text based on the current language
    private var showPasswordButton: some View {
        Button {
            showPassword.toggle()
        } label: {
            Text(currentLanguage == .greek ? "Προβολή" : "Show")
                .fontWeight(.semibold)
        }
        .foregroundStyle(Color("forest_green"))
        .font(.title3)
    }
}

// A view component to display regex information about the current text field (either username or password) the user interacts with
struct ShowInfoView: View {
    @Binding var showInfo: Bool
    @Binding var currentLanguage: LanguageMode
    @Binding var textFieldMode: TextFieldMode
    
    var size: CGSize
    
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle().fill(Color("onyx"))
            contentDisplay
        }
        .opacity(0.9)
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
                .frame(width: size.width * 0.85, height: 100)
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
                Text("και στη συνέχεια 4 αριθμούς")
            } else {
                Text("Must start with two capital letters")
                Text("and afterwards 4 numbers")
            }
        }
        .foregroundStyle(.white)
        .font(.system(size: min(size.width / 10, 18)))
    }
    
    private var passwordText: some View {
        VStack {
            if currentLanguage == .greek {
                Text("τουλάχιστον 8 χαρακτήρες")
                Text("(2 κεφαλαία, 3 πεζά,")
                Text("1 ειδικός χαρακτήρας, 2 νούμερα)")
            } else {
                Text("at least 8 characters")
                Text("(2 uppercase, 3 lowercase,")
                Text("1 special character, 2 numbers)")
            }
        }
        .foregroundStyle(.white)
        .font(.system(size: min(size.width / 10, 18)))
    }
}

// A view component to allow users to change the app's language mode
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
                    .background(Capsule().foregroundStyle(Color("onyx")))
                    .overlay(
                        languageOptions.animation(.smooth(duration: 0.1), value: showLanguageOptions),
                        alignment: .topLeading
                    )
            }.padding(.horizontal, 30).offset(y: -5)
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
                        .foregroundStyle(Color("onyx"))
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
           Text("\(languageText)").foregroundStyle(.white).font(.title2).offset(x: 5)
           Spacer()
        }
    }
}



















struct Login_Preview: PreviewProvider {
    static var previews: some View {
        @StateObject var auth = Auth()
        LoginView()
            .environmentObject(auth)
    }
}


