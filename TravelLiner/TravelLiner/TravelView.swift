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
    @State var day_old: Int = 1 // 선택된 날짜
    @State var tap_place: Places = Places(name: "", longitude: 0.0, latitude: 0.0, sequence: 1)
    @State var img_seq = 0
    @Bindable var travel: TravelModel // 데이터
    @StateObject var searchPlacce: KakaoSearchPlace = KakaoSearchPlace() // 검색 클래스
    //var title: String
    //var position: MapPoint
    var body: some View {
        ZStack{
            KakaoMapView(draw: $draw, tap: $tap, day: $day, tap_place: $tap_place, day_old: $day_old, travel: self.travel)
//                .onTapGesture {
//                    self.search_toggle.toggle()
//                }
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
                                .foregroundStyle(day.date == self.day ? .white : .black)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(day.date == self.day ? Color.accentColor : Color.white)
                                        //.shadow(radius: 7, x: 5, y: 5)
                                    if day.date != self.day {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 2)
                                    }
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
                if tap {
                    VStack{
                        Spacer()
                        Image("POI")
                            .opacity(0.0)
                            .popover(isPresented: $tap, arrowEdge: .top, content: {
                                VStack{
                                    HStack{
                                        Text(tap_place.name)
                                            .bold()
                                            .font(.title2)
                                            .presentationCompactAdaptation(.popover)
                                            .onAppear() {
                                                self.search_toggle = false
                                                searchPlacce.searchPlacewithKeyword(keyword: tap_place.name, page: 1, x: tap_place.longitude, y: tap_place.latitude)
                                                searchPlacce.searchImage(keyword: tap_place.name, page: 1)
                                                self.img_seq = 0
                                            }
                                        Text(" #")
                                        Text(searchPlacce.placeDoc.first?.category_group_name ?? "")
                                        Spacer()
                                    }
                                    HStack{
                                        Button {
                                            if img_seq == 0 {
                                                return
                                            }
                                            img_seq -= 1
                                        } label: {
                                            Image(systemName: "chevron.left")
                                        }
                                        .disabled(img_seq == 0)
                                        Spacer()
                                        if !self.searchPlacce.imgDoc.isEmpty {
                                            AsyncImage(url: URL(string: self.searchPlacce.imgDoc.map{$0.image_url ?? "https://avatars.githubusercontent.com/u/46069040?s=400&u=6f2850dc2cbf5f0ca300f7bbd79cbbcd79fa137c&v=4"}[img_seq])) { image in
                                                image.image?.resizable()
                                                    .scaledToFit()
                                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                                    .frame(width: 300)
                                            }
                                        }
                                        Spacer()
                                        Button {
                                            if img_seq == self.searchPlacce.imgDoc.count - 1 {
                                                return
                                            }
                                            img_seq += 1
                                        } label: {
                                            Image(systemName: "chevron.right")
                                        }
                                        .disabled(img_seq == self.searchPlacce.imgDoc.count - 1)
                                    }
                                    HStack{
                                        Text("주소: \(searchPlacce.placeDoc.first?.road_address_name ?? "도로명 주소")")
                                        Spacer()
                                    }
                                    HStack{
                                        Text("전화번호: \(searchPlacce.placeDoc.first?.phone ?? "000-000-000")")
                                        Spacer()
                                    }
                                }
                                .padding()
                            })
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
                                            Places(name: places.place_name ?? "no name", longitude: Double(places.x ?? "0.0") ?? 0.0, latitude: Double(places.y ?? "0.0") ?? 0.0, sequence: (travel.days.filter{$0.date == self.day}.first?.places.count ?? 0) + 1)
                                        )
                                        searchPlacce.placeDoc = []
                                        self.day_old = 0
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
                                    .shadow(radius: 7, x: 5, y: 5)
                                Circle()
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(Color.black)
                            }
                            .padding()
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
                                    .shadow(radius: 7, x: 5, y: 5)
                                Circle()
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(Color.black)
                            }
                            .padding()
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
