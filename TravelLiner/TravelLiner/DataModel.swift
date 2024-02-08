//
//  DataModel.swift
//  TravelMap
//
//  Created by 안병욱 on 1/31/24.
//

import SwiftData
import SwiftUI

@Model //모델임을 알림
class TravelModel: Identifiable, Hashable {
    var title: String // 여행 제목
    @Relationship(.unique, deleteRule: .cascade) var days: [Days]
    var icon: String // 여행 아이콘
    var start_date: Date? // 여행 출발 날짜
    init(title: String, days: [Days], icon: String, start_date: Date) {
        self.title = title
        self.days = days
        self.icon = icon
        self.start_date = start_date
    }
}

@Model
class Days { //해당 일차에 장소 리스트가 담기게 된다
    var date: Int // 몇일차인지 1이면 1일차 2면 2일차 이런식
    @Relationship(.unique, deleteRule: .cascade) var places: [Places]
    init(date: Int, places: [Places]) {
        self.date = date
        self.places = places
    }
}

@Model
class Places { // 해당 위치에 대한 기본 정보가 담긴다.
    var name: String // 위치 이름으로 Rest API를 통해 이름을 가져옴
    var longitude: Double // KakapMap에서 Mappoint를 이용해서 위치를 잡게 되는데 SwiftData에서 Mappoint 사용이 안됨 따라서 Mappoint에서 사용하는 위도 경도 데이터를 따로 저장
    var latitude: Double
    var sequence: Int // 장소 순서
    init(name: String, longitude: Double, latitude: Double, sequence: Int) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.sequence = sequence
    }
}
