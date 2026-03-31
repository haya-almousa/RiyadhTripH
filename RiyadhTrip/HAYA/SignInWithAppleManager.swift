//
//  SignInWithAppleManager.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import UIKit

@MainActor
final class SignInWithAppleManager: NSObject {

    private var currentNonce: String?

    func startSignInWithAppleFlow() async throws -> AuthDataResult {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        return try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])

            controller.delegate = Delegate(
                nonce: nonce,
                onSuccess: { credential, fullName, email in
                    Task {
                        do {
                            let result = try await Auth.auth().signIn(with: credential)

                            if let fullName {
                                let formatter = PersonNameComponentsFormatter()
                                let nameString = formatter.string(from: fullName)
                                if !nameString.isEmpty {
                                    UserDefaults.standard.set(nameString, forKey: "apple_name")
                                }
                            }

                            if let email {
                                UserDefaults.standard.set(email, forKey: "apple_email")
                            }

                            continuation.resume(returning: result)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                },
                onFailure: { error in
                    continuation.resume(throwing: error)
                }
            )

            controller.presentationContextProvider = PresentationContextProvider()
            controller.performRequests()
        }
    }
}

private final class Delegate: NSObject, ASAuthorizationControllerDelegate {
    let nonce: String
    let onSuccess: (AuthCredential, PersonNameComponents?, String?) -> Void
    let onFailure: (Error) -> Void

    init(
        nonce: String,
        onSuccess: @escaping (AuthCredential, PersonNameComponents?, String?) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        self.nonce = nonce
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            onFailure(NSError(domain: "AppleSignIn", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to get identity token"]))
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        onSuccess(credential, appleIDCredential.fullName, appleIDCredential.email)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onFailure(error)
    }
}

private final class PresentationContextProvider: NSObject, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

// MARK: - Nonce helpers
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        var randoms = [UInt8](repeating: 0, count: 16)
        let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
        if status != errSecSuccess { fatalError("Unable to generate nonce") }

        randoms.forEach { random in
            if remainingLength == 0 { return }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}
