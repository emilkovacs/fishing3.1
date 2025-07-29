//
//  HomeView.swift
//  fishing3
//
//  Created by Emil Kovács on 28. 7. 2025..
//

import SwiftUI
import SwiftData

// Map
// Today
// Historical

//Controls etc layer

@Observable
class HomeViewModel {
    
}

struct HomeView: View {
    var body: some View {
        ZStack{
            List{
                Spacer().frame(height: 128)
                    .modifier(ListModifier())
                if true {
                    Text("Today")
                        .font(.title)
                        .fontWeight(.medium)
                        .modifier(ListModifier())
                        .padding(.bottom,24)
                    EntryRow()
                    EntryRow()
                    EntryRow()
                }

                HStack{
                    Text("March")
                    Spacer()
                    Text("12")
                        .font(.caption)
                }
                    .font(.title3)
                    .fontWeight(.medium)
                    .modifier(ListModifier())
                    .padding(.vertical,12)
                
                EntryDayRow(title: "March 24")
                EntryDayRow(title: "March 22")
                EntryDayRow(title: "March 18")
                
                HStack{
                    Text("February")
                    Spacer()
                    Text("8")
                        .font(.caption)
                }
                    .font(.title3)
                    .fontWeight(.medium)
                    .modifier(ListModifier())
                    .padding(.vertical,12)
                HStack{
                    Text("January")
                    Spacer()
                    Text("24")
                        .font(.caption)
                }
                    .font(.title3)
                    .fontWeight(.medium)
                    .modifier(ListModifier())
                    .padding(.vertical,12)
                                    
                
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
    }
}

struct EntryRow: View {
    var body: some View {
        VStack{
            HStack(alignment: .center){
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing:0){
                        
                        Image(systemName: "cloud")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text(" Cloudy,  ")
                        
                        Text("14:48  ")
                        
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppColor.half)
                    .padding(.bottom,6)
                    
                    Text("Northern Pike, Trailing Bait")
                        .fontWeight(.medium)
                    
                    Text("20kg, 63cm, from Shore ")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.half)
                }
                
                Spacer()
                Image("demoC")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 82, height: 82,alignment: .top)
                    .cornerRadius(12)
            }
            
            Divider()
                .padding(.vertical,12)
            
        }
        .modifier(ListModifier())
        
    }
}

struct EntryDayRowB: View {
    var body: some View {
        VStack{
           
            Text("3 catches")
            
            HStack{
                Text("March 14")
                Spacer()
                Text("Cloudy, 24C")
            }
            .font(.subheadline)
            .foregroundStyle(AppColor.half)
            
            Divider()
                .padding(.vertical,12)
        }
        .modifier(ListModifier())
    }
}

struct EntryDayRow: View {
    let title: String
    var body: some View {
        VStack{
            HStack(alignment: .center){
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("8 catches, \(title)")
                    
                    HStack(spacing: 0) {
                        Text("4 species, 3 baits")
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppColor.half)
                    .padding(.top,6)
                        
                }
                
                Spacer()

            }
            
            Divider()
                .padding(.vertical,12)
        }
        .modifier(ListModifier())
    }
}

#if DEBUG

struct HomeView_PreviewWrapper: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    HomeView_PreviewWrapper()
}

#endif
