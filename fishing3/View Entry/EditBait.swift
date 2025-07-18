//
//  EditBait.swift
//  fishing3
//
//  Created by Emil Kovács on 18. 7. 2025..
//

import SwiftUI
import SwiftData


struct EditBait: View {
    
    @Environment(\.modelContext) var context
    
    @Bindable var bait: Bait
    var new: Bool
    var backAction: () -> Void
    
    var title: String {
        new ? "New Bait" : "Edit Bait"
    }
    
    @State private var alertDisplay: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.medium)
                        .padding(.bottom,32)
                    
                    LargeStringInput("Name", "Unique Name", $bait.name)
                    LargeSelector("Type", $bait.type)
                    LargeSelector("Position", $bait.position)
                    LargeStringVerticalInput("Notes", "Optional notes", $bait.notes)
                    bottomControls
                }
                .padding(.horizontal)
                .padding(.top,64+16)
                .padding(.top,AppSafeArea.edges.top)
            }
            topControls
            
        }
        .background(AppColor.tone)
        .ignoresSafeArea(.container)
        .alert(alertTitle, isPresented: $alertDisplay) {} message: {Text(alertMessage)}
    }
    
    var topControls: some View {
        HStack{
            CircleButton("chevron.left") { back() }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top,AppSafeArea.edges.top)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    var bottomControls: some View {
        HStack{
            CircleButton("trash") {
                delete()
            }
            Spacer()
            CapsuleButton("plus", new ? "Add" : "Save") {
                saveOrCreate()
            }
        }
        .padding(.top,32)
        .padding(.bottom,AppSafeArea.edges.bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
    
    func alertUser(_ title: String, _ message: String){
        alertTitle = title
        alertMessage = message
        alertDisplay = true
    }
    
    func delete(){
        withAnimation {
            context.delete(bait)
        }
        
        do {
            try context.save()
        } catch {
            alertUser("Error", "Failed to delete or save bait.")
        }
        
        backAction()
    }
    func back(){
        context.rollback()
        
        do {
            try context.save()
        } catch {
            alertUser("Error", "Failed to save bait.")
        }
        
        backAction()
    }
    func saveOrCreate(){
        //Normalize name
        bait.name = bait.name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Empty name check
        guard !bait.name.isEmpty else {
            alertUser("Empty Name", "Give your bait a name.")
            return
        }
        
        let nameToCheck = bait.name

        let descriptor = FetchDescriptor<Bait>(
            predicate: #Predicate { $0.name == nameToCheck }
        )

        do {
            let matchingBaits = try context.fetch(descriptor)

            let isDuplicate = matchingBaits.contains { $0.id != bait.id }

            if isDuplicate {
                alertUser("Duplicate Name", "Give your bait a unique name.")
                return
            }
        } catch {
            alertUser("Error", "Failed to check for duplicate name.")
        }
            
        
        //Save and insert if needed
        if new { context.insert(bait) }
        
        do {
            try context.save()
        } catch {
            alertUser("Error", "Failed to save bait.")
        }
        
        //Close view
        backAction()
    }
}




#if DEBUG
struct EditBait_PreviewWrapper: View {
    
    @Query var baits: [Bait]
    @State private var bait: Bait = Bait("Trailing", .fly, .midwater, "")
    
    var body: some View {
        EditBait(bait: bait, new: true) {
            print("bck")
        }
    }
}

#Preview {
    EditBait_PreviewWrapper()
        .modelContainer(for: [Entry.self,Species.self,Bait.self],inMemory: false)
}
#endif
