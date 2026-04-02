//
//  RiyadhTripApp.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import SwiftUI
import Firebase

@main
struct RiyadhTripApp: App {
    init() {
        FirebaseApp.configure()
        print("Configured Firebase")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
