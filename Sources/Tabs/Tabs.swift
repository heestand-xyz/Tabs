//
//  Created by Anton Heestand on 2022-09-25.
//

import SwiftUI

public struct Tabs<Content: View>: View {
    
    public struct Value {
        public let id: UUID
        public let isActive: Bool
        public let width: CGFloat?
        public let height: CGFloat
    }
    
    let content: (Value) -> Content
    
    @Binding var openIDs: [UUID]
    @Binding var activeID: UUID?
    
    let spacing: CGFloat
    let width: CGFloat?
    let height: CGFloat
    
    @StateObject private var tabEngine: TabEngine
    
    public init(
        openIDs: Binding<[UUID]>,
        activeID: Binding<UUID?>,
        spacing: CGFloat = .tabSpacing,
        width: CGFloat? = nil,
        height: CGFloat = CGSize.tabSize.height,
        @ViewBuilder content: @escaping (Value) -> Content
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
                    
                    let index = openIDs.firstIndex(of: id) ?? 0
                    let isActive = activeID == id
                        
                    ZStack(alignment: .leading) {
                        
                        Button {
                            if tabEngine.active { return }
                            activeID = id
                        } label: {
                            content(Value(id: id, isActive: isActive, width: width, height: height))
                        }
                        .buttonStyle(Tab())
                        .disabled(isActive)
                        .tabGesture(at: index, count: openIDs.count, engine: tabEngine, coordinateSpace: .named("tabs"), move: move)
                        
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
                                    tabEngine.dynamicLengths[index] = geometry.size.width
                                }
                                .onChange(of: geometry.size) { size in
                                    guard width == nil else { return }
                                    tabEngine.dynamicLengths[index] = size.width
                                }
                                .onDisappear {
                                    guard width == nil else { return }
                                    tabEngine.dynamicLengths.removeValue(forKey: index)
                                }
                        }
                    }
                    .tabTransform(at: index, engine: tabEngine)
                }
            }
        }
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
