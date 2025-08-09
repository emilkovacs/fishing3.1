//
//  Composer.swift
//  fishing3
//
//  Created by Emil Kovács on 8. 8. 2025..
//

import SwiftUI
import MapKit

struct Composer: View {
    
    @Environment(\.modelContext) var context
    
    var body: some View {
        NavigationStack{
            ZStack{
                ScrollView{
                    
                    HStack{Spacer()}
                }

                ComposerTopBar()
                ComposerBottomBar()
                
            }
            .background(AppColor.tone)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar,.bottomBar)
            .navigationBarBackButtonHidden()
        }
    }
}

struct ComposerTopBar: View {
    
    @Environment(\.modelContext) var context
    @State private var showData: Bool = false
    
    @Namespace var namespace
    
    var body: some View {
        HStack{
            CircleMenu(symbol: "ellipsis") {
                Group{
                    Button("Manage Data", systemImage: "externaldrive", action: {
                        showData.toggle()
                    })
                    Button("Settings", systemImage: "gearshape", action: {})
                    Button("Feedback", systemImage: "tray", action: {})
                }
            }
            .matchedTransitionSource(id: "data", in: namespace)
            .navigationDestination(isPresented: $showData) {
                ManageDataView(namespace: namespace)
                    .navigationTransition(.zoom(sourceID: "data", in: namespace) )
                
            }
            Spacer()
            CircleButton("chart.bar", action: {})
        }
        .topBarPlacement()
        
    }
}
struct ComposerBottomBar: View {
    @Environment(\.modelContext) var context
    @State private var mapExpanded: Bool = false
    @State private var showAddCatch: Bool = false
    @Namespace var namespace
    
    var body: some View {
        HStack{
            
            CompositeButton(mapExpanded ? nil : "Logs", "calendar.day.timeline.left", action: {
                withAnimation{mapExpanded.toggle()}
            })
            CompositeButton(mapExpanded ? "Map" : nil, "map", action: {
                withAnimation{mapExpanded.toggle()}
            })
            Spacer()
            CapsuleButton("plus", "Catch") {
                showAddCatch.toggle()
            }
            .navigationDestination(isPresented: $showAddCatch) {
                EditEntry(context: context, location: CLLocation(latitude: 1, longitude: 1), entry: Entry(lat: 1, lon: 1), newEntry: false, backAction: {
                    showAddCatch.toggle()
                })
                    .navigationTransition(.zoom(sourceID: "Add", in: namespace))
                    .navigationBarBackButtonHidden()
                    .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            }
        }
        .bottomBarPlacement()
    }
}


#Preview {
    Composer()
        .superContainer()
        
}




