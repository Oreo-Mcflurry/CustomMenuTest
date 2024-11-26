//
//  ContentView.swift
//  CustomMenu
//
//  Created by A_Mcflurry on 11/26/24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func dropdownOverlay<T: Selectable>(_ config: Binding<DropdownConfig<T>>, values: [T]) -> some View {
        self
            .overlay {
                if config.wrappedValue.show {
                    DropdownView(values: values, config: config)
                        .transition(.identity)
                }
            }
    }
    
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

struct DropdownConfig<T: Selectable> {
    var active: T
    var show: Bool = false
    var showContent: Bool = false
    var anchor: CGRect = .zero
    var cornerRadius: CGFloat = 12
}

struct DropdownView<T: Selectable>: View {
    var values: [T]
    @Binding var config: DropdownConfig<T>
    var body: some View {
        VStack(spacing: 0) {
            ForEach(values, id: \.self) { item in
                HStack {
                    Text(item.title)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "chevron.down")
                    
                }
                .padding(.horizontal, 15)
                .frame(height: config.anchor.height)
                .contentShape(.rect)
                .onTapGesture {
                    config.active = item
                    withAnimation(.snappy(duration: 0.2)) {
                        config.showContent = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            config.show = false
                        }
                    }
                }
            }
        }
        .frame(width: config.anchor.width)
        .background(.gray)
        .mask(alignment: .top) {
            Rectangle()
                .frame(height: config.showContent ? nil : 0, alignment: .top)
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
                            .frame(height: config.showContent ? nil : 0, alignment: .top)
                            .offset(x: config.anchor.minX, y: config.anchor.minY)
                        
                    }.transition(.opacity)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.2)) {
                            config.showContent = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                config.show = false
                            }
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
}

struct SourceDropdownView<T: Selectable>: View {
    @Binding var config: DropdownConfig<T>
    var body: some View {
        HStack {
            Text(config.active.title)
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.down")
            
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(.background, in: .rect(cornerRadius: config.cornerRadius))
        .contentShape(.rect(cornerRadius: config.cornerRadius))
        .onTapGesture {
            config.show = true
            withAnimation(.snappy(duration: 0.2)) {
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

struct ContentView: View {
    @State var config = DropdownConfig(active: ClubKickPoint.mid)
    var body: some View {
        ScrollView {
            SourceDropdownView(config: $config)
        }
        .dropdownOverlay($config, values: ClubKickPoint.allCases)
    }
}

enum ClubKickPoint: String, CaseIterable {
    case low = "Low"
    case mid = "Mid"
    case high = "High"
}

extension ClubKickPoint: Selectable {
    var allCase: [ClubKickPoint] {
        return ClubKickPoint.allCases
    }
    
    var title: String {
        return self.rawValue
    }
    
}

protocol Selectable: Hashable {
    var allCase: [Self] { get }
    var title: String { get }
}
