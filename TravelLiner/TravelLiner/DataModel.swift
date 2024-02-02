//
//  DataModel.swift
//  TravelMap
//
//  Created by 안병욱 on 1/31/24.
//

import SwiftData
import SwiftUI

@Model
class TravelModel: Identifiable, Hashable {
    var title: String
    @Relationship(.unique, deleteRule: .cascade) var days: [Days]
    var icon: String
    var start_date: Date?
    init(title: String, days: [Days], icon: String, start_date: Date) {
        self.title = title
        self.days = days
        self.icon = icon
        self.start_date = start_date
    }
}

@Model
class Days {
    var date: Int
    @Relationship(.unique, deleteRule: .cascade) var places: [Places]
    init(date: Int, places: [Places]) {
        self.date = date
        self.places = places
    }
}

@Model
class Places {
    var name: String
    var longitude: Double
    var latitude: Double
    init(name: String, longitude: Double, latitude: Double) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
    }
}
