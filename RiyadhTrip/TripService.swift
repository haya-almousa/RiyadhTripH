//
//  TripService.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class TripService {
    private let db = Firestore.firestore()

    private func tripsRef(for uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("trips")
    }

    func addTrip(title: String, dailyBudget: Double, days: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw URLError(.userAuthenticationRequired) }

        let data: [String: Any] = [
            "title": title,
            "dailyBudget": dailyBudget,
            "days": days,
            "createdAt": FieldValue.serverTimestamp()
        ]

        _ = try await tripsRef(for: uid).addDocument(data: data)
    }

    func fetchTrips() async throws -> [Trip] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let snap = try await tripsRef(for: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snap.documents.compactMap { doc in
            let data = doc.data()
            let title = data["title"] as? String ?? ""
            let dailyBudget = data["dailyBudget"] as? Double ?? 0
            let days = data["days"] as? Int ?? 0
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

            return Trip(id: doc.documentID, title: title, dailyBudget: dailyBudget, days: days, createdAt: createdAt)
        }
    }
}
