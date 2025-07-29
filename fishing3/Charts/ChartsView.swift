//
//  ChartsView.swift
//  fishing3
//
//  Created by Emil Kovács on 28. 7. 2025..
//

import SwiftUI
import SwiftData
import Charts

//Notes for onboard:
/// Last 5000 entries are calculated without filters.
/// Filters: Top 5 species,
/// Do we even need filters?
///
@Observable
class ChartsViewModel {
    
    var context: ModelContext
    var backAction: () -> Void
    let entries: [Entry]

    init(context: ModelContext, backAction: @escaping () -> Void) {
        self.context = context
        self.backAction = backAction
        
        //Construct descriptor
        var descriptor = FetchDescriptor<Entry>( sortBy: [SortDescriptor(\.timestamp, order: .forward)])
        descriptor.fetchLimit = 5000
        
        //Fetch with descriptor
        do {
            entries = try context.fetch(descriptor)
        } catch {
            #if DEBUG
            print("Failed to fetch entries: \(error)")
            #endif
            entries = []
        }
    }

}

struct ChartsView: View {
    
    @Bindable var vm: ChartsViewModel
    
    init(
        context: ModelContext, backAction: @escaping () -> Void
    ) {
        self.vm = ChartsViewModel(context: context, backAction: backAction)
    }
    
    
    var body: some View {
        ZStack {
            ChartsStatsView()
            
            ListTopBlocker()
            ChartsTopControls()
        }
        .environment(vm)
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
        
    }
}

struct ChartsStatsView: View {
    @Environment(ChartsViewModel.self) var vm
    var body: some View {
        List{
            Spacer()
                .frame(height: AppSafeArea.edges.top + AppSize.buttonSize + 32)
                .modifier(ListModifier())
            HStack{
                Text("Statistics")
                    .font(.largeTitle)
                Spacer()
            }
            .padding(.bottom,24)
            .modifier(ListModifier())
            
            HorizontalBarChart(allEntries: vm.entries, keyPath: \.species?.name, tint: .blue).modifier(ListModifier())
            
            Spacer()
                .frame(height: AppSafeArea.edges.bottom + AppSize.buttonSize + 32)
                .modifier(ListModifier())
        }
        .listStyle(.plain)
    }
}

struct ChartsTopControls: View {
    var body: some View {
        HStack{
            CircleButton("chevron.left") {
                
            }
            Spacer()
            CircleButton("line.3.horizontal.decrease") {
                
            }
        }
        .padding(.horizontal)
        .padding(.top,AppSafeArea.edges.top)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#if DEBUG

struct ChartsView_PreviewWrapper: View {
    @Environment(\.modelContext) var context
    
    var body: some View {
        ChartsView(context: context) {
            print("⏮️ Main UI Back action fired")
        }
    }
}

#Preview {
    ChartsView_PreviewWrapper()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
}

#endif
