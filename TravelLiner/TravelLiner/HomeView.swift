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
    @Environment(\.colorScheme) var colorscheme //시스템에따라 다크모드일 경우 텍스트 색이 달라지게 되기 때문에 설정 고정하기 위해 가져옴.
    @Environment(\.modelContext) private var context // swiftdata 관리
    var travelSorted: [TravelModel] {//SwiftData에 접근하는 방법인데 윈도우 그룹안에 데이터가 순서 없이 담기게 되고 쿼리 선언과함께 리스트가 만들어진다. 한마디로 모델 만든 순서의 영향이 크지 않음.
        switch travelOrder {
        case .Dday:
            return self.travel.sorted { $0.start_date ?? Date() < $1.start_date ?? Date() }
        case .name:
            return self.travel.sorted { $0.title < $1.title }
        default:
            return self.travel.sorted { $0.id < $1.id }
        }
    }
    @Query var travel: [TravelModel]
    @State var travelOrder: TravelOrder = .add
    @State var addTravel: Bool = false // 여행 추가 모달용
    @State var selectedOrder = "디데이"
    @State var selLocModal = false
    @State var selected_contry = "전국"
    var orders = ["디데이", "이름순", "여행 추가 순"]
    
    var body: some View {
        NavigationStack{
            ZStack{
                ScrollView{
                    VStack{
                        VStack{
                            Text("나의 여행")
                                .font(.title)
                                .bold()
                                .scaleEffect(1.4)
                            Button{
                                self.selLocModal = true
                            } label: {
                                HStack{
                                    Image("POI")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                    Text("지역 선택 - \(self.selected_contry)")
                                        .tint(.black)
                                        .padding(.trailing, 5)
                                }
                                .padding(5)
                                .background{
                                    Capsule()
                                        .foregroundStyle(.accent)
                                }
                            }
                            .sheet(isPresented: self.$selLocModal, content: {
                                self.selLoc
                                    .presentationDetents([.fraction(0.4)])
                            })
                        }
                        .padding(.vertical, 80)
                        HStack{
                            Picker("피커뷰", selection: $travelOrder) {
                                Text("디데이순").tag(TravelOrder.Dday)
                                Text("이름순").tag(TravelOrder.name)
                                Text("여행추가순").tag(TravelOrder.add)
                            }
                            .tint(.black)
                            Spacer()
                        }
                        Divider()
                            .frame(minHeight: 1)
                            .overlay(Color.accentColor)
                        ForEach(self.travelSorted) { travels in //ForEach에 변수를 바로 담을 수 있고 SwiftData 자체가 identifiable을 포함하고 있어 id 지정 필요 없음
                            NavigationLink {
                                //Text(trip_previewList[index] + "시작!")
                                TravelView(travel: travels) // 여행 상세뷰
                            } label: {
                                ZStack{
                                    HStack{
                                        Spacer()
                                        Button{
                                            context.delete(travels)
                                        } label: {
                                            Image(systemName: "trash.slash.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 30)
                                                .padding(.horizontal)
                                                .frame(width: 120, height: 60, alignment: .trailing)
                                                .foregroundColor(.white)
                                                .background{
                                                    Capsule()
                                                        .foregroundStyle(.red)
                                                }
                                                .padding(.trailing, 25)
                                        }
                                    }
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text(travels.title)
                                                .tint(colorscheme == .dark ? Color.white : Color.black)
                                                .font(.title2)
                                                .bold()
                                                .padding(.horizontal, 10)
                                            Divider()
                                            HStack{
                                                Text("D - 7")
                                                    .foregroundStyle(.black)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 10)
                                        }
                                        .padding(.horizontal, 10)
                                        Text(travels.icon)
                                            .font(.title)
                                            .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                            .frame(width: 60, height: 60, alignment: .center)
                                            .background {
                                                Circle()
                                                    .foregroundStyle(.foreground.opacity(0.2))
                                            }
                                            .padding(.leading, 3)
                                        
                                    }
                                    .padding(10)
                                    .background {
                                        Capsule()
                                            .foregroundStyle(.background)
                                    }
                                    .Swipes() // 스와이프로 뒤의 버튼 나타나게함
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    
                                }
                            }
                            Divider()
                                .frame(minHeight: 1)
                                .overlay(Color.accentColor)
                        }
                        Spacer()
                            .frame(height: 100)
                        
                    }
                }
                VStack{
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
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.background)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 2.0)
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal ,20)
                        
                    }
                    .sheet(isPresented: $addTravel) {
                        AddTravelView(addTravel: $addTravel) // 여행추가 모달
                    }
                }
            }
            .preferredColorScheme(.light)
        }
    }
    
    var contry: [String] = ["서울", "경기", "강원", "부산", "충북", "충남", "전북", "전남", "경북", "경남", "제주", "전국", ]
    var selLoc: some View {
        VStack{
            HStack{
                Text("지역 선택")
                    .bold()
                    .font(.title3)
                    .padding(20)
                Spacer()
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 85, maximum: 120))], spacing: 0){
                ForEach(self.contry, id: \.self) { loc in
                    Button{
                        
                    } label: {
                        Text(loc)
                            .padding(10)
                            .padding(.horizontal)
                            .foregroundStyle(self.selected_contry == loc ? .white : .black)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(self.selected_contry == loc ? Color.accentColor : Color.white)
                                //.shadow(radius: 7, x: 5, y: 5)
                                if self.selected_contry != loc {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 2)
                                        .foregroundStyle(.black)
                                }
                            }
                            .padding(3)
                            .onTapGesture {
                                self.selected_contry = loc
                                self.selLocModal = false
                            }
                    }
                }
            }
            .padding(.horizontal, 5)
            Spacer()
        }
    }
}


enum TravelOrder {
    case name, Dday, add
}

#Preview {
    HomeView()
}
