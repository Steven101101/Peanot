//
//  ContentView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                TabView {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house") }
                    SearchView()
                        .tabItem { Label("Search", systemImage: "magnifyingglass") }
                }.tint(PeanotColors.primary)
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
