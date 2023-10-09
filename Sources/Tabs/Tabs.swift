//
//  Created by Anton Heestand on 2022-09-25.
//

import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
public struct Tabs<Content: View, Xmark: View>: View {
    
    let content: (TabValue) -> Content
    let xmark: (TabValue) -> Xmark
    
    @Binding var openIDs: [UUID]
    @Binding var activeID: UUID?

    let showClose: Bool
    let closeConfirmation: (UUID) async -> Bool
    
    let spacing: CGFloat
    let width: CGFloat?
    let height: CGFloat
        
    @StateObject private var tabEngine: TabEngine
    
    @State private var gesture: TabGesture = {
        #if os(iOS) || os(visionOS)
        return .scroll
        #else
        return .auto
        #endif
    }()
    
    public init(
        openIDs: Binding<[UUID]>,
        activeID: Binding<UUID?>,
        showClose: Bool = true,
        closeConfirmation: @escaping (UUID) async -> Bool = { _ in true },
        spacing: CGFloat = .tabSpacing,
        width: CGFloat? = nil,
        height: CGFloat = CGSize.tabSize.height,
        xmarkColor: Color = .primary,
        @ViewBuilder content: @escaping (TabValue) -> Content,
        @ViewBuilder xmark: @escaping (TabValue) -> Xmark
    ) {
        self.content = content
        self.xmark = xmark
        _openIDs = openIDs
        _activeID = activeID
        self.showClose = showClose
        self.closeConfirmation = closeConfirmation
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
                    
                    let isFirst: Bool = openIDs.first == id
                    let isActive: Bool = activeID == id
                    let isMoving: Bool = tabEngine.id == id
                    
                    let tabValue = TabValue(
                        id: id, 
                        isActive: isActive,
                        isMoving: isMoving,
                        width: width,
                        height: height)
                        
                    ZStack(alignment: .leading) {
                        
                        Button {
                            if tabEngine.active { return }
                            activeID = id
                        } label: {
                            content(tabValue)
                        }
                        .buttonStyle(Tab(isFirst: isFirst))
                        .tabGesture(id: id, ids: openIDs, gesture: $gesture, engine: tabEngine, coordinateSpace: .named("tabs"), move: move)
                        
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
