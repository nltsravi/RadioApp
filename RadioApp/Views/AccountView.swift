//
//  AccountView.swift
//  QSO Log app
//
//  Lightweight account screen with Sign in options.
//

import SwiftUI
import AuthenticationServices

struct AccountView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var isSigningIn = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                    Text("Welcome")
                        .font(.largeTitle).bold()
                    Text("Sign in to sync your QSOs and settings across devices")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)

                VStack(spacing: 12) {
                    // Sign in with Apple
                    SignInWithAppleButton(.signIn, onRequest: { request in
                        isSigningIn = true
                        auth.signInWithAppleRequest(request)
                    }, onCompletion: { result in
                        isSigningIn = false
                        auth.handleSignInWithApple(result: result)
                    })
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    // Google
                    Button(action: { auth.signInWithGoogle() }) {
                        HStack(spacing: 10) {
                            Image(systemName: "g.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Sign in with Google")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 50)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                    // LinkedIn
                    Button(action: { auth.signInWithLinkedIn() }) {
                        HStack(spacing: 10) {
                            Image(systemName: "link.circle.fill")
                                .foregroundColor(Color(red: 0.0, green: 119/255.0, blue: 181/255.0))
                                .font(.title2)
                            Text("Sign in with LinkedIn")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 50)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                if isSigningIn { ProgressView().padding(.top, 8) }

                if let user = auth.currentUser {
                    VStack(spacing: 8) {
                        Text("Signed in as: \(user.name ?? user.email ?? "User")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("Sign Out") { auth.signOut() }
                            .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .background(AppTheme.groupBackground)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView { AccountView() }
}


