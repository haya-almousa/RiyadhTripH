//
//  Trip.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import Foundation

struct Trip: Identifiable {
    let id: String
    let title: String
    let dailyBudget: Double
    let days: Int
    let createdAt: Date
}
