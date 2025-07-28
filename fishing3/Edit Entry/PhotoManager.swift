//
//  PhotoManager].swift
//  fishing3
//
//  Created by Emil Kovács on 28. 7. 2025..
//

import SwiftUI



struct PhotoManager: View {
    
    @Binding var photos: [UIImage]
    var backAction: () -> Void
    
    @State private var editMode: Bool = false
    @AppStorage("phGridDisplay") var gridDisplay: Bool = true
    
    private var columns: [GridItem] {
            Array(repeating: GridItem(.flexible()), count: gridDisplay ? 2 : 1)
        }
    var spacing: CGFloat { gridDisplay ? 8 : 16 }
    var corner: CGFloat { gridDisplay ? 8 : 12 }
    
    var enumeratedPhotos: [(offset: Int, element: UIImage)] { Array(photos.enumerated()) }
    
    var body: some View {
        ZStack{
            ScrollView{
                LazyVGrid(columns: columns, alignment: .leading, spacing: spacing) {
                    ForEach(enumeratedPhotos,id: \.offset ){ index, photo in
                        PhotoManagerItem(photo: photo, index: index, corner: corner, editMode: editMode){
                            photos.remove(at: index)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top,AppSafeArea.edges.top + AppSize.buttonSize + 32)
                .padding(.bottom,AppSafeArea.edges.bottom + 32)
            }
            .scrollIndicators(.hidden)
            .animation(.snappy, value: gridDisplay)
            .animation(.default, value: editMode)
            .animation(.default, value: photos)
            
            ListTopBlocker()
            PhotoManagerControls(editMode: $editMode, gridDisplay: $gridDisplay) {
                backAction()
            }
            
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
    }
}

struct PhotoManagerItem: View {
    
    let photo: UIImage
    let index: Int
    
    let corner: CGFloat
    let editMode: Bool
    
    let deleteAction: () -> Void
    
    var body: some View {
        Image(uiImage: photo)
            .resizable()
            .scaledToFit()
            .cornerRadius(corner)
            .overlay(alignment: .bottomTrailing) {
                if editMode {
                    CircleButton("trash") {
                        deleteAction()
                    }
                    .scaleEffect(0.75)
                }
            }
    }
}
struct PhotoManagerControls: View {
    @Binding var editMode: Bool
    @Binding  var gridDisplay: Bool
    var backAction: () -> Void
    
    var body: some View {
        HStack{
            CircleButton("chevron.left") { backAction() }
            Spacer()
            CircleButton(gridDisplay ? "rectangle.grid.1x2" :  "square.grid.2x2") {
                gridDisplay.toggle()
            }
            CircleButton(editMode ? "checkmark" :  "pencil") {
                editMode.toggle()
            }
            
        }
        .padding(.top,AppSafeArea.edges.top)
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}


//MARK: - PREVIEW

#if DEBUG

struct PhotoManager_PreviewWrapper: View {
    
    @State private var photos: [UIImage] = [
        UIImage(named: "demoA")!,
        UIImage(named: "demoB")!,
        UIImage(named: "demoC")!,
        UIImage(named: "demoD")!,
        UIImage(named: "demoE")!,
    ]
    
    var body: some View {
        PhotoManager(photos: $photos) {
            print("Back action trigerred")
        }
    }
}

#Preview {
    PhotoManager_PreviewWrapper()
}

#endif
