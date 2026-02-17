//
//  AddTripView.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var budget = ""
    @State private var days = ""

    let onSave: (String, Double, Int) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Trip title", text: $title)
                TextField("Daily budget (SAR)", text: $budget).keyboardType(.decimalPad)
                TextField("Days", text: $days).keyboardType(.numberPad)
            }
            .navigationTitle("New Trip")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let b = Double(budget) ?? 0
                        let d = Int(days) ?? 0
                        onSave(title, b, d)
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
