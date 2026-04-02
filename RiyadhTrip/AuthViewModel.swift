//
//  AuthViewModel.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    

    @Published var email: String = ""
    @Published var password: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var infoMessage: String = ""

    private let db = Firestore.firestore()
  //  private let apple = SignInWithAppleManager()//

    func signInEmail() async {
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            try await upsertUserDocumentIfNeeded(uid: result.user.uid, email: result.user.email, name: result.user.displayName)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUpEmail() async {
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await upsertUserDocumentIfNeeded(uid: result.user.uid, email: result.user.email, name: result.user.displayName)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInWithApple() async {
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
           // let result = try await apple.startSignInWithAppleFlow()
           // let uid = result.user.uid

            let savedName = UserDefaults.standard.string(forKey: "apple_name")
          //  let savedEmail = result.user.email ?? UserDefaults.standard.string(forKey: "apple_email")

         //   try await upsertUserDocumentIfNeeded(uid: uid, email: savedEmail, name: savedName)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword() async {
        errorMessage = ""
        infoMessage = ""
        guard !email.isEmpty else {
            errorMessage = "يرجى إدخال البريد الإلكتروني"
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
            infoMessage = "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        errorMessage = ""
        do { try Auth.auth().signOut() }
        catch { errorMessage = error.localizedDescription }
    }

    private func upsertUserDocumentIfNeeded(uid: String, email: String?, name: String?) async throws {
        let ref = db.collection("users").document(uid)
        let snap = try await ref.getDocument()
        if snap.exists { return }

        try await ref.setData([
            "email": email ?? "",
            "name": name ?? "",
            "role": "user",
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}

