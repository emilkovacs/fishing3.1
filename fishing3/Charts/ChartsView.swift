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


// Dev notes
/// Maybe a cool chart loader with "aggregating data" ?
///
/// Onboard view?
/// Filter view?

@Observable
class ChartsViewModel {
    
    var context: ModelContext
    var backAction: () -> Void
    let entries: [Entry]

    var showWeather: Bool = true
    var showStats: Bool = true
    
    init(context: ModelContext, backAction: @escaping () -> Void) {
        self.context = context
        self.backAction = backAction
        
        //Construct descriptor
        var descriptor = FetchDescriptor<Entry>( sortBy: [SortDescriptor(\.timestamp, order: .forward)])
        descriptor.fetchLimit = 300
        
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
            if vm.showStats{
                ChartsStatsView()
                    .transition(.blurReplace)
            } else {
                ChartsWeatherView()
                    .transition(.blurReplace)
            }
            
            ListTopBlocker()
            ListBottomBlocker()
            ChartsTopControls(vm: vm)
            ChartsBottomControls(vm: vm)
            
        }
        .environment(vm)
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
        
    }
}

struct ChartsWeatherView: View {
    @Environment(ChartsViewModel.self) var vm
    var body: some View {
        List{
            Spacer()
                .frame(height: AppSafeArea.edges.top + AppSize.buttonSize + 32)
                .modifier(ListModifier())
            
            HStack{
                Text("Weather")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.bottom,32)
            .modifier(ListModifier())
            
            MultiChart(types: [.temp_current,.temp_feels,.temp_high,.temp_low], allEntries: vm.entries)
            MultiChart(types: [.pressure,.pressure_trend,.humidity], allEntries: vm.entries)
                
            MultiChart(types: [.water_temp,.water_visibility,.tide_state], allEntries: vm.entries)
            
            MultiChart(types: [.condition,.cloudCover,.air_visibility,.rain_chance,.rain_amount], allEntries: vm.entries)
            
            MultiChart(types: [.wind_speed,.wind_gusts], allEntries: vm.entries)
            
            SingleChart(type: .moon_phase, allEntries: vm.entries)
            
            Spacer()
                .frame(height: AppSafeArea.edges.bottom + AppSize.buttonSize + 32)
                .modifier(ListModifier())
        }
        .listStyle(.plain)
        .background(AppColor.tone)
        
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
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.bottom,32)
            .modifier(ListModifier())
            
           // MultiChart(types: [.species_name,.species_water,.species_behaviour], allEntries: vm.entries)
            
           // MultiChart(types: [.bait_name,.bait_type,.bait_position], allEntries: vm.entries)
            
            //SingleChart(type: .casting_method, allEntries: vm.entries)
            
            //MultiChart(types: [.bottom_type], allEntries: vm.entries)
            
           // MultiChart(types: [.weight_distribution,.length_distribution], allEntries: vm.entries)
            
           // HorizontalBarChart(allEntries: vm.entries, keyPath: \.species?.name, tint: .blue).modifier(ListModifier())
            
            Spacer()
                .frame(height: AppSafeArea.edges.bottom + AppSize.buttonSize + 32)
                .modifier(ListModifier())
        }
        .listStyle(.plain)
    }
}

struct ChartsFilterView: View {
    
    @Bindable var vm: ChartsViewModel
    ///Total amount
    ///
    //Amount
    //Species
    
    var body: some View {
        Text("E")
    }
}

//Controls
struct ChartsBottomControls: View {
    @Bindable var vm: ChartsViewModel
    var body: some View {
        HStack{
            CompositeButton(vm.showStats ? "Stats" : nil, "chart.pie") {
                withAnimation {
                    vm.showStats = true
                }
            }
            CompositeButton(vm.showStats ? nil : "Weather", "cloud.sun") {
                withAnimation {
                    vm.showStats = false
                }
            }
            Spacer()
            CapsuleButton("line.3.horizontal.decrease", "Filter") {
                
            }
           
        }
        .padding(.horizontal)
        .padding(.bottom,AppSafeArea.edges.bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
struct ChartsTopControls: View {
    @Bindable var vm: ChartsViewModel
    var body: some View {
        HStack{
            CircleButton("chevron.left") {
                vm.backAction()
            }
            Spacer()
            CircleButton("info") {
                
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
        .superContainer()
}
#endif
