//
//  SettingsView.swift
//  fishing3
//
//  Created by Emil Kovács on 5. 8. 2025..
//

import SwiftUI
import SwiftData


/// Manage Entries
/// Manage Species
/// Manage Baits

/// Color scheme
/// AppIcon

/// Fishing Pro
/// Manage subscription
/// Restore purchases


/// Analytics
/// Terms of use
/// Privacy policy

//Danger zone
/// Export data backup
/// Import data backup
/// Delete all records


enum SettingsViews {
    case list
    case catches,baits,species,data
    case feedback
    case acknow,about,paywall
}

struct SettingsView: View {
    @Environment(\.modelContext) var context
    @State private var view: SettingsViews = .list
    var backAction: () -> Void
    
    var body: some View {
        ZStack{
            switch view {
            case .list:
                SettingsList(view:$view){ backAction() }
            case .catches:
                Text("Catches")
            case .baits:
                ListBaits(
                    mode: .edit, selectedBait: .constant(nil), context: context, backAction: {backHomeAction()}
                )
                .transition(.blurReplace)
            case .species:
                ListSpecies(
                    mode: .edit, selectedSpecies: .constant(nil), context: context, backAction: {backHomeAction()}
                )
                .transition(.blurReplace)
            case .data:
                Text("Catches")
            case .feedback:
                Text("Catches")
            case .acknow:
                Text("Catches")
            case .about:
                Text("Catches")
            case .paywall:
                Text("Catches")
            }
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
    }
    
    func backHomeAction(){
        withAnimation {
            view = .list
        }
    }
}

struct SettingsList: View {
    @Binding var view: SettingsViews
    var backAction: () -> Void
    
    var body: some View {
        ZStack{
            List {
                ListTopSpacer()
                Text("Manage Data")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom,8)
                    .modifier(ListModifier())
                SettingsRowLabel("Manage Catches", symbol: "circle")
                SettingsRowButton("Manage Species", symbol: "fish") {
                    withAnimation {
                        view = .species
                    }
                }
                SettingsRowButton("Manage Baits", symbol: "circle") {
                    withAnimation {
                        view = .baits
                    }
                }
                
                
                SettingsRowLabel("Data backup", symbol: "circle")
                
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top,48)
                    .padding(.bottom,8)
                    .modifier(ListModifier())
                
                SettingsRowLabel("Color scheme", symbol: "circle")
                SettingsRowLabel("App icon", symbol: "circle")
                SettingsRowLabel("Analytics", symbol: "circle")
                
                Text("Subscription")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top,48)
                    .padding(.bottom,8)
                    .modifier(ListModifier())
                SettingsRowLabel("Manage Subscription", symbol: "circle")
                SettingsRowLabel("Restore purchases", symbol: "circle")
                SettingsRowLabel("Send feedback", symbol: "circle")
                SettingsRowLabel("Write a review", symbol: "circle")
               
                
                Text("Documents")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top,48)
                    .padding(.bottom,8)
                    .modifier(ListModifier())
                
                SettingsRowLabel("Privacy Policy", symbol: "circle")
                SettingsRowLabel("Terms of Use", symbol: "circle")
                SettingsRowLabel("Acknodgwelemnebts", symbol: "circle")
                SettingsRowLabel("About", symbol: "circle")
                
                ListBottomSpacer()
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            ListTopBlocker()
            SettingsListTopControls { backAction() }
        }
        .ignoresSafeArea(.container)
        .background(AppColor.tone.ignoresSafeArea(.all))
    }
}

struct SettingsRowButton: View {
    let title: String
    let leadingSymbol: String
    let trailingSymbol: String
    let action: () -> Void
    var body: some View {
        Button {
            AppHaptics.light()
            action()
        } label: {
            SettingsRowLabel(title, symbol: leadingSymbol, trailingSymbol: trailingSymbol)
        }
        .modifier(ListModifier())
    }
    
    init(_ title: String, symbol: String, trailingSymbol: String = "chevron.right", action: @escaping () -> Void) {
        self.title = title
        self.leadingSymbol = symbol
        self.trailingSymbol = trailingSymbol
        self.action = action
    }
}
struct SettingsRowLabel: View {
    
    let title: String
    let leadingSymbol: String
    let trailingSymbol: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            HStack{
                Image(systemName: leadingSymbol)
                    .frame(width: 22,alignment: .center)
                    .font(.callout2)
                Text(title)
                    .fontWeight(.medium)
                    .font(.callout)
                Spacer()
                Image(systemName: trailingSymbol)
                    .foregroundStyle(AppColor.half)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.vertical,16)
            Divider()
        })
        .modifier(ListModifier())
    }
    
    init(_ title: String, symbol: String, trailingSymbol: String = "chevron.right") {
        self.title = title
        self.leadingSymbol = symbol
        self.trailingSymbol = trailingSymbol
    }
}
struct SettingsListTopControls: View {
    var backAction: () -> Void
    var body: some View {
        HStack{
            CircleButton("chevron.left") { backAction() }
            Spacer()
            CapsuleButton("tray.fill","Ideas") {
                
            }
        }
        .padding(.top,AppSafeArea.edges.top)
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
}

#if DEBUG

struct SettingsView_PreviewWrapper: View {
    var body: some View {
        SettingsView {
            print("⏮️ Main UI back action triggered.")
        }
    }
}

#Preview {
    SettingsView_PreviewWrapper()
        .superContainer()
}

#endif
