//
//  Created by Anton Heestand on 2022-09-25.
//

import SwiftUI

public struct Tabs<Content: View>: View {
    
    let content: (TabValue) -> Content
    
    @Binding var openIDs: [UUID]
    @Binding var activeID: UUID?
    
    let spacing: CGFloat
    let width: CGFloat?
    let height: CGFloat
    
    @StateObject private var tabEngine: TabEngine
    
    @State private var gesture: TabGesture = {
        #if os(iOS)
        return .scroll
        #else
        return .auto
        #endif
    }()
    
    public init(
        openIDs: Binding<[UUID]>,
        activeID: Binding<UUID?>,
        spacing: CGFloat = .tabSpacing,
        width: CGFloat? = nil,
        height: CGFloat = CGSize.tabSize.height,
        @ViewBuilder content: @escaping (TabValue) -> Content
    ) {
        self.content = content
        _openIDs = openIDs
        _activeID = activeID
        self.spacing = spacing
        self.width = width
        self.height = height
        _tabEngine = StateObject(wrappedValue: {
            TabEngine(axis: .horizontal, length: width, spacing: spacing)
        }())
    }
    
    public var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: spacing) {
                
                ForEach(openIDs, id: \.self) { id in
                    
                    let isActive = activeID == id
                        
                    ZStack(alignment: .leading) {
                        
                        Button {
                            if tabEngine.active { return }
                            activeID = id
                        } label: {
                            content(TabValue(id: id, isActive: isActive, width: width, height: height))
                        }
                        .buttonStyle(Tab())
//                        #if os(macOS)
//                        .disabled(isActive)
//                        #endif
                        .tabGesture(id: id, ids: openIDs, gesture: $gesture, engine: tabEngine, coordinateSpace: .named("tabs"), move: move)
                        
                        Button {
                            close(id: id)
                        } label: {
                            ZStack {
                                Color.primary.opacity(0.001)
                                Image(systemName: "xmark")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(1.0, contentMode: .fit)
                            }
                        }
                        .buttonStyle(.plain)
                        .aspectRatio(1.0, contentMode: .fit)
                    }
                    .frame(width: width)
                    .background {
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    guard width == nil else { return }
                                    tabEngine.dynamicLengths[id] = geometry.size.width
                                }
                                .onChange(of: geometry.size) { size in
                                    guard width == nil else { return }
                                    tabEngine.dynamicLengths[id] = size.width
                                }
                                .onDisappear {
                                    guard width == nil else { return }
                                    tabEngine.dynamicLengths.removeValue(forKey: id)
                                }
                        }
                    }
                    .tabTransform(id: id, engine: tabEngine)
                }
            }
        }
        .scrollDisabled(!gesture.canScroll)
        .frame(height: height)
        .coordinateSpace(name: "tabs")
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
