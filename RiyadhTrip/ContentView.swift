//
//  ContentView.swift
//  RiyadhTrip
//
//  Created by Haya almousa on 17/02/2026.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {

    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        RootView()
    }
}
