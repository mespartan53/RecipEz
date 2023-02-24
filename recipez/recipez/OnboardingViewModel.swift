//
//  OnboardingViewModel.swift
//  recipez
//
//  Created by Marcus Estrada on 2/20/23.
//

import Foundation
import FirebaseAuth

class OnboardingViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var currentOnboarding = OnBoardingType.signin
    @Published var formIsValid = false
    
    
    private let emailRegex = try! NSRegularExpression(pattern: "^\\S+@\\S+\\.\\S+$")
    private let passwordRegex = try! NSRegularExpression(pattern: "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{8,}$")
    
    
    func signInUser() {
        print("Signing in user email: \(email) --- password \(password)")
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            if let err = error {
                print("Failed to sign in due to error:", err)
                return
            }
            print("Successfully signed in with ID: \(result?.user.uid ?? "")")
        }
    }
    
    func signUpUser() {
        print("Signing up user email: \(email)")
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            if let err = error {
                print("Failed to sign up due to error:", err)
                return
            }
            print("Successfully created account with ID: \(result?.user.uid ?? "")")
        }
    }
    
    func forgotPassword() {
        print("Retrieving user password for: \(email)")
        Auth.auth().sendPasswordReset(withEmail: email) {
            error in
            if let err = error {
                print("Could not send email to reset password due to error:", err)
                return
            }
        }
    }
    
    func validateForm() {
        var isEmailValid = false
        var isPasswordValid = false
        switch (currentOnboarding) {
        case .signup:
            isEmailValid = validateEmail()
            isPasswordValid = validatePassword()
            if isEmailValid && isPasswordValid {
                formIsValid = true
            } else {
                formIsValid = false
            }
            break
        case .signin:
            isEmailValid = validateEmail()
            isPasswordValid = validatePassword()
            if isEmailValid && isPasswordValid {
                formIsValid = true
            } else {
                formIsValid = false
            }
            break
        case .forgot:
            isEmailValid = validateEmail()
            if isEmailValid {
                formIsValid = true
            } else {
                formIsValid = false
            }
            break
        default:
            formIsValid = false
        }
    }
    
    private func validateEmail() -> Bool {
        let range = NSRange(location: 0, length: email.utf16.count)
        let matches = emailRegex.matches(in: email, options: [], range: range)
        return !matches.isEmpty
    }
    
    private func validatePassword() -> Bool {
        let range = NSRange(location: 0, length: password.utf16.count)
        let matches = passwordRegex.matches(in: password, options: [], range: range)
        return !matches.isEmpty
    }
}

enum OnBoardingType {
    case signin
    case signup
    case forgot
    case none
}
