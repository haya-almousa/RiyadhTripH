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
    @State private var handle: AuthStateDidChangeListenerHandle?

    var body: some View {
        Group {
            if isLoggedIn {
                HomeView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            guard handle == nil else { return }
            handle = Auth.auth().addStateDidChangeListener { _, user in
                isLoggedIn = (user != nil)
            }
        }
        .onDisappear {
            if let handle {
                Auth.auth().removeStateDidChangeListener(handle)
                self.handle = nil
            }
        }
    }
}
