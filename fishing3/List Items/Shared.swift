//
//  ListSharedItems.swift
//  fishing3
//
//  Created by Emil Kovács on 21. 7. 2025..
//

import SwiftUI

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

