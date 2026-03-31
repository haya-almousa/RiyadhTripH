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
        ZStack {
            // Background Image
            Image("الدرعيه")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Dark overlay to make text readable
            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.55)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer(minLength: 60)

                // Title text on image (left aligned)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Discover The")
                        .font(.system(size: 42, weight: .bold))
                    Text("Best Places!")
                        .font(.system(size: 42, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

                Spacer()

                // Bottom Card
                VStack(spacing: 16) {

                    // Primary button
                    Button {
                        // مثال: تودين تفتحين صفحة إنشاء حساب
                        // أو تخليها تشتغل signUpEmail مباشرة حسب تصميمك
                        Task { await vm.signUpEmail() }
                    } label: {
                        ZStack {
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create New Account")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(Color(red: 0.73, green: 0.67, blue: 0.86)) // lavender قريب من الصورة
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .disabled(vm.isLoading)

                    // Secondary text
                    Button {
                        // مثال: تودين تفتحين صفحة تسجيل دخول
                        // أو signInEmail حسب تصميمك
                        Task { await vm.signInEmail() }
                    } label: {
                        Text("I already have an Account")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(red: 0.63, green: 0.53, blue: 0.78))
                    }
                    .buttonStyle(.plain)

                    // OR Divider
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.35))
                            .frame(height: 1)
                        Text("OR")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.gray.opacity(0.8))
                        Rectangle()
                            .fill(Color.gray.opacity(0.35))
                            .frame(height: 1)
                    }
                    .padding(.top, 2)

                    // Apple button
                    Button {
                        Task {
                            vm.errorMessage = ""
                            vm.isLoading = true
                            defer { vm.isLoading = false }
                            do { try await apple.startSignInWithAppleFlow() }
                            catch { vm.errorMessage = error.localizedDescription }
                        }
                    } label: {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.isLoading)

                    // Error message (optional)
                    if !vm.errorMessage.isEmpty {
                        Text(vm.errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 22)
                .padding(.bottom, 28)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 8)
                .padding(.bottom, 5)
            }
        }
    }
}
#Preview {
    AuthView()
}
