//
//  TravelView.swift
//  TravelMap
//
//  Created by 안병욱 on 1/27/24.
//

import SwiftUI
import SwiftData
import KakaoMapsSDK

struct TravelView: View {
    @State var draw: Bool = true // 카카오맵 그리기 그리고 지우기 확인용
    @State var tap: Bool = false // 지도 누름 감지
    @State var search_toggle: Bool = false // 돋보기 검색 누름 확인
    @State var search_input: String = "" // 검색어필드
    @State var day: Int = 1 // 선택된 날짜
    @Bindable var travel: TravelModel // 데이터
    @StateObject var searchPlacce: KakaoSearchPlace = KakaoSearchPlace() // 검색 클래스
    //var title: String
    //var position: MapPoint
    var body: some View {
        ZStack{
            
            KakaoMapView(draw: $draw, tap: $tap, day: $day, travel: self.travel)
                .onTapGesture {
                    self.search_toggle.toggle()
                }
                .onAppear(){
                    self.draw = true
                }
                .onDisappear(){
                    self.draw = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(travel.title)
                .navigationBarTitleDisplayMode(.inline)
            VStack{
                ScrollView(.horizontal){
                    HStack{
                        Spacer()
                        ForEach(travel.days.sorted(by: {$0.date < $1.date})) { day in
                            Text("\(day.date) 일차")
                                .padding(10)
                                .padding(.horizontal)
                                .foregroundStyle(.background)
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(day.date == self.day ? Color.accentColor : Color.secondary)
                                        .shadow(radius: 7, x: 5, y: 5)
                                }
                                .padding(7)
                                .padding(.bottom)
                                .scaleEffect(day.date == self.day ? 1.1 : 1.0)
                                .onTapGesture {
                                    self.day = day.date
                                }
                        }
                        Spacer()
                    }
                }
                if search_toggle {
                    VStack{
                        HStack{
                            HStack{
                                Image(systemName: "magnifyingglass")
                                TextField("추가하고싶은 여행지를 선택하세요", text: $search_input)
                                    .onSubmit {
                                        searchPlacce.searchPlacewithKeyword(keyword: search_input, page: 1)
                                    }
                                //.foregroundStyle(.foreground)
                                //.textFieldStyle(.roundedBorder)
                            }
                            .padding(7)
                            .background{
                                Capsule()
                                    .foregroundStyle(.background)
                                    .shadow(radius: 7, x: 5, y: 5)
                            }
                            Button {
                                self.search_input = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 35)
                                    .foregroundStyle(.white)
                                    .shadow(radius: 7, x: 5, y: 5)
                                
                            }
                        }
                        .padding(.horizontal)
                        ScrollView {
                            ForEach(searchPlacce.placeDoc, id: \.self) { places in
                                HStack{
                                    VStack(alignment: .leading){
                                        Text(places.place_name ?? "no name")
                                        Text(places.road_address_name ?? "no address")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        //.modifier(seaerchPlaceViewModifier(place: $place, place_info: place, day_index: day_index))
                                    }
                                    Spacer()
                                    Button{
                                        print(places)
                                        travel.days.filter{$0.date == self.day}.first?.places.append(
                                            Places(name: places.place_name ?? "no name", longitude: Double(places.x ?? "0.0") ?? 0.0, latitude: Double(places.y ?? "0.0") ?? 0.0, sequence: travel.days.filter{$0.date == self.day}.first?.places.count ?? 0)
                                        )
                                        searchPlacce.placeDoc = []
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .scaleEffect(1.5)
                                        //.foregroundStyle(self.place.map{ $0.name }.contains(place.place_name) ? .red : .blue)
                                    }
                                }
                                .padding(10)
                                Divider()
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.background)
                                .shadow(radius: 5, x: 5, y: 5)
                        }
                        .padding(5)
                        .frame(height: 300)
                        //.border(.red)
                        Spacer()
                    }
                }
                Spacer()
                HStack{
                    Button {
                        
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .bold()
                            .foregroundStyle(.foreground)
                            .padding(15)
                            .background{
                                Circle()
                                    .foregroundStyle(.background)
                            }
                            .padding()
                            .shadow(radius: 7, x: 5, y: 5)
                    }
                    Spacer()
                    Button {
                        self.search_toggle.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .bold()
                            .foregroundStyle(.foreground)
                            .padding(15)
                            .background{
                                Circle()
                                    .foregroundStyle(.background)
                            }
                            .padding()
                            .shadow(radius: 7, x: 5, y: 5)
                    }

                }
            }
            .sheet(isPresented: $tap, content: {
                Text(travel.title)
            })
        }
    }
}



//#Preview {
//    TravelView(travel: travel_dummy)
//        //.modelContainer(for: [TravelModel.self])
//        //.modelContainer(previewContainer_travel)
//        //.modelContainer(for: TravelView.self)
//}
