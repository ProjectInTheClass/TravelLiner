//
//  TravelLinerApp.swift
//  TravelLiner
//
//  Created by 안병욱 on 2/2/24.
//

import SwiftUI

@main
struct TravelLinerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: TravelModel.self)
    }
}
