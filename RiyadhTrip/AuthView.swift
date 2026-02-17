//
//  AuthView.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var vm = AuthViewModel()
    private let apple = SignInWithAppleManager()

    var body: some View {
        VStack(spacing: 16) {
            Text("RiyadhTrip")
                .font(.largeTitle).bold()

            VStack(spacing: 10) {
                TextField("Email", text: $vm.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $vm.password)
                    .textFieldStyle(.roundedBorder)
            }

            if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button {
                Task { await vm.signInEmail() }
            } label: {
                if vm.isLoading { ProgressView() }
                else { Text("Sign In") }
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isLoading)

            Button {
                Task { await vm.signUpEmail() }
            } label: {
                Text("Create Account")
            }
            .buttonStyle(.bordered)

            Divider().padding(.vertical, 8)

            Button {
                Task {
                    vm.errorMessage = ""
                    vm.isLoading = true
                    defer { vm.isLoading = false }

                    do { try await apple.startSignInWithAppleFlow() }
                    catch { vm.errorMessage = error.localizedDescription }
                }
            } label: {
                Text("Sign in with Apple")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(vm.isLoading)

            Spacer()
        }
        .padding()
        .frame(maxWidth: 420)
    }
}
