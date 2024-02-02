//
//  datepicker.swift
//  TravelMap
//
//  Created by 안병욱 on 2/1/24.
//

import SwiftUI

struct datepicker: View {
    @State var sel: Date = Date()
    var body: some View {
        VStack{
            DatePicker("", selection: $sel, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .font(.caption)
                .foregroundStyle(.black)
                .background(.white)
            Spacer()
        }
        .background(.gray)
    }
}

#Preview {
    datepicker()
}
