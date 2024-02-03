//
//  HomeView.swift
//  TravelMap
//
//  Created by 안병욱 on 1/26/24.
//

import SwiftUI
import SwiftData
import KakaoMapsSDK

struct HomeView: View {
    @Environment(\.colorScheme) var colorscheme
    @Query var travel: [TravelModel]
    @State var addTravel: Bool = false
    
//    let trip_previewList: [String] = ["제주도 성산일출봉", "경주 첨성대", "롯데타워", "나로 우주센터"]
//    let trip_location: [MapPoint] = [
//        MapPoint(longitude: 126.942250, latitude: 33.458528),
//        MapPoint(longitude: 129.21917, latitude: 35.83472),
//        MapPoint(longitude: 127.102778, latitude: 37.5125),
//        MapPoint(longitude:  127.5181524, latitude: 34.45357843)
//    ]
//    let trip_previewImage: [String] = ["🚌", "🚎", "🚕", "🚗"]
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    ForEach(travel) { travels in
                        NavigationLink {
                            //Text(trip_previewList[index] + "시작!")
                            TravelView(travel: travels)
                                .onAppear {
                                    print(travels.days.first?.places.first?.latitude ?? 0.0)
                                }
                        } label: {
                            HStack{
                                Text(travels.icon)
                                    .font(.title)
                                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                    .frame(width: 60, height: 60, alignment: .center)
                                    .background {
                                        Circle()
                                            .foregroundStyle(.foreground.opacity(0.2))
                                    }
                                    .padding(.leading, 3)
                                Text(travels.title)
                                    .tint(colorscheme == .dark ? Color.white : Color.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .padding()
                                    .tint(Color.secondary.opacity(0.3))
                            }
                            .padding(3)
                            .background {
                                Capsule()
                                    .foregroundStyle(.background)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                    }
                    Spacer()
                    Button {
                        self.addTravel.toggle()
                        
                    } label: {
                        HStack(alignment: .center){
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                            Text("새로운 여행 추가하기")
                            Spacer()
                        }
                        .padding(10)
                        .foregroundStyle(Color.secondary)
                        .background {
                            Capsule()
                                .foregroundStyle(.background)
                        }
                        .padding(20)
                        
                        .navigationTitle(Text("나의 여행"))
                    }
                    .sheet(isPresented: $addTravel) {
                        AddTravelView()
                    }
                    //Spacer().frame(height: 50)
                }
            }
            //.background(Color.secondary.opacity(0.3))
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    HomeView()
}
