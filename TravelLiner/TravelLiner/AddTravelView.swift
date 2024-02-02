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
    @Environment(\.dismiss) var dismiss
    @State var title: String = ""
    @State var img: String = "🧭"
    @Environment(\.modelContext) private var context
    @Query var travel: [TravelModel]
    @State var tag: Int = 0
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center){
                Spacer()
                TextField("", text: $img)
                    .font(.system(size: 150))
                    //.scaleEffect(10.0)
                    .multilineTextAlignment(.center)
                    .onReceive(Just(img), perform: { _ in
                        if img.count > 1 {
                            img = String(img[img.startIndex])
                        }
                    })
                    .frame(width: 200, height: 200)
                    .background {
                        Circle()
                            .foregroundStyle(.background)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
                TextField("어떤 여행을 가실 건가요?", text: $title)
                    .padding(7)
                    .background {
                        Capsule()
                            .foregroundStyle(.background)
                            .shadow(radius: 5, x: 5, y: 5)
                    }
                    .padding()
                NavigationLink {
                    TravelPlanView(title: $title, travel: travel.last ?? TravelModel(title: "error", days: [], icon: "", start_date: Date()))
                } label: {
                    Text("계속하기")
                }.simultaneousGesture(TapGesture().onEnded{
                    let new_model = TravelModel(title: self.title, days: [Days(date: 1, places: [])], icon: "\(img)", start_date: Date())
                    context.insert(new_model)
                })
                Spacer()
            }
            .background(.secondary.opacity(0.2))
            .navigationTitle("나의 새로운 여행 추가하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button{
                        dismiss()
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
    @Binding var title: String
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Bindable var travel: TravelModel
    //var days: [Days]
    var body: some View {
        List {
            Text(travel.title)
            ForEach(travel.days) { day in
                DisclosureGroup("\(day.date) 일차") {
                    ForEach(day.places) { place in
                        Text(place.name)
                    }
                    
                    NavigationLink {
                        AddPlaceVIew(day: travel.days.filter{ $0 == day }.first ?? Days(date: 1, places: []))
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
            } header: {
                Text("Lower")
                    .textCase(.none)
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button{

                        dismiss()
                    } label: {
                        Text("확인")
                    }
                    .buttonStyle(.borderedProminent)
                }
            })
        }
        .navigationTitle(travel.title)
    }
}

struct AddPlaceVIew: View {
    @State var keyword: String = ""
    //@Binding var place: [Int: [Documents]]
    //let day_index: Int
    @Bindable var day: Days
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @StateObject var searchPlacce: KakaoSearchPlace = KakaoSearchPlace()
//    let dummy: [Documents] = [
//        Documents(place_name: "롯데월드타워", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯데월드", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯데월타워1", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯데타워", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯데월드타워2", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯데타워1", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯월드타워", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯타워", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯데월워", road_address_name: "서울 송파구 올림픽로 300"),
//        Documents(place_name: "롯워", road_address_name: "서울 송파구 올림픽로 300")
//    ]
//    
    var body: some View {
        VStack{
            TextField("어디로 가실건가요?", text: $keyword)
                .onSubmit {
                    searchPlacce.searchPlacewithKeyword(keyword: keyword, page: 1)
                    keyword = ""
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
                                Places(name: places.place_name ?? "no name", longitude: Double(places.x ?? "0.0") ?? 0.0, latitude: Double(places.y ?? "0.0") ?? 0.0)
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

//struct seaerchPlaceViewModifier: ViewModifier {
//    //@Binding var place: [Int: [Documents]]
//    let place_info: Documents
//    let day_index: Int
//    var place: [Places]
//    
//    public func body(content: Content) -> some View {
//        HStack{
//            content
//            Spacer()
//            Button{
//                //self.place[day_index]?.append(place_info)
//                place.append(Places(name: <#T##String#>, longitude: <#T##Double#>, latitude: <#T##Double#>))
//            } label: {
//                Image(systemName: "plus.circle.fill")
//                    .scaleEffect(1.5)
//            }
//        }
//    }
//    
//    
//}
