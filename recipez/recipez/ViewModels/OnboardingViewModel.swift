//
//  OnboardingViewModel.swift
//  recipez
//
//  Created by Marcus Estrada on 2/20/23.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import SwiftUI

class OnboardingViewModel: NSObject, ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var currentOnboarding = OnBoardingType.signin
    @Published var formIsValid = false
    
    @Published var alertTitle = ""
    @Published var alertDetails = ""
    @Published var showAlert = false
    
    
    private let emailRegex = try! NSRegularExpression(pattern: "^\\S+@\\S+\\.\\S+$")
    private let passwordRegex = try! NSRegularExpression(pattern: "^.{8,}$")
    
    fileprivate var currentNonce: String?
    
    //MARK: alert functions
    
    func setAlert(title: String, details: String) {
        alertTitle = title
        alertDetails = details
        showAlert = true
    }
    
    func resetAlert() {
        alertTitle = ""
        alertDetails = ""
        showAlert = false
    }
    
    //MARK: Essential Database functions for onboarding
    
    private func storeNewUser(_ uid: String) {
        let db = Firestore.firestore()
        let users = db.collection("users")
        let userRef = users.document(uid)
        
        userRef.getDocument { doc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Error when fetching user document")
                return
            }
            
            //user already exists and should not create
            if let doc = doc, doc.exists {
                return
            }
        }
        
        print("Creating new user")
        userRef.setData([
            "name": "Anonymous",
            "shoppingList": [],
            "likedRecipes": [],
        ]) {
            error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    //MARK: Authentication
    
    func signInWithApple() {
        startSignInWithAppleFlow()
    }
    
    private func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = Application_utility.rootViewController
        authorizationController.performRequests()
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController) {
            user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let user = user?.user,
                let idToken = user.idToken else {return}
            
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) {
                result, error in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                self.storeNewUser(result!.user.uid)
            }
        }
    }
    
    func signInUser() {
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            if let err = error {
                print("Failed to sign in due to error:", err)
                self.setAlert(title: "Error Signing In", details: err.localizedDescription)
                return
            }
            print("Successfully signed in with ID: \(result?.user.uid ?? "")")
        }
    }
    
    func signUpUser() {
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            if let err = error {
                print("Failed to sign up due to error:", err.localizedDescription)
                self.setAlert(title: "Error Signing Up", details: err.localizedDescription)
                return
            }
            
            self.storeNewUser(result!.user.uid)
            
            print("Successfully created account with ID: \(result?.user.uid ?? "")")
        }
        
    }
    
    func forgotPassword() {
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

//for google sign in
final class Application_utility {
    static var rootViewController: UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return .init()}
        
        guard let root = screen.windows.first?.rootViewController else {return .init()}
        
        return root
    }
}

//for apple sign in
extension OnboardingViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
//            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
//                                                           rawNonce: nonce,
//                                                           fullName: appleIDCredential.fullName)
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                self.storeNewUser(result!.user.uid)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
