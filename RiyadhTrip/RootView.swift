//
//  RootView.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @State private var isLoggedIn = (Auth.auth().currentUser != nil)

    var body: some View {
        Group {
            if isLoggedIn {
                HomeView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            // يراقب تغيّر حالة الدخول تلقائي
            Auth.auth().addStateDidChangeListener { _, user in
                isLoggedIn = (user != nil)
            }
        }
    }
}
