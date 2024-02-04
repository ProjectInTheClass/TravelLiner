//
//  Preview_sampleData.swift
//  TravelLiner
//
//  Created by 안병욱 on 2/2/24.
//

import SwiftUI
import SwiftData

@MainActor
let previewContainer_travel: ModelContainer = {
    do{
        let container = try ModelContainer(
            for: TravelModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        container.mainContext.insert(travel_dummy)
        return container
    } catch {
        fatalError("failed to create container")
    }
    return try! ModelContainer(for: TravelModel.self)
}()



let travel_dummy = TravelModel(
    title: "서울",
    days: [
    ],
    icon: "🚅",
    start_date: Date()
)

let days_dummy1 = Days(date: 1, places: [])
let days_dummy2 = Days(date: 1, places: [])
