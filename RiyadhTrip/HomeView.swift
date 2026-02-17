//
//  HomeView.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var trips: [Trip] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    @State private var showAdd = false

    private let service = TripService()

    var body: some View {
        NavigationStack {
            List {
                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundStyle(.red)
                }

                ForEach(trips) { trip in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(trip.title).font(.headline)
                        Text("Daily budget: \(trip.dailyBudget, specifier: "%.0f") SAR • Days: \(trip.days)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign out") {
                        do { try Auth.auth().signOut() }
                        catch { errorMessage = error.localizedDescription }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("+ Add") { showAdd = true }
                }
            }
            .task { await loadTrips() }
            .refreshable { await loadTrips() }
            .sheet(isPresented: $showAdd) {
                AddTripView { title, budget, days in
                    Task {
                        do {
                            try await service.addTrip(title: title, dailyBudget: budget, days: days)
                            await loadTrips()
                            showAdd = false
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }

    private func loadTrips() async {
        errorMessage = ""
        isLoading = true
        defer { isLoading = false }

        do {
            trips = try await service.fetchTrips()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

