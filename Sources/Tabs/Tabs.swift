//
//  Created by Anton Heestand on 2022-09-25.
//

import SwiftUI

public struct Tabs<Content: View>: View {
    
    let count: Int
    let content: (Int, Bool, CGSize) -> Content
    
    @Binding var activeIndex: Int?
    
    let spacing: CGFloat
    let size: CGSize
    
    let move: (Int, Int) -> ()
    let close: (Int) -> ()
    
    @StateObject private var tabEngine: TabEngine
    
    public init(
        count: Int,
        activeIndex: Binding<Int?>,
        spacing: CGFloat = .tabSpacing,
        size: CGSize = .tabSize,
        @ViewBuilder content: @escaping (Int, Bool, CGSize) -> Content,
        move: @escaping (Int, Int) -> (),
        close: @escaping (Int) -> ()
    ) {
        self.count = count
        self.content = content
        _activeIndex = activeIndex
        self.spacing = spacing
        self.size = size
        self.move = move
        self.close = close
        _tabEngine = StateObject(wrappedValue: {
            TabEngine(axis: .horizontal, length: size.width, spacing: spacing)
        }())
    }
    
    public init(
        openIDs: Binding<[UUID]>,
        activeID: Binding<UUID?>,
        spacing: CGFloat = .tabSpacing,
        size: CGSize = .tabSize,
        @ViewBuilder content: @escaping (UUID, Bool, CGSize) -> Content
    ) {
        self.count = openIDs.wrappedValue.count
        self.content = { index, isActive, size in
            content(openIDs.wrappedValue[index], isActive, size)
        }
        _activeIndex = Binding(get: {
            guard let id = activeID.wrappedValue
            else { return 0 }
            return openIDs.wrappedValue.firstIndex(of: id) ?? 0
        }, set: { index, _ in
            if let index {
                activeID.wrappedValue = openIDs.wrappedValue[index]
            } else {
                activeID.wrappedValue = nil
            }
        })
        self.spacing = spacing
        self.size = size
        self.move = { index, toIndex in
            openIDs.wrappedValue.move(fromOffsets: [index], toOffset: toIndex)
        }
        self.close = { index in
            
            let id: UUID = openIDs.wrappedValue[index]
            
            openIDs.wrappedValue.remove(at: index)
            
            if id == activeID.wrappedValue {
                activeID.wrappedValue = {
                    if openIDs.wrappedValue.indices.contains(index) {
                        return openIDs.wrappedValue[index]
                    } else {
                        return openIDs.wrappedValue.last
                    }
                }()
            }
        }
        _tabEngine = StateObject(wrappedValue: {
            TabEngine(axis: .horizontal, length: size.width, spacing: spacing)
        }())
    }
    
    public var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: spacing) {
                
                ForEach(Array(0..<count).indices, id: \.self) { index in
                    
                    let isActive = activeIndex == index
                        
                    ZStack(alignment: .leading) {
                        
                        Button {
                            if tabEngine.active { return }
                            activeIndex = index
                        } label: {
                            content(index, isActive, size)
                        }
                        .buttonStyle(Tab())
                        .disabled(isActive)
                        .tabGesture(at: index, count: count, engine: tabEngine, coordinateSpace: .named("tabs"), move: move)
                        
                        Button {
                            close(index)
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
                    .frame(width: size.width)
                    .tabTransform(at: index, engine: tabEngine)
                }
            }
        }
        .frame(height: size.height)
        .coordinateSpace(name: "tabs")
    }
}

struct Tabs_Previews: PreviewProvider {
    static var previews: some View {
        Tabs(count: 3, activeIndex: .constant(0)) { index, isActive, _ in
            ZStack {
                isActive ? Color.accentColor : Color.primary.opacity(0.1)
                Text("Tab \(index + 1)")
            }
        } move: { _, _ in
        } close: { _ in
        }
        .previewLayout(.fixed(width: 700, height: 30))
    }
}
