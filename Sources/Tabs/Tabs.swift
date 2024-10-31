//
//  Created by Anton Heestand on 2022-09-25.
//

import SwiftUI

public struct Tabs<Content: View, Xmark: View>: View {
    
    let style: TabsStyle
    
    let content: (TabValue) -> Content
    let xmark: (TabValue) -> Xmark
    
    let enabledIDs: [UUID]
    @Binding var openIDs: [UUID]
    @Binding var activeID: UUID?

    let showClose: Bool
    let closeConfirmation: (UUID) async -> Bool
        
    @StateObject private var tabEngine: TabEngine
    
    @State private var gesture: TabGesture = {
        #if os(iOS) || os(visionOS)
        return .scroll
        #else
        return .auto
        #endif
    }()
    
    @FocusState var focusedID: UUID?
    
    public init(
        style: TabsStyle = TabsStyle(shape: .rectangle),
        enabledIDs: [UUID]? = nil,
        openIDs: Binding<[UUID]>,
        activeID: Binding<UUID?>,
        showClose: Bool = true,
        closeConfirmation: @escaping (UUID) async -> Bool = { _ in true },
        @ViewBuilder content: @escaping (TabValue) -> Content,
        @ViewBuilder xmark: @escaping (TabValue) -> Xmark = { _ in EmptyView() }
    ) {
        self.style = style
        self.content = content
        self.xmark = xmark
        self.enabledIDs = enabledIDs ?? openIDs.wrappedValue
        _openIDs = openIDs
        _activeID = activeID
        self.showClose = showClose
        self.closeConfirmation = closeConfirmation
        _tabEngine = StateObject(wrappedValue: {
            TabEngine(axis: .horizontal, 
                      length: style.width, 
                      spacing: style.spacing,
                      padding: style.padding)
        }())
    }
    
    public var body: some View {
        
        ScrollViewReader { proxy in
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: style.spacing) {
                    
                    ForEach(openIDs, id: \.self) { id in
                        
                        let index: Int = openIDs.firstIndex(of: id) ?? 0
                        let isFirst: Bool = openIDs.first == id
                        let isActive: Bool = activeID == id
                        let isMoving: Bool = tabEngine.id == id
                        
                        let tabValue = TabValue(
                            id: id,
                            index: index,
                            isActive: isActive,
                            isMoving: isMoving,
                            width: style.width,
                            height: style.height)
                        
                        ZStack(alignment: .leading) {
                            
                            if enabledIDs.contains(id) {
                                Button {
                                    if tabEngine.active { return }
                                    activeID = id
                                } label: {
                                    content(tabValue)
                                        .clipShape(style.shape.shape)
                                        .contentShape(style.shape.shape)
                                        .padding(.vertical, style.padding)
                                }
                                .focused($focusedID, equals: id)
                                .buttonStyle(Tab(isFirst: isFirst))
                                .tabGesture(id: id, ids: openIDs, gesture: $gesture, engine: tabEngine, coordinateSpace: .named("tabs"), move: move)
                            } else {
                                content(tabValue)
                                    .clipShape(style.shape.shape)
                                    .contentShape(style.shape.shape)
                                    .padding(.vertical, style.padding)
                            }
                            
                            if showClose {
                                
                                Button {
                                    Task {
                                        guard await closeConfirmation(id) else { return }
                                        await MainActor.run {
                                            close(id: id)
                                        }
                                    }
                                } label: {
                                    xmark(tabValue)
                                }
                                .buttonStyle(.plain)
                                .aspectRatio(1.0, contentMode: .fit)
                            }
                        }
                        .frame(width: style.width)
                        .background {
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        guard style.width == nil else { return }
                                        tabEngine.dynamicLengths[id] = geometry.size.width
                                    }
                                    .onChange(of: geometry.size) { size in
                                        guard style.width == nil else { return }
                                        tabEngine.dynamicLengths[id] = size.width
                                    }
                                    .onDisappear {
                                        guard style.width == nil else { return }
                                        tabEngine.dynamicLengths.removeValue(forKey: id)
                                    }
                            }
                        }
                        .tabTransform(id: id, engine: tabEngine)
                        .id("tab-\(id.uuidString)")
                    }
                }
                .padding(.horizontal, style.padding)
            }
            .scrollDisabled(!gesture.canScroll)
            .onAppear {
                guard gesture.canScroll else { return }
                guard let id: UUID = activeID else { return }
                proxy.scrollTo("tab-\(id.uuidString)")
            }
            .onChange(of: openIDs) { newOpenIDs in
                guard newOpenIDs.count > openIDs.count else { return }
                guard gesture.canScroll else { return }
                guard let id: UUID = activeID else { return }
                proxy.scrollTo("tab-\(id.uuidString)")
            }
//            .onChange(of: activeID) { newID in
//                guard gesture.canScroll else { return }
//                guard let id: UUID = newID else { return }
//                proxy.scrollTo("tab-\(id.uuidString)")
//            }
        }
        .frame(height: style.height)
        .coordinateSpace(name: "tabs")
        .onAppear {
            focusedID = activeID
        }
        .onChange(of: activeID) { newActiveID in
            focusedID = newActiveID
        }
    }
    
    private func move(from index: Int, to toIndex: Int) {
        openIDs.move(fromOffsets: [index], toOffset: toIndex)
    }
    
    private func close(id: UUID) {
        
        let index = openIDs.firstIndex(of: id) ?? 0
        
        openIDs.removeAll(where: { $0 == id })
        
        if id == activeID {
            activeID = {
                if openIDs.indices.contains(index) {
                    return openIDs[index]
                } else {
                    return openIDs.last
                }
            }()
        }
    }
}
