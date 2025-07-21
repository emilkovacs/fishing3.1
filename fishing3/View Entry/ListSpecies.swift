//
//  ListSpecies.swift
//  fishing3
//
//  Created by Emil Kovács on 17. 7. 2025..
//

import SwiftUI
import SwiftData

enum ListOptions: String, Selectable {
    case recents, forwward, backward
    var id: String { self.rawValue }
    var label: String {
        switch self {
        case .recents: return "Recents Top"
        case .forwward: return "Forward"
        case .backward: return "Backward"
        }
    }
    
    var shortLabel: String {
        switch self {
        case .recents: return ""
        case .forwward: return ""
        case .backward: return ""
        }
    }
    var symbolName: String {
        switch self {
        case .recents: return "arrowshape.up.fill"
        case .forwward: return "arrowshape.right.fill"
        case .backward: return "arrowshape.left.fill"
        }
    }
    
    
}

struct ListSpecies: View {
    
    @State private var demoString: String = ""
    @Query(sort: \Species.name) var allSpecies: [Species]
    
    
    var filteredSpecies: [Species] {
        guard !demoString.isEmpty else { return allSpecies}
        return allSpecies.filter { $0.name.localizedCaseInsensitiveContains(demoString) }
    }
    
    var body: some View {
        ZStack{
            List{
                Group{
                    Spacer().frame(height: AppSafeArea.edges.top + AppSize.buttonSize + 32)
                    
                    ListTitle(title: "All Species")
                        .padding(.bottom,32)
                    
                    ForEach(filteredSpecies){ specie in
                        SpeciesRow(species: specie)
                            .contextMenu{
                                Button("Select", systemImage: "checkmark"){}
                                Button("Star", systemImage: "star"){specie.star.toggle()}
                                Button("Edit", systemImage: "pencil"){}
                                Button("Delete", systemImage: "trash"){}
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button() {
                                    specie.star.toggle()
                                } label: {
                                    Label("Edit", systemImage: "star")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button() {
                                    //delete(item)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                    }
                    
                    Spacer().frame(height: AppSafeArea.edges.bottom + AppSize.buttonSize + 32)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSpacing(0)
                .listRowBackground(AppColor.tone)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            
            TopBlocker()
            ControlBar()
            BottomBlocker()
            SearchBar(filterString: $demoString, prompt: "Search species")
        }
        .background(AppColor.tone)
        .ignoresSafeArea(.container)
    }
    
    var alt: some View {
        ZStack{
            ScrollView{
                LazyVStack(
                    alignment: .leading, spacing: 0
                ) {
                    ListTitle(title: "All Species")
                        .padding(.bottom,32)
                    Divider()
                    ForEach(filteredSpecies){ specie in
                        SpeciesRow(species: specie)
                    }
                }
                .padding(.horizontal)
                .padding(.top,32)
                .padding(.top,AppSafeArea.edges.top + AppSize.buttonSize)
                .padding(.bottom,32)
                .padding(.bottom,AppSafeArea.edges.bottom + AppSize.buttonSize)
            }
            TopBlocker()
            ControlBar()
            BottomBlocker()
            SearchBar(filterString: $demoString, prompt: "Search species")
        }
        .background(AppColor.tone)
        .ignoresSafeArea(.container)
    }
    
    struct ControlBar: View {
        var body: some View {
            HStack{
                CircleButton("chevron.left") {
                    
                }
                
                Spacer()
                CircleButton("line.3.horizontal.decrease") {
                    
                }
                CapsuleButton("plus", "Add") {
                    
                }
            }
            .padding(.top,AppSafeArea.edges.top)
            .padding(.horizontal)
            
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    struct TopBlocker: View {
        var body: some View {
            LinearGradient(colors: [
                AppColor.tone,AppColor.tone.opacity(0.65),Color.clear
            ],startPoint: .top, endPoint: .bottom)
            .frame(height: 112)
            .frame(maxHeight: .infinity, alignment: .top)
            .allowsHitTesting(false)
        }
    }
   
    
    struct ListTitle: View {
        let title: String
        var body: some View {
            HStack(alignment: .firstTextBaseline){
                Text(title)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColor.primary)
                Spacer()
                Text("46")
                    .font(.callout2)
                    .foregroundStyle(AppColor.half)
            }
        }
    }
}

struct BottomBlocker: View {
    var body: some View {
        LinearGradient(colors: [
            AppColor.tone,AppColor.tone.opacity(0.9),Color.clear
        ],startPoint: .bottom, endPoint: .top)
        .frame(height: 112)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
    }
}

struct SpeciesRow: View {
    let species: Species
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                
                if species.star {
                    Image(systemName: "star.fill")
                        .foregroundStyle(AppColor.half)
                        .font(.callout2)
                        .fontWeight(.medium)
                }
                
                Text(species.name)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: species.water.symbolName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColor.half)
                    .frame(width: 20,alignment: .center)
                
                Image(systemName: species.behaviour.symbolName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColor.half)
                    .frame(width: 20,alignment: .center)
            }
            .padding(.vertical,16)
            Divider()
        }
    }
}



//MARK: - PREVIEW
#if DEBUG
struct ListSpecies_PreviewWrapper: View {
    var body: some View {
        ListSpecies()
    }
}

#Preview {
    ListSpecies_PreviewWrapper()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
}
#endif
