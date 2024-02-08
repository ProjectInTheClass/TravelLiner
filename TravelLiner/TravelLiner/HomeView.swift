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
    @Query var travel: [TravelModel] //SwiftData에 접근하는 방법인데 윈도우 그룹안에 데이터가 순서 없이 담기게 되고 쿼리 선언과함께 리스트가 만들어진다. 한마디로 모델 만든 순서의 영향이 크지 않음.
    @State var addTravel: Bool = false // 여행 추가 모달용
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    ForEach(travel) { travels in //ForEach에 변수를 바로 담을 수 있고 SwiftData 자체가 identifiable을 포함하고 있어 id 지정 필요 없음
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
                                .Swipes() // 스와이프로 뒤의 버튼 나타나게함
                                .padding(.horizontal, 20)
                                
                            }
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
                        AddTravelView(addTravel: $addTravel) // 여행추가 모달
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    HomeView()
}
