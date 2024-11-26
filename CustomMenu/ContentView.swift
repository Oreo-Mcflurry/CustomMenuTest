//
//  ContentView.swift
//  CustomMenu
//
//  Created by A_Mcflurry on 11/26/24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func dropdownOverlay(_ config: Binding<DropdownConfig>, values: [String]) -> some View {
        self
            .overlay {
                if config.wrappedValue.show {
                    DropdownView(values: values, config: config)
                        .transition(.identity)
                }
            }
    }
}

struct DropdownView: View {
    var values: [String]
    @Binding var config: DropdownConfig
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(values, id: \.self) { item in
                    HStack {
                        Text(item)
                        
                        Spacer(minLength: 0)
                        
                        Image(systemName: "chevron.down")
                            
                    }
                    .padding(.horizontal, 15)
                    .frame(height: config.anchor.height)
                    .contentShape(.rect)
                    .onTapGesture {
                        config.activeText = item
                        withAnimation(.snappy(duration: 0.3)) {
                            config.showContent = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                config.show = false
                            }
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(width: config.anchor.width, height: 200)
        .background(.gray)
        .mask(alignment: .top) {
            Rectangle()
                .frame(height: config.showContent ? 200 : 0, alignment: .top)
        }
        .clipShape(.rect(cornerRadius: config.cornerRadius))
        .offset(x: config.anchor.minX, y: config.anchor.minY + 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            if config.showContent {
                Rectangle()
                    .fill(.clear)
                    .contentShape(.rect)
                    .reverseMask(.topLeading) {
                        RoundedRectangle(cornerRadius: config.cornerRadius)
                            .frame(height: config.showContent ? 200 : 0, alignment: .top)
                            .offset(x: config.anchor.minX, y: config.anchor.minY)
                        
                    }.transition(.opacity)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.3)) {
                            config.showContent = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                config.show = false
                            }
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
}

extension View {
    @ViewBuilder
    func reverseMask<Content: View>(_ algignment: Alignment, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .mask {
                Rectangle()
                    .overlay(alignment: algignment) {
                        content()
                    }
            }
    }
        
}

struct SourceDropdownView: View {
    @Binding var config: DropdownConfig
    var body: some View {
        HStack {
            Text(config.activeText)
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.down")
                
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(.background, in: .rect(cornerRadius: config.cornerRadius))
        .contentShape(.rect(cornerRadius: config.cornerRadius))
        .onTapGesture {
            config.show = true
            withAnimation(.snappy) {
                config.showContent = true
            }
        }
        .onGeometryChange(for: CGRect.self) {
            $0.frame(in: .global)
        } action: { newValue in
            config.anchor = newValue
        }

    }
}

struct DropdownConfig {
    var activeText: String
    var show: Bool = false
    var showContent: Bool = false
    var anchor: CGRect = .zero
    var cornerRadius: CGFloat = 12
}

struct ContentView: View {
    var values: [String] = ["Messages", "Archived", "Trash"]
    @State var config = DropdownConfig(activeText: "Messages")
    @State var config2 = DropdownConfig(activeText: "Messages")
    var body: some View {
        ScrollView {
            SourceDropdownView(config: $config)
            SourceDropdownView(config: $config2)
        }
        .dropdownOverlay($config, values: values)
        .dropdownOverlay($config2, values: values)
    }
}


#Preview {
    ContentView()
}
