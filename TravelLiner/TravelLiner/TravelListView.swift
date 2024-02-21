//  TravelListView.swift
//  TravelLiner
//
//  Created by 김재완 on 2024/02/18.
//

import SwiftUI

extension Array {
    mutating func move(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex,
              startIndex..<endIndex ~= sourceIndex,
              startIndex..<endIndex ~= destinationIndex else { return }
        let element = remove(at: sourceIndex)
        insert(element, at: destinationIndex)
    }
}

struct TravelListView: View {
    @State var days: [Days] // 여행의 각 일차 정보
    @State private var showDeleteAlert = false // 알림창 표시 여부
    @State private var indicesToDelete: (dayIndex: Int, placeIndex: Int)? // 삭제할 day의 인덱스와 place의 인덱스
    @State private var isEditing = false // 편집 모드 상태
    
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
                    Button(action: {
                        isEditing.toggle() // 편집 모드 토글
                    }) {
                        Text(isEditing ? "완료" : "편집")
                    }
                }
                .padding()
                
                LazyVStack(spacing: 16) {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(days.enumerated()), id: \.element) { index, day in
                            DaySectionView(dayIndex: index, days: $days, onDeletePlace: { placeIndex in
                                self.indicesToDelete = (dayIndex: index, placeIndex: placeIndex)
                                        self.showDeleteAlert = true // 알림창 표시
                            }, isEditing: isEditing)
                        }
                        .padding(.horizontal)
                    }
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
}

struct DaySectionView: View {
    var dayIndex: Int
    @Binding var days: [Days]
    var onDeletePlace: (Int) -> Void
    var isEditing: Bool // 편집 모드 상태 추가
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(dayIndex + 1) 일차")
                    .font(.headline)
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(10)
                .padding(.bottom, -4)
            
            ForEach(days[dayIndex].places.indices, id: \.self) { placeIndex in
                PlaceRow(
                    placeNumber: placeIndex + 1,
                    placeName: days[dayIndex].places[placeIndex].name,
                    onDelete: {
                        onDeletePlace(placeIndex)
                    },
                    onMoveUp: {
                        if placeIndex > 0 {
                            days[dayIndex].places.swapAt(placeIndex, placeIndex - 1)
                            days = days.map { $0 } // SwiftUI에 상태 변경 알림
                        }
                    },
                    onMoveDown: {
                        if placeIndex < days[dayIndex].places.count - 1 {
                            days[dayIndex].places.swapAt(placeIndex, placeIndex + 1)
                            days = days.map { $0 } // SwiftUI에 상태 변경 알림
                        }
                    },
                    isEditing: isEditing
                )
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
    var onMoveUp: () -> Void
    var onMoveDown: () -> Void
    var isEditing: Bool
    
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
            
            if isEditing { // 편집 모드일 때만 버튼 보여주기
//                Button(action: onMoveUp) {
//                    Image(systemName: "arrow.up")
//                        .foregroundColor(.blue)
//                }
//                .padding(.trailing, 5)
//                
//                Button(action: onMoveDown) {
//                    Image(systemName: "arrow.down")
//                        .foregroundColor(.blue)
//                }
//                .padding(.trailing, 5)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .padding(.trailing, 5)
            }
        }
        .padding(.vertical, 10)
        .background(Color(.white))
        .cornerRadius(10)
    }
}


//#Preview {
//    TravelListView(days: days)
//}
