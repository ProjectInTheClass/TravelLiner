//  TravelListView.swift
//  TravelLiner
//
//  Created by 김재완 on 2024/02/18.
//

import SwiftUI

struct TravelListView: View {
    @State var days: [Days] // 여행의 각 일차 정보
    @State private var showDeleteAlert = false // 알림창 표시 여부
    @State private var indicesToDelete: (dayIndex: Int, placeIndex: Int)? // 삭제할 day의 인덱스와 place의 인덱스
    
    var body: some View {
        ScrollView {
            VStack {
                Text("=")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack {
                    Text("여행일정")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                
                LazyVStack(spacing: 16) {
                    ForEach(days.sorted(by: { $0.date < $1.date }), id: \.self) { day in
                            DaySectionView(day: day, onDeletePlace: { placeIndex in
                                self.indicesToDelete = (dayIndex: days.firstIndex(where: { $0.id == day.id }) ?? 0, placeIndex: placeIndex)
                                self.showDeleteAlert = true // 알림창 표시
                            })
                    }
                    .padding(.horizontal)
                    
                }
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("삭제하시겠습니까?"),
                message: Text("이 작업은 되돌릴 수 없습니다."),
                primaryButton: .destructive(Text("삭제하기")) {
                    if let indices = indicesToDelete {
                        days[indices.dayIndex].places.remove(at: indices.placeIndex)
                        indicesToDelete = nil // 인덱스 초기화
                    }
                },
                secondaryButton: .cancel {
                    indicesToDelete = nil // 인덱스 초기화
                }
            )
        }
    }
            
            struct DaySectionView: View {
                var day: Days
                var onDeletePlace: (Int) -> Void
                
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
                            PlaceRow(placeNumber: index + 1, placeName: day.places[index].name) {
                                onDeletePlace(index)
                            }
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
                var onDelete: () -> Void
                
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
                        
                        Button(action: {
                            onDelete()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(.trailing, 5)
                    }
                    .padding(.vertical, 10)
                    .background(Color(.white))
                    .cornerRadius(10)
                }
            }
        }
        //#Preview {
        //    TravelListView(days: days)
        //}
