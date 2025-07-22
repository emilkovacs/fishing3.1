//
//  ListBait.swift
//  fishing3
//
//  Created by Emil Kovács on 21. 7. 2025..
//

import SwiftUI
import SwiftData

@Observable
class ListBaitViewModel {
    
    var context: ModelContext
    var allBaits: [Bait]
    var filterString: String = ""
    var orderedBaits: [Bait] = []
    var filteredBaits: [Bait] {
        guard !filterString.isEmpty else { return orderedBaits}
        return orderedBaits.filter {$0.name.localizedCaseInsensitiveContains(filterString)}
    }
    
    let descriptor = FetchDescriptor<Bait>(
        sortBy: [SortDescriptor(\.name,order: .forward)]
    )
    
    // Select or Edit
    let mode: ListModes
    var listOrder: ListOrders = .recents
    let viewTitle: String
    
    var showEdit: Bool = false
    var backAction: () -> Void
    
    var editedBait: Bait = Bait("New Bait", .unknown, .unknown, "")
    var newBait: Bool = true
    
    init(
        mode: ListModes, context: ModelContext, backAction: @escaping () -> Void
    ) {
        
        self.context = context
        do {
            allBaits = try context.fetch(descriptor)
        } catch {
            #if DEBUG
            print("Failed to fetch baits.")
            #endif
            allBaits = []
        }
        
        self.mode = mode
        self.viewTitle = mode == .edit ? "All Baits" : "Select Bait"
        self.backAction = backAction
    }
    
    func updateSort(order: ListOrders) {
        switch order {
        case .forward:
                orderedBaits = allBaits.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            
        case .reverse:
 orderedBaits = allBaits.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
            }
        
        case .lastAdded:
            orderedBaits = allBaits.sorted {
                $0.timestamp > $1.timestamp
            }
            
        case .recents:
            var descriptor = FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
                descriptor.fetchLimit = 50

                if let recentEntries = try? context.fetch(descriptor) {
                    // Count by bait ID
                    var baitsFrequency: [PersistentIdentifier: Int] = [:]

                    for entry in recentEntries {
                        if let id = entry.bait?.persistentModelID {
 baitsFrequency[id, default: 0] += 1
                        }
                    }

                    // Sort allBaits by frequency via persistentModelID
                    orderedBaits = allBaits.sorted {
                        (baitsFrequency[$0.persistentModelID] ?? 0) > (baitsFrequency[$1.persistentModelID] ?? 0)
                    }
                } else {
                    orderedBaits = allBaits
                }
        }
    }
    
    func refresh(){
        do {
            allBaits = try context.fetch(descriptor)
        } catch {
            #if DEBUG
            print("Failed to fetch baits.")
            #endif
            allBaits = []
        }
    }
    func toggleStar(_ targetBait: Bait){
        withAnimation { targetBait.star.toggle() }
        
        try? context.save()
    }
    func showAddOverlay(){
        ///Refresh to get a new Bait..
        editedBait =  Bait("New Bait", .unknown, .unknown, "")
        newBait = true
        
        if filteredBaits.isEmpty {
            if !filterString.isEmpty {
 editedBait.name = filterString
            }
        }
        
        withAnimation{ showEdit = true }
    }
    func showEditOverlay(_ targetBait: Bait){
        editedBait = targetBait
        newBait = false
        withAnimation{ showEdit = true }
    }
    func hideEditOverlay(){
        withAnimation{ showEdit = false }
        refresh()
    }
}


struct ListBaits: View {
    
    @Bindable var vm: ListBaitViewModel
    @Binding var selectedBait: Bait?
    @AppStorage("BaitsListOrder") var listOrder: ListOrders = .recents
    
    init(
        mode: ListModes, selectedBait: Binding<Bait?>, context: ModelContext, backAction: @escaping () -> Void) {
            self.vm = ListBaitViewModel(mode: mode, context: context, backAction: backAction)
            self._selectedBait = selectedBait
        }
    
    var body: some View {
        ZStack{
            List{
                ListTopSpacer()
                
                ListTitle(title: vm.viewTitle,count: vm.filteredBaits.count)
                    .padding(.bottom,24)
                    .modifier(ListModifier())
                
                    
                ForEach(vm.filteredBaits){ bait in
                    BaitRow(bait: bait, selectedBait: $selectedBait, mode: vm.mode)
                        .modifier(ListModifier())
                }
                     
                
                if vm.allBaits.isEmpty {
                    Text("No Baits, tap + to add first.")
                        .foregroundStyle(AppColor.half)
                        .modifier(ListModifier())
                }
                
                ListBottomSpacer()
            }
            .listStyle(.plain)
            
            ListTopBlocker()
            ControlBar(listOrder: $listOrder)
            ListBottomBlocker()
            SearchBar(filterString: $vm.filterString, prompt: "Search baits")
            
            
            if vm.showEdit {
 
                EditBait(bait: vm.editedBait, new: vm.newBait) {
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
        @Environment(ListBaitViewModel.self) var vm
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
 
    struct BaitRow: View {
        @Environment(ListBaitViewModel.self) var vm
        let bait: Bait
        @Binding var selectedBait: Bait?
        let mode: ListModes
        
        var body: some View {
            VStack(spacing: 0) {
                HStack{
                    if selectedBait == bait {
                        Image(systemName: "checkmark")
                    }
                    if bait.star {
                        Image(systemName: "star.fill")
                            .foregroundStyle(AppColor.half)
                            .font(.callout2)
                            .fontWeight(.medium)
                    }
                    Text(bait.name)
                        .fontWeight(.medium)
                        .font(.callout)
                    Spacer()
                    Image(systemName: bait.type.symbolName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColor.half)
                        .frame(width: 20,alignment: .center)
                    
                    Image(systemName: bait.position.symbolName)
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
                    selectedBait = bait
                    vm.backAction()
                    AppHaptics.light()
                } else {
                    vm.showEditOverlay(bait)
                    AppHaptics.light()
                }
            }
            .contextMenu{
                if mode == .select {
                
                    let title: String = selectedBait == bait ? "Discard" : "Select"
                    let systemImage: String = selectedBait == bait ? "xmark.circle" : "checkmark.circle"
                    
                    Button(title, systemImage: systemImage) {
                        if selectedBait == bait {
                            selectedBait = nil
                        } else {
                            selectedBait = bait
                        }
                    }
                    
                }
                Button("Edit", systemImage: "pencil") { vm.showEditOverlay(bait)}
                Button(bait.star ? "Unstar" : "Star", systemImage: bait.star ? "star" : "star.fill") {
                    vm.toggleStar(bait)
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button("Star", systemImage: "star") {
                    vm.toggleStar(bait)
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Edit", systemImage: "pencil") {
                    vm.showEditOverlay(bait)
                }
            }
            
        }
    }

}




//MARK: - PREVIEW
#if DEBUG
struct ListBaits_PreviewWrapper: View {
    @Environment(\.modelContext) var context
    @State private var bait: Bait?
    var body: some View {
        ListBaits(mode: .select, selectedBait: $bait, context: context) { }
    }
}

#Preview {
 ListBaits_PreviewWrapper()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
}
#endif



