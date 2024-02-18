//
//  TravelListView.swift
//  TravelLiner
//
//  Created by 김재완 on 2024/02/18.
//

import SwiftUI

struct TravelListView: View {
    var days: [Days] // 여행의 각 일차 정보
    
    var body: some View {
        ScrollView {
            VStack {
                Text("=")
                    .font(.subheadline)
                HStack {
                    Text("여행일정")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                
                LazyVStack(spacing: 16) { // 섹션 간격을 16으로 설정
                    ForEach(days.sorted(by: { $0.date < $1.date }), id: \.self) { day in
                        DaySectionView(day: day)
                        
                        if day.date < days.max(by: { $0.date < $1.date })?.date ?? day.date {
                                                    Divider()
                                                        .background(Color.black) // Divider 색상을 검은색으로 설정
                                                }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
struct DaySectionView: View {
    var day: Days

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(day.date) 일차")
                .font(.headline)
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray5)) // 시스템 그레이 색상 사용
                .cornerRadius(10)
                .padding(.bottom, -4) // 섹션 헤더와 항목 사이의 간격

            ForEach(day.places.indices, id: \.self) { index in
                PlaceRow(placeNumber: index + 1, placeName: day.places[index].name)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 5)
        }
        .padding(.bottom, 10)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct PlaceRow: View {
    var placeNumber: Int
    var placeName: String

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                Text("\(placeNumber)")
                    .foregroundColor(.white)
            }
            .padding(.leading, 5)

            Text(placeName)
                .padding(.leading, 5)

            Spacer()

            Image(systemName: "line.horizontal.3")
                .foregroundColor(.gray)
                .padding(.trailing, 5)
        }
        .padding(.vertical, 10)
        .background(Color(.white)) // 항목 배경색
        .cornerRadius(10)
    }
}

//#Preview {
//    TravelListView(days: days)
//}
