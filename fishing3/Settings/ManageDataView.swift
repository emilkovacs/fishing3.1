//
//  ManageDataView.swift
//  fishing3
//
//  Created by Emil Kovács on 9. 8. 2025..
//

import SwiftUI

struct ManageDataView: View {
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack{
            List {
                ListTopSpacer()
                /*
                ListTitle(title: "Manage Data",count: nil)
                    .padding(.bottom,24)
                    .listModifier()
                */
                Text("Manage Data")
                    .font(.title)
                    .fontWeight(.medium)
                    .listModifier()
                    
                Text("All Data")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top,36)
                    .listModifier()
                    
                Text("Manage your cretead data, or remove them.")
                    .listModifier()
                    .foregroundStyle(AppColor.half)
                    .padding(.bottom,8)
                    
                SettingsRowLabelAlt("Catches", "calendar.day.timeline.left", 3) {
                    ListSessions(context: context)
                }
                SettingsRowLabelAlt("Species", "fish", 3) {
                    ListSpecies(mode: .edit, selectedSpecies: .constant(nil), context: context)
                }
                SettingsRowLabelAlt("Baits", "point.forward.to.point.capsulepath.fill", 3) {
                    ListBaits(mode: .edit, selectedBait: .constant(nil), context: context) {
                        
                    }
                }
               // SettingsRowLabelAlt("Notes","note.text", 42)
                        
                Text("Backup")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top,42)
                    .listModifier()

                
                Text("Export or import data from backup.")
                    .listModifier()
                    .foregroundStyle(AppColor.half)
                    .padding(.bottom,8)
                
                
               // SettingsRowLabelAlt("iCloud sync","icloud", nil)
               // SettingsRowLabelAlt("Export data","arrowshape.turn.up.right", nil)
               // SettingsRowLabelAlt("Import data","arrowshape.turn.up.backward", nil)
                //SettingsRowLabelAlt("Delete all data","trash", nil)
                
                
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            
            ListTopBlocker()
            ManageDataTopBar(namespace: namespace)
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
        .navigationBarBackButtonHidden()
    }
}


struct SettingsRowLabelAlt<Destination: View>: View {
    
    let title: String
    let symbol: String?
    let count: Int?
    let destination: () -> Destination
    
    @State private var navigate: Bool = false
    
    var body: some View {
        Button {
            AppHaptics.light()
            navigate.toggle()
        } label: {
            VStack(spacing: 0) {
                HStack {
                    if let symbol {
                        Image(systemName: symbol)
                            .font(.caption)
                            .frame(width: 28, height: 28)
                            .background(AppColor.half.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.trailing,4)
                    }
                    Text(title)
                        .font(.callout)
                        .fontWeight(.medium)
                    Spacer()
                    if let count {
                        Text("\(count)")
                            .foregroundStyle(AppColor.half)
                            .font(.callout2)
                            .fontWeight(.medium)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColor.half)
                }
                .padding(.vertical,AppSize.regularSpace)
                Divider()
            }
        }
        .listModifier()
        .navigationDestination(isPresented: $navigate) {
                destination()
                .navigationBarBackButtonHidden()
        }

    }
    
    init(_ title: String, _ symbol: String? = nil, _ count: Int? = nil, destination: @escaping () -> Destination) {
        self.title = title
        self.symbol = symbol
        self.count = count
        self.destination = destination
    }
    
    
}

struct ManageDataTopBar:View {
    @Environment(\.dismiss) var dismiss
    var namespace: Namespace.ID
    var body: some View {
        HStack{
            CircleButton("chevron.left") { dismiss() }
                .matchedGeometryEffect(id: "data", in: namespace)
            Spacer()
        }
        .topBarPlacement()
    }
}

#if DEBUG

struct ManageData_PreviewWrapper: View {
    
    @Environment(\.modelContext) var context
    @Namespace var namespace
    var body: some View {
        
        ManageDataView(namespace: namespace)
    }
}

#Preview {
    NavigationStack{
        ManageData_PreviewWrapper()
    }
    .superContainer()
}


#endif
