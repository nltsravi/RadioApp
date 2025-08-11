//
//  AuthViewModel.swift
//  QSO Log app
//

import Foundation
import AuthenticationServices
import SwiftUI

struct UserAccount: Codable, Equatable {
    enum Provider: String, Codable { case apple, google, linkedin }
    var id: String
    var name: String?
    var email: String?
    var provider: Provider
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: UserAccount?
    @Published var isBusy: Bool = false
    @Published var errorMessage: String?
    
    private let storageKey = "auth.currentUser.v1"
    
    init() {
        loadFromStorage()
    }
    
    // MARK: - Sign in with Apple
    func signInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        // Optionally set state/nonce for security if used with backend
        request.state = UUID().uuidString
    }
    
    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            let userId = credential.user
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            let email = credential.email
            let user = UserAccount(id: userId, name: fullName.isEmpty ? nil : fullName, email: email, provider: .apple)
            currentUser = user
            saveToStorage(user)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Google (placeholder)
    func signInWithGoogle() {
        // TODO: Integrate GoogleSignIn SDK and call here. Placeholder for now.
        errorMessage = "Google Sign-In not configured. Add GoogleSignIn SDK and client ID."
    }
    
    // MARK: - LinkedIn (placeholder)
    func signInWithLinkedIn() {
        // TODO: Implement LinkedIn OAuth via ASWebAuthenticationSession with your client ID/redirect URI.
        errorMessage = "LinkedIn Sign-In not configured. Add OAuth client and redirect URI."
    }
    
    func signOut() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    // MARK: - Storage
    private func saveToStorage(_ user: UserAccount) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let user = try? JSONDecoder().decode(UserAccount.self, from: data) else { return }
        currentUser = user
    }
}


