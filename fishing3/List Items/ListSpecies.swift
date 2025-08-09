//
//  ListSpecies.swift
//  fishing3
//
//  Created by Emil Kovács on 17. 7. 2025..
//

import SwiftUI
import SwiftData


@Observable
class ListSpeciesViewModel {
    
    var context: ModelContext
    var allSpecies: [Species]
    var filterString: String = ""
    var orderedSpecies: [Species] = []
    var filteredSpecies: [Species] {
        guard !filterString.isEmpty else { return orderedSpecies}
        return orderedSpecies.filter { $0.name.localizedCaseInsensitiveContains(filterString) }
    }
    
    let descriptor = FetchDescriptor<Species>(
        sortBy: [SortDescriptor(\.name,order: .forward)]
    )
    
    // Select or Edit
    let mode: ListModes
    var listOrder: ListOrders = .recents
    let viewTitle: String
        
    
    init(mode: ListModes, context: ModelContext,) {
        
        self.context = context
        do {
            allSpecies = try context.fetch(descriptor)
        } catch {
            #if DEBUG
            print("Failed to fetch species.")
            #endif
            allSpecies = []
        }
        
        self.mode = mode
        self.viewTitle = mode == .edit ? "All Species" : "Select Species"
        
        self.orderedSpecies = allSpecies
    }
    
    func updateSort(order: ListOrders) {
        switch order {
        case .forward:
            orderedSpecies = allSpecies.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            
        case .reverse:
            orderedSpecies = allSpecies.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
            }
        
        case .lastAdded:
            orderedSpecies = allSpecies.sorted {
                $0.timestamp > $1.timestamp
            }
            
        case .recents:
            var descriptor = FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
                descriptor.fetchLimit = 50

                if let recentEntries = try? context.fetch(descriptor) {
                    // Count by species ID
                    var speciesFrequency: [PersistentIdentifier: Int] = [:]

                    for entry in recentEntries {
                        if let id = entry.species?.persistentModelID {
                            speciesFrequency[id, default: 0] += 1
                        }
                    }

                    // Sort allSpecies by frequency via persistentModelID
                    orderedSpecies = allSpecies.sorted {
                        (speciesFrequency[$0.persistentModelID] ?? 0) > (speciesFrequency[$1.persistentModelID] ?? 0)
                    }
                } else {
                    orderedSpecies = allSpecies
                }
        }
    }
    
    func refresh(){
        do {
            allSpecies = try context.fetch(descriptor)
        } catch {
            #if DEBUG
            print("Failed to fetch species.")
            #endif
            allSpecies = []
        }
    }
    func toggleStar(_ targetSpecies: Species){
        withAnimation { targetSpecies.star.toggle() }
        try? context.save()
    }
}

struct ListSpecies: View {
    
    @Bindable var vm: ListSpeciesViewModel
    @Binding var selectedSpecies: Species?
    @AppStorage("SpeciesListOrder12") var listOrder: ListOrders = .recents
    @Namespace var namespace
    
    init(
        mode: ListModes, selectedSpecies: Binding<Species?>, context: ModelContext
    ) {
            self.vm = ListSpeciesViewModel(mode: mode, context: context)
            self._selectedSpecies = selectedSpecies
        }
    
    var body: some View {
        ZStack{
            List{
                ListTopSpacer()
                
                ListTitle(title: vm.viewTitle,count: vm.filteredSpecies.count)
                    .padding(.bottom,24)
                    .modifier(ListModifier())
                
                ForEach(vm.filteredSpecies){ specie in
                    SpeciesRow(species: specie, selectedSpecies: $selectedSpecies, mode: vm.mode)
                }
                
                if vm.allSpecies.isEmpty {
                    Text("No Species, tap + to add first.")
                        .foregroundStyle(AppColor.half)
                        .modifier(ListModifier())
                }
                
                ListBottomSpacer()
            }
            .listStyle(.plain)
            
            ListTopBlocker()
            ListSpeciesTopBar(listOrder: $listOrder)
            ListBottomBlocker()
            SearchBar(filterString: $vm.filterString, prompt: "Search species")
            
        }
        .environment(vm)
        .background(AppColor.tone.ignoresSafeArea(.all))
        .ignoresSafeArea(.container)
        .onAppear {
            vm.updateSort(order: listOrder)
        }
        .onChange(of: listOrder) { oldValue, newValue in
            vm.updateSort(order: listOrder)
        }
    }
    
}

struct ListSpeciesTopBar: View {
    
    @Environment(ListSpeciesViewModel.self) var vm
    @Environment(\.dismiss) var dismiss
    @Binding var listOrder: ListOrders
    
    @State private var newSpecies = Species("New Species", .unknown, .unknown)
    @State private var showEditor: Bool = false
    @Namespace var namespace
    
    var body: some View {
        HStack{
            CircleButton("chevron.left") { dismiss() }
            Spacer()
            CircleSelector(symbol: "line.3.horizontal.decrease", selection: $listOrder)
            CapsuleButton("plus", "Add") {
                newSpecies = Species("New Species", .unknown, .unknown)
                showEditor.toggle()
            }
            .matchedTransitionSource(id: "base", in: namespace)
            .navigationDestination(isPresented: $showEditor) {
                EditSpecies(species: newSpecies, new: true, namespace: namespace) {
                    vm.filterString = ""
                    vm.updateSort(order: .lastAdded)
                    vm.refresh()
                    vm.updateSort(order: .lastAdded)
                }
            }
        }
        .topBarPlacement()
    }
}

struct SpeciesRow: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ListSpeciesViewModel.self) var vm
    let species: Species
    @Binding var selectedSpecies: Species?
    let mode: ListModes
    
    @State private var showEditor: Bool = false
    @Namespace var namespace
    
    var body: some View {
        Button {
            if mode == .select {
                AppHaptics.light()
                selectedSpecies = species
                dismiss()
            } else {
                AppHaptics.light()
                showEditor.toggle()
            }
        } label: {
            VStack(spacing: 0) {
                HStack{
                    if selectedSpecies == species {
                        Image(systemName: "checkmark")
                    }
                    if species.star {
                        Image(systemName: "star.fill")
                            .foregroundStyle(AppColor.half)
                            .font(.callout2)
                            .fontWeight(.medium)
                    }
                    Text(species.name)
                        .fontWeight(.medium)
                        .font(.callout)
                        .matchedTransitionSource(id: "name", in: namespace)
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
            .background(AppColor.tone)
            .matchedTransitionSource(id: "base", in: namespace)
            
        }
        .listModifier()
        .contextMenu{
            if mode == .select {
            
                let title: String = selectedSpecies == species ? "Discard" : "Select"
                let systemImage: String = selectedSpecies == species ? "xmark.circle" : "checkmark.circle"
                
                Button(title, systemImage: systemImage) {
                    if selectedSpecies == species {
                        selectedSpecies = nil
                    } else {
                        selectedSpecies = species
                    }
                }
                
            }
            Button("Edit", systemImage: "pencil") { showEditor.toggle()}
            Button(species.star ? "Unstar" : "Star", systemImage: species.star ? "star" : "star.fill") {
                vm.toggleStar(species)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button("Star", systemImage: "star") {
                vm.toggleStar(species)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Edit", systemImage: "pencil") {
                AppHaptics.light()
                showEditor.toggle()
            }
        }
        .navigationDestination(isPresented: $showEditor) {
            EditSpecies(species: species, new: false, namespace:namespace){
                vm.filterString = ""
                vm.refresh()
                vm.updateSort(order: .lastAdded)
            }
        }
        
    }
}



//MARK: - PREVIEW
#if DEBUG
struct ListSpecies_PreviewWrapper: View {
    @Environment(\.modelContext) var context
    @State private var species: Species?
    var body: some View {
        ListSpecies(mode: .edit, selectedSpecies: .constant(nil), context: context)
    }
}

#Preview {
    NavigationStack{
        ListSpecies_PreviewWrapper()
    }
    .superContainer()
}
#endif
