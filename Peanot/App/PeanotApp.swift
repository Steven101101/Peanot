//
//  PeanotApp.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI
import SwiftData

@main
struct PeanotApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: RecentScan.self)
    }
}
