//
//  AuthViewModel.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published State
    @Published var email: String = ""
    @Published var password: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - Email/Password Auth
    func signInEmail() async {
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            try await upsertUserDocumentIfNeeded(uid: result.user.uid, email: result.user.email)
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
            try await upsertUserDocumentIfNeeded(uid: result.user.uid, email: result.user.email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        errorMessage = ""
        do { try Auth.auth().signOut() }
        catch { errorMessage = error.localizedDescription }
    }

    // MARK: - Firestore helpers
    private func upsertUserDocumentIfNeeded(uid: String, email: String?) async throws {
        let ref = db.collection("users").document(uid)
        let snap = try await ref.getDocument()
        if snap.exists { return }

        try await ref.setData([
            "email": email ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}

