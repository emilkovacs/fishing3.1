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

struct SelectorButton: View {
    
    let title: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .padding(.bottom,8)
                    .foregroundStyle(AppColor.half)
                    .font(.callout2)
                    .fontWeight(.medium)
                HStack{
                    Text(label)
                        .foregroundStyle(AppColor.primary)
                        .fontWeight(.medium)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColor.button)
                }
                
                Divider().padding(.vertical,16)
            }
        }

    }
    
    init(_ title: String, _ label: String, action: @escaping () -> Void) {
        self.title = title
        self.label = label
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

//MARK: - INPUTS

struct SearchBar: View {
    
    @Binding var filterString: String
    let prompt: String
    
    @FocusState private var focused
    
    var body: some View {
        TextField(text: $filterString, prompt: Text(prompt)) { Text(filterString) }
            .font(.callout)
            .fontWeight(.medium)
            .foregroundStyle(AppColor.primary)
            .autocorrectionDisabled()
        
            .frame(height: AppSize.buttonSize * 1.25)
            .padding(.leading,AppSize.buttonSize + 6)
            .background(AppColor.secondary)
            .cornerRadius(AppSize.buttonSize * 1.2)
            .overlay(alignment: .leading) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColor.button)
                    .padding(.leading)
                    .fontWeight(.semibold)
                    .font(.callout2)
            }
            .overlay(alignment: .trailing) {
                if !filterString.isEmpty {
                    Button {
                        filterString = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(AppColor.button)
                            .frame(width: AppSize.buttonSize + 6, height: AppSize.buttonSize)
                            .fontWeight(.semibold)
                            .font(.caption)
                            .contentShape(Rectangle())
                    }
                }
            }
            .padding(.horizontal)
        
            .focused($focused)
            .onDisappear { focused = false }
            .onTapGesture { focused = true }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom,AppSafeArea.edges.bottom)
        
            
            
    }
}

struct LargeStringInput: View {
    
    let title: String
    let prompt: String
    @Binding var text: String
    let limit: Int
    
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .padding(.bottom,8)
                .foregroundStyle(AppColor.half)
                .font(.callout2)
                .fontWeight(.medium)
            TextField(text: $text, prompt: Text(prompt), label: {Text(title)})
                .fontWeight(.medium)
                .font(.headline)
                .focused($focused)
                .onDisappear { focused = false }
                .onChange(of: focused, { oldValue, newValue in
                    if text == "New Species" || text == "New Bait" {
                        text = ""
                    }
                    if newValue {
                        AppHaptics.light()
                    }
                })
                .onChange(of: text, { oldValue, newValue in
                    if newValue.count >= limit {
                        text = oldValue
                    }
                })
                .overlay(alignment: .trailing) {
                    if !text.isEmpty {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(AppColor.button)
                                .frame(width: AppSize.buttonSize, height: AppSize.buttonSize,alignment: .trailing)
                                .fontWeight(.semibold)
                                .font(.caption)
                                .contentShape(Rectangle())
                                
                        }
                    }
                }
                
            
            Divider().padding(.vertical,16)
        }
    }
    
    init(_ title: String, _ prompt: String, _ text: Binding<String>, limit: Int = 24) {
        self.title = title
        self.prompt = prompt
        self._text = text
        self.limit = limit
    }
}

struct LargeStringVerticalInput: View {
    
    let title: String
    let prompt: String
    @Binding var text: String
    let limit: Int
    
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .padding(.bottom,8)
                .foregroundStyle(AppColor.half)
                .font(.callout2)
                .fontWeight(.medium)
             
            //TextField(text: $text, prompt: Text(prompt), label: {Text(title)})
            
            TextField("", text: $text, prompt: Text(prompt), axis: .vertical)
                .fontWeight(.medium)
                .font(.headline)
                .focused($focused)
                .onDisappear { focused = false }
                .onChange(of: focused, { oldValue, newValue in
                    if newValue {
                        AppHaptics.light()
                    }
                })
                .onChange(of: text, { oldValue, newValue in
                    if newValue.count >= limit {
                        text = oldValue
                    }
                })
                            
            Divider().padding(.vertical,16)
        }
    }
    
    init(_ title: String, _ prompt: String, _ text: Binding<String>, limit: Int = 120) {
        self.title = title
        self.prompt = prompt
        self._text = text
        self.limit = limit
    }
}


//Numer filed

struct LargeDoubleInput: View {
    
    
    let title: String
    @Binding var value: Double?
    let unit: String
    var prompt: String { "0 \(unit)" }
    
    @FocusState var focused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .padding(.bottom,8)
                .foregroundStyle(AppColor.half)
                .font(.callout2)
                .fontWeight(.medium)
            NumberField(value: $value, title: title, prompt: prompt)
                .focused($focused)
                .fontWeight(.medium)
                .font(.headline)
            
                .overlay(alignment: .leading) {
                    HStack(spacing:0){
                        if !focused && value != nil {
                            if value == nil {
                                Text(prompt)
                                    .opacity(0.0)
                            } else {
                                Text(AppFormatter.numberInput.string(from: value == nil ? 0 : value! as NSNumber) ?? "0")
                                    .opacity(0.0)
                            }
                            Text(" \(unit)")
                                .foregroundStyle(AppColor.half)
                        }
                    }
                    .fontWeight(.medium)
                }


                
            
            Divider().padding(.vertical,16)
        }
    }
}

struct NumberField: View {
    
    //Creates a "root" type like textfield, but can be used for numbers. :)
    
    @Binding var value: Double?
    var title: String
    var prompt: String
    
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    let defaultValue: String = ""
    
    var body: some View {
        TextField(title, text: $text, prompt: Text(prompt))
            .keyboardType(.numbersAndPunctuation)
            .autocorrectionDisabled()
            .scrollDismissesKeyboard(.immediately)
        
            .focused($isFocused)
            .onAppear {
                text = value.flatMap { AppFormatter.numberInput.string(from: NSNumber(value: $0)) } ?? defaultValue
            }
            .onChange(of: isFocused) { _ , focused in
                if focused {
                    if text == defaultValue {
                        text = ""
                    }
                } else {
                    let cleaned = sanitizeInput(text)
                    if let number = AppFormatter.numberInput.number(from: cleaned) {
                        value = number.doubleValue
                    } else {
                        value = nil
                    }
                    text = value
                        .flatMap { AppFormatter.numberInput.string(from: NSNumber(value: $0)) }
                        ?? defaultValue
                }
            }
        
    }
    
    private func sanitizeInput(_ input: String) -> String {
        let decimalSeparator = AppFormatter.numberInput.decimalSeparator ?? "."
        var allowed = CharacterSet.decimalDigits
        allowed.insert(charactersIn: decimalSeparator)

        var sanitized = input
            .replacingOccurrences(of: ".", with: decimalSeparator)
            .replacingOccurrences(of: ",", with: decimalSeparator)

        sanitized = sanitized.components(separatedBy: allowed.inverted).joined()

        if let first = sanitized.firstIndex(of: Character(decimalSeparator)) {
            let before = sanitized[..<sanitized.index(after: first)]
            let after = sanitized[sanitized.index(after: first)...].replacingOccurrences(of: decimalSeparator, with: "")
            sanitized = before + after
        }

        return sanitized
    }
}


//Selector
struct CircleSelector<T:Selectable>: View {
    let symbol: String
    @Binding var selection: T
    var body: some View {
        Menu {
            Picker("", selection: $selection) {
                ForEach(T.allCases){ item in
                    Label(item.label, systemImage: item.symbolName).tag(item)
                }
            }
        } label: {
            CircleLabel(symbol: symbol)
        }
        .buttonStyle(ActionButtonStyle({
            AppHaptics.light()
        }))

    }
}

struct LargeSelector<T:Selectable>: View {
    

    let title: String
    @Binding var selection: T
    
    var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                ForEach(T.allCases){ item in
                    Label(item.label, systemImage: item.symbolName).tag(item)
                }
            }
        } label: {
            VStack(alignment: .leading,spacing: 0){
                Text(title)
                    .padding(.bottom,8)
                    .foregroundStyle(AppColor.half)
                    .font(.callout2)
                    .fontWeight(.medium)
                HStack{
                    Text(selection.label)
                        .font(.headline)
                    if selection.label != "Unknown" {
                        Image(systemName: selection.symbolName)
                            .font(.callout2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColor.button)
                }
                .foregroundStyle(AppColor.primary)
                
                Divider().padding(.vertical,16)
            }
            .offset(x:-24)
            
        }
        .offset(x:24)
        .buttonStyle(ActionButtonStyle({
            AppHaptics.light()
        }))

    }
    
    init(_ title: String, _ selection: Binding<T>) {
        self.title = title
        self._selection = selection
    }
}

//MARK: - HELPERS

/// Used for menus to have animations and haptics feedbacks
struct ActionButtonStyle: ButtonStyle {
    var action: () -> Void
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, _ in
                action()
            }
    }
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
}

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

struct PreviewLabel:View {
    let text: String
    var body: some View {
        Text("// \(text)")
            .font(.caption2)
            .fontDesign(.monospaced)
    }
    
    init(_ text: String) {
        self.text = text
    }
}

struct AppButtons_PreviewWrapper: View {
    
    @State private var filterString: String = ""
    @State private var largeString: String = ""
    @State private var notesString: String = ""
    @State private var speciesWater: SpeciesWater = .unknown
    @State private var doubleValue: Double?
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    HStack{
                        CircleLabel(symbol: "chevron.left")
                        CircleButton("circle") {
                            
                        }
                        CapsuleLabel(symbol: "matter.logo", title: "Matter")
                        Spacer()
                        CircleSelector(symbol: "circle", selection: $speciesWater)
                        
                    }
                    
                    Spacer().frame(height: 64)
                    
                    PreviewLabel("Large String Input")
                    LargeStringInput("Name", "Unique Name", $largeString)
                        
                    PreviewLabel("Large Double Input")
                    LargeDoubleInput(title: "Weight", value: $doubleValue, unit: "cm")
                    PreviewLabel("Large String Vertical Input")
                    LargeStringVerticalInput("Notes", "Notes", $notesString, limit: 120)
                        
                    PreviewLabel("Selector Button")
                    SelectorButton("Species", "Carp") {
                        
                    }
                    PreviewLabel("Large Selector")
                    LargeSelector("Water", $speciesWater)
                        
                    
                    

                        
                    
                    SearchBar(filterString: $filterString, prompt: "Search things")
                    
                    HStack{Spacer()}
                }
                .padding(.horizontal)
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
