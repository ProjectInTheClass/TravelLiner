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
        .modelContainer(for: TravelModel.self) // WindowGroup에 .modelContainer를 하게 되어 해당 윈도우 그룹안에 있는 우리가 만든 뷰들이 담기게되어 어느 뷰에서든 어디서든 접근이 가능하다.
    }
}
