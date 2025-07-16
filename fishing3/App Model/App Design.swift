//
//  App Design.swift
//  fishing3
//
//  Created by Emil Kovács on 11. 7. 2025..
//

import Foundation
import SwiftUI



struct AppColor {
    static let primary: Color = Color("app_primary")
    static let half: Color = Color("app_half")
    static let secondary: Color = Color("app_secondary")
    static let tone: Color = Color("app_tone")
    static let dark: Color = Color("app_dark")
    static let button: Color = Color("app_button")
}

struct AppSize {
    static let size: CGFloat = 38.0
    static let radius: CGFloat = 18.0
    static let spacing: CGFloat = 8.0
    
    static let buttonSpacing: CGFloat = 6.0
    static let buttonPadding: CGFloat = 16.0
    static let buttonSize: CGFloat = 38.0
}

struct AppHaptics {
    static func light(){
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    static func heavy(){
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

struct AppUnits {
    static let usesMetric: Bool = Locale.current.measurementSystem == .metric
    
    static let weight: String = usesMetric ? "kg" : "lb"
    static let length: String = usesMetric ? "cm" : "in"
    
}
    

extension Font {
    static let callout2: Font = .system(size: 14)
}


class AppSafeArea {
    static let edges = AppSafeArea()

    private(set) var top: CGFloat = 0
    private(set) var bottom: CGFloat = 0

    private let userDefaultsKey = "safeArea"

    private init() {
        loadOrCapture()
    }

    func update(from insets: UIEdgeInsets) {
        top = insets.top
        bottom = insets.bottom
        save()
    }

    // MARK: - Persistence

    private func save() {
        let dict: [String: CGFloat] = ["top": top, "bottom": bottom]
        UserDefaults.standard.set(dict, forKey: userDefaultsKey)
    }

    private func loadOrCapture() {
        if let dict = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: CGFloat] {
            top = dict["top"] ?? 0
            bottom = dict["bottom"] ?? 0
        } else if let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow }) {
            update(from: window.safeAreaInsets)
        }
    }
}
