//
//  ListSpecies.swift
//  fishing3
//
//  Created by Emil Kovács on 17. 7. 2025..
//

import SwiftUI
import SwiftData

enum ListOrders: String, Selectable {
    case recents, lastAdded, forward, reverse
    var id: String {self.rawValue}
    var label: String {
        switch self {
        case .recents: return "Recents"
        case .lastAdded: return "Last Added"
        case .forward: return "A-Z"
        case .reverse: return "Z-A"
        }
    }
    var shortLabel: String {
        self.label
    }
    var symbolName: String {
        switch self {
        case .recents: return "cursorarrow.click.badge.clock"
        case .lastAdded: return "plus.arrow.trianglehead.clockwise"
        case .forward: return "arrowshape.forward.circle"
        case .reverse: return "arrowshape.backward.circle"
        }
    }
    
}
enum ListModes { case select, edit }

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
    
    var showEdit: Bool = false
    var backAction: () -> Void
    
    var editedSpecie: Species = Species("New Species", .unknown, .unknown)
    var newSpecies: Bool = true
    
    init(
        mode: ListModes, context: ModelContext, backAction: @escaping () -> Void
    ) {
        
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
        self.backAction = backAction
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
    func showAddOverlay(){
        ///Refresh to get a new Species..
        editedSpecie =  Species("New Species", .unknown, .unknown)
        newSpecies = true
        
        if filteredSpecies.isEmpty {
            if !filterString.isEmpty {
                editedSpecie.name = filterString
            }
        }
        
        withAnimation{ showEdit = true }
    }
    func showEditOverlay(_ targetSpecies: Species){
        editedSpecie = targetSpecies
        newSpecies = false
        withAnimation{ showEdit = true }
    }
    func hideEditOverlay(){
        withAnimation{ showEdit = false }
        refresh()
    }
}

struct ListSpecies: View {
    
    @Bindable var vm: ListSpeciesViewModel
    @Binding var selectedSpecies: Species?
    @AppStorage("SpeciesListOrder12") var listOrder: ListOrders = .recents
    
    init(
        mode: ListModes, selectedSpecies: Binding<Species?>, context: ModelContext, backAction: @escaping () -> Void) {
            self.vm = ListSpeciesViewModel(mode: mode, context: context, backAction: backAction)
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
                        .modifier(ListModifier())
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
            ControlBar(listOrder: $listOrder)
            ListBottomBlocker()
            SearchBar(filterString: $vm.filterString, prompt: "Search species")
            
            if vm.showEdit {
                EditSpecies(species: vm.editedSpecie, new: vm.newSpecies) {
                    vm.hideEditOverlay()
                    vm.filterString = ""
                    vm.refresh()
                    vm.updateSort(order: .lastAdded)
                }
                .transition(.blurReplace)
            }
            
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
    
    struct ControlBar: View {
        @Environment(ListSpeciesViewModel.self) var vm
        @Binding var listOrder: ListOrders
        var body: some View {
            HStack{
                CircleButton("chevron.left") { vm.backAction() }
                Spacer()
                CircleSelector(symbol: "line.3.horizontal.decrease", selection: $listOrder)
                CapsuleButton("plus", "Add") { vm.showAddOverlay() }
            }
            .padding(.top,AppSafeArea.edges.top)
            .padding(.horizontal)
            
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
    struct SpeciesRow: View {
        @Environment(ListSpeciesViewModel.self) var vm
        let species: Species
        @Binding var selectedSpecies: Species?
        let mode: ListModes
        
        var body: some View {
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
            .onTapGesture {
                if mode == .select {
                    selectedSpecies = species
                    AppHaptics.light()
                } else {
                    vm.showEditOverlay(species)
                    AppHaptics.light()
                }
            }
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
                Button("Edit", systemImage: "pencil") { vm.showEditOverlay(species)}
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
                    vm.showEditOverlay(species)
                }
            }
            
        }
    }

}

struct ListModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSpacing(0)
            .listRowBackground(AppColor.tone)
            .listRowSeparator(.hidden)
        
    }
}
struct ListTopSpacer: View {
    var body: some View {
        Spacer().frame(
            height: AppSafeArea.edges.top + AppSize.buttonSize + 32
        )
            .modifier(ListModifier())
    }
}
struct ListBottomSpacer: View {
    var body: some View {
        Spacer().frame(
            height: AppSafeArea.edges.bottom + AppSize.buttonSize + 32
        )
            .modifier(ListModifier())
    }
}
struct ListTitle: View {
    let title: String
    let count: Int?
    var body: some View {
        HStack(alignment: .firstTextBaseline){
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(AppColor.primary)
            Spacer()
            if let number = count {
                Text("\(number)")
                    .font(.callout2)
                    .foregroundStyle(AppColor.half)
            }
        }
    }
}
struct ListTopBlocker: View {
    var body: some View {
        LinearGradient(colors: [
            AppColor.tone,AppColor.tone.opacity(0.65),Color.clear
        ],startPoint: .top, endPoint: .bottom)
        .frame(height: 112)
        .frame(maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
    }
}
struct ListBottomBlocker: View {
    var body: some View {
        LinearGradient(colors: [
            AppColor.tone,AppColor.tone.opacity(0.9),Color.clear
        ],startPoint: .bottom, endPoint: .top)
        .frame(height: 112)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
    }
}





//MARK: - PREVIEW
#if DEBUG
struct ListSpecies_PreviewWrapper: View {
    @Environment(\.modelContext) var context
    @State private var species: Species?
    var body: some View {
        ListSpecies(mode: .select, selectedSpecies: $species, context: context) { }
    }
}

#Preview {
    ListSpecies_PreviewWrapper()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
}
#endif
