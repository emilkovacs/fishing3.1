//
//  AppButtons.swift
//  fishing3
//
//  Created by Emil Kovács on 15. 7. 2025..
//

import SwiftUI





//MARK: - BUTTONS

struct CircleButton: View {
    
    let symbol: String
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button {
            animatePress(scale: $scale)
            AppHaptics.light()
            action()
        } label: {
            CircleLabel(symbol: symbol)
        }
        .scaleEffect(scale)
    }
    
    init(_ symbol: String, action: @escaping () -> Void) {
        self.symbol = symbol
        self.action = action
    }
}

struct CapsuleButton: View {
    
    let symbol: String
    let title: String
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button {
            animatePress(scale: $scale)
            AppHaptics.light()
            action()
        } label: {
            CapsuleLabel(symbol: symbol, title: title)
        }
        .scaleEffect(scale)
    }
    
    init(_ symbol: String, _ title: String, action: @escaping () -> Void) {
        self.symbol = symbol
        self.title = title
        self.action = action
    }
}


//MARK: - LABELS

struct CapsuleLabel: View {
    let symbol: String
    let title: String
    
    var body: some View {
        HStack(alignment: .center, spacing: AppSize.buttonSpacing) {
            
            Image(systemName: symbol)
                .foregroundStyle(AppColor.button)
                .fontWeight(.semibold)
                .font(.callout2)
            
            Text(title)
                .foregroundStyle(AppColor.button)
                .fontWeight(.semibold)
                .font(.callout2)
        }
        .padding(.horizontal)
        .frame(height: AppSize.buttonSize)
        .background(AppColor.secondary)
        .cornerRadius(AppSize.buttonSize)
        .contentShape(Rectangle())
    }
}

struct CircleLabel: View {
    let symbol: String
    var body: some View {
        Image(systemName: symbol)
            .foregroundStyle(AppColor.button)
            .fontWeight(.semibold)
            .font(.callout2)
            .frame(width: AppSize.buttonSize, height: AppSize.buttonSize)
            .background(AppColor.secondary)
            .cornerRadius(AppSize.buttonSize)
            .contentShape(Rectangle())
    }
}


//MARK: - HELPERS

func animatePress(scale: Binding<CGFloat>) {
    withAnimation(.bouncy.speed(2)) {
        scale.wrappedValue = 0.9
    }
    Task {
        try? await Task.sleep(nanoseconds: 150_000_000)
        withAnimation(.bouncy.speed(2)) {
            scale.wrappedValue = 1.0
        }
    }
}

#if DEBUG
struct AppButtons_PreviewWrapper: View {
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    HStack{
                        CircleLabel(symbol: "chevron.left")
                        CircleButton("circle") {
                            
                        }
                        CapsuleLabel(symbol: "matter.logo", title: "Matter")

                    }
                    .padding(.horizontal)
                    
                    
                    HStack{Spacer()}
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(AppColor.tone)
    }
}
#endif
#Preview {
    AppButtons_PreviewWrapper()
}
