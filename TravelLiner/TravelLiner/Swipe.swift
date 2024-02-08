//
//  Swipe.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/18.
//

import SwiftUI
import SwiftData

struct Swipe: ViewModifier {
    //@Query var travel: [TravelModel]
    //@Environment(\.modelContext) private var context // swiftdata 관리
    @State var offset = 0.0
    //let geometry: GeometryProxy
    @State var open = false
    let maxoffset = -60.0
    
    //@StateObject var user = User()
    //@Binding var progress: Bool
    //var itsMe = false
    //var commentId: String = ""
    
    
    func body(content: Content) -> some View {
//        ZStack{
//            RoundedRectangle(cornerRadius: 10)
//                //.frame(width: geometry.size.width - 65)
//                .padding(.horizontal,20)
//                .padding(.vertical, 6)
//                .foregroundColor(itsMe ? .red : .secondary)
//            Button {
//                context.delete()
//                progress = true
//            } label: {
//                HStack{
//                    Spacer()
//                    Image(systemName:itsMe ? "trash.fill" : "trash.slash.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 25)
//                        .foregroundColor(.white)
//                        .padding(.horizontal,40)
//                }
//            }
//            //.frame(width: )
//            .disabled(itsMe ? false : true)

        content
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged{ gesture in
                        withAnimation {
                            if open {
                                guard gesture.translation.width < maxoffset else {return}
                                offset = gesture.translation.width
                            } else {
                                guard gesture.translation.width < 0 else {return}
                                offset = gesture.translation.width
                            }
                        }
                    }
                    .onEnded{ gesture in
                        withAnimation {
                            if open {
                                offset = .zero
                                open = false
                            } else {
                                guard gesture.translation.width < 0 else {return}
                                offset = maxoffset
                                open = true
                            }
                        }
                    }
            )
        
        
    }
}

extension View {
    func Swipes() -> some View {
        self.modifier(Swipe())
    }
}
