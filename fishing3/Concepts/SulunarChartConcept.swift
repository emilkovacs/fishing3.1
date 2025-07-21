//
//  SulunarChartConcept.swift
//  fishing3
//
//  Created by Emil Kovács on 19. 7. 2025..
//
import SwiftUI



struct SolarCurveChartView: View {
   
    var body: some View {
        ScrollView{
            HStack{Spacer()}.frame(height: 160)
            VStack(alignment: .center){
                Circle()
                    .frame(width: 10,height: 10)
                HStack(spacing:12){
                    ForEach(0..<24) { index in
                        
                        if index == 4 || index == 5 {
                            Text("I")
                                .foregroundStyle(Color.blue)
                        } else {
                            Text("I")
                        }
                        
                        
                    }
                }
            }
            .padding()
        }
        .background(AppColor.tone)
    }
}


#Preview {
    SolarCurveChartView()
}
