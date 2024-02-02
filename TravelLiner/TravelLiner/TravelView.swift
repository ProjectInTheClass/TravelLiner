//
//  TravelView.swift
//  TravelMap
//
//  Created by 안병욱 on 1/27/24.
//

import SwiftUI
import KakaoMapsSDK

struct TravelView: View {
    @State var draw: Bool = true
    @State var tap: Bool = false
    @State var search_toggle: Bool = true
    @State var search_input: String = ""
    var title: String
    var position: MapPoint
    var body: some View {
        ZStack{
            
            KakaoMapView(draw: $draw, tap: $tap, position: position, spot: title)
//                .onTapGesture {
//                    self.search_toggle.toggle()
//                }
            //Rectangle()
                .foregroundStyle(.secondary)
                .onAppear(){
                    self.draw = true
                }
                .onDisappear(){
                    self.draw = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            VStack{
                ScrollView(.horizontal){
                    HStack{
                        Spacer()
                        ForEach(0...7, id: \.self) { index in
                            Text("\(index + 1) 일차")
                                .padding(10)
                                .padding(.horizontal)
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(.background)
                                        .shadow(radius: 7, x: 5, y: 5)
                                }
                                .padding(7)
                                .padding(.bottom)
                        }
                        Spacer()
                    }
                }
                if search_toggle {
                    HStack{
                        HStack{
                            Image(systemName: "magnifyingglass")
                            TextField("추가하고싶은 여행지를 선택하세요", text: $search_input)
                        }
                        .padding(7)
                        .background{
                            Capsule()
                                .foregroundStyle(.white)
                                .shadow(radius: 7, x: 5, y: 5)
                        }
                        Button {
                            
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 35)
                                .foregroundStyle(.white)
                                .shadow(radius: 7, x: 5, y: 5)
                            
                        }
                    }
                    .padding(.horizontal)
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
                Text(title)
            })
        }
    }
}



#Preview {
    TravelView(title: "title", position: MapPoint(longitude: 126.942250, latitude: 33.458528))
}
