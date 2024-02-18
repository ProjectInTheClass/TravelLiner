//
//  AddTravelView.swift
//  TravelMap
//
//  Created by 안병욱 on 1/31/24.
//

import SwiftUI
import SwiftData
import Combine

struct AddTravelView: View {
    @Environment(\.dismiss) var dismiss // 모달 종료
    @State var title: String = "" // 여행 제목
    @State var img: String = "🧭" // 여행 아이콘
    @State var startDate: Date = Date()
    @Environment(\.modelContext) private var context // swiftdata 관리
    @Query var travel: [TravelModel] // 윈도우 그룹 속 데이터 접그
    @Binding var addTravel: Bool // 홈뷰 모달 닫기용
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center){
                Spacer()
                
                Divider()
                    .frame(minHeight: 1)
                    .overlay(Color.accentColor)
                HStack{
                    VStack{
                        TextField("어떤 여행을 가실 건가요?", text: $title)
                            .padding(.horizontal)
                        Divider()
                        DatePicker("여행 출발 날짜", selection: self.$startDate, displayedComponents: .date)
                            .environment(\.locale, .init(identifier: "ko"))
                    }
                    .padding()
                    TextField("", text: $img)
                        .font(.system(size: 80))
                        //.scaleEffect(10.0)
                        .multilineTextAlignment(.center)
                        .onReceive(Just(img), perform: { _ in
                            if img.count > 1 {
                                img = String(img[img.startIndex])
                            }
                        })
                        .frame(width: 100, height: 100)
                        .background {
                            Circle()
                                .foregroundStyle(.foreground.opacity(0.2))
                        }
                }
                Divider()
                    .frame(minHeight: 1)
                    .overlay(Color.accentColor)
                NavigationLink {
                    TravelPlanView(title: $title, addTravel: $addTravel, travel: travel.last ?? TravelModel(title: "error", days: [], icon: "", start_date: Date())) // 실질적인 여행 추가뷰
                } label: {
                    HStack{
                        Spacer()
                        Text("계속하기")
                            .tint(.white)
                            .padding(.vertical, 8)
                        Spacer()
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(20)
                }.simultaneousGesture(TapGesture().onEnded{ //네비세이션 링크를 클릭과 동시에 실행
                    let new_model = TravelModel(title: self.title, days: [Days(date: 1, places: [])], icon: "\(img)", start_date: startDate) // 텅빈 모델 생성
                    context.insert(new_model) // 윈도우 그룹 안에 TravelModel 데이터 담아줌
                })
                Spacer()
            }
            .background(.background)
            .navigationTitle("나의 새로운 여행 추가하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button{
                        dismiss() // 모달 종료
                    } label: {
                        //Text("title")
                        Image(systemName: "xmark.circle.fill")
                            .scaleEffect(1.5)
                            .foregroundStyle(.gray)
                    }
                }
                
            })
        }
    }
}

struct TravelPlanView: View {
    @Binding var title: String // 앞의 뷰에서 여행 제목 가져옴
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Binding var addTravel: Bool // 홈뷰 모달 닫기용
    @Bindable var travel: TravelModel // 일종의 swiftdata에서 사용하는 @Binding 대신 윈도우그룹속 데이터를 가져오기 때문에 초기화 인스턴스 생성 불필요
    //var days: [Days]
    var body: some View {
        List {
            Text(travel.title)
            ForEach(travel.days.sorted(by: {$0.date < $1.date})/* 배열 일차에 따라 재배열*/) { day in
                DisclosureGroup("\(day.date) 일차") {
                    ForEach(day.places.sorted(by: {$0.sequence < $1.sequence})) { place in
                        HStack{
                            Text(String(place.sequence))
                                .foregroundStyle(.background)
                                .padding(7)
                                .background {
                                    Circle()
                                        .foregroundStyle(.blue)
                                }
                            Text(place.name)
                        }
                    }
                    
                    NavigationLink {
                        AddPlaceVIew(day: travel.days.filter{ $0 == day }.first ?? Days(date: 1, places: [])) // 장소 검색뷰로 해당 X일차 데이터를 넘김. 해당 뷰에서 inser를 통해 데이터를 입력할거라 bindable 필요치 않음
                    } label: {
                        Text("장소 추가하기")
                            .foregroundStyle(.tint)
                    }
                }
            }
            Section {
                HStack{
                    Spacer()
                    Button{
                        travel.days.append(Days(date: travel.days.count + 1, places: []))
                        //print(travel)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .scaleEffect(1.5)
                    }
                    Spacer()
                }
            }
            
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button{
                    self.addTravel = false // 모달이나
                } label: {
                    Text("확인")
                }
                .buttonStyle(.borderedProminent)
            }
        })
        .navigationTitle(travel.title)
    }
}

struct AddPlaceVIew: View {
    @State var keyword: String = ""
    @Bindable var day: Days // [Places]로 하면 Obsevable이 안되기 때문에 Days 모델을 들고옴
    
    @Environment(\.modelContext) private var context // swiftdata 관리
    @Environment(\.dismiss) var dismiss // 모달 종료용
    
    @StateObject var searchPlacce: KakaoSearchPlace = KakaoSearchPlace() // Rest API 검색 클래스
    var body: some View {
        VStack{
            TextField("어디로 가실건가요?", text: $keyword)
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                }
                .padding(.horizontal)
                .onSubmit {
                    // 엔터치면 검색됨
                    searchPlacce.searchPlacewithKeyword(keyword: keyword, page: 1)
                    //keyword = ""
                }
            List(searchPlacce.placeDoc/*self.dummy*/, id: \.self) { places in
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
                            day.places.append(
                                Places(name: places.place_name ?? "no name", longitude: Double(places.x ?? "0.0") ?? 0.0, latitude: Double(places.y ?? "0.0") ?? 0.0, sequence: (day.places.count + 1))
                            )
                            dismiss()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .scaleEffect(1.5)
                                //.foregroundStyle(self.place.map{ $0.name }.contains(place.place_name) ? .red : .blue)
                        }
                }
            }
        }
    }
}

