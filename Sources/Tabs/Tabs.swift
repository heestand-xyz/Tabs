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
    }
    
    @State private var dragActive: Bool = false
    @State private var dragIndex: Int?
    @State private var dragTranslation: CGFloat = 0.0
    @State private var dragShift: Int = 0
    
    public var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 2.0) {
                
                ForEach(Array(0..<count).indices, id: \.self) { index in
                    
                    let isActive = activeIndex == index
                        
                    ZStack(alignment: .leading) {
                        
                        Button {
                            if dragActive { return }
                            activeIndex = index
                        } label: {
                            content(index, isActive, size)
                        }
                        .buttonStyle(Tab())
                        .disabled(isActive)
                        .simultaneousGesture(
                            DragGesture(coordinateSpace: .named("tabs"))
                                .onChanged { value in
                                    
                                    if dragIndex == nil {
                                        dragActive = true
                                        dragIndex = index
                                    }
                                    
                                    dragTranslation = value.translation.width
                                    
                                    let shift = Int(dragTranslation / (size.width + spacing) + (dragTranslation > 0.0 ? 0.5 : -0.5))
                                    if shift != dragShift {
                                        withAnimation {
                                            dragShift = shift
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    
                                    if dragShift != 0 {
                                        var newIndex = index + dragShift
                                        newIndex = min(max(newIndex, 0), count - 1)
                                        if newIndex > index {
                                            newIndex += 1
                                        }
                                        move(index, newIndex)
                                    }
                                    
                                    dragIndex = nil
                                    dragTranslation = 0.0
                                    dragShift = 0
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
                                        guard dragIndex == nil
                                        else { return }
                                        dragActive = false
                                    }
                                }
                        )
                        
                        Button {
                            close(index)
                        } label: {
                            Image(systemName: "xmark")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: size.width)
                    .offset(x: dragIndex == index ? dragTranslation : 0.0)
                    .offset(x: {
                       
                        guard dragActive,
                              let dragIndex,
                              dragIndex != index
                        else { return 0.0 }
                        
                        let width: CGFloat = size.width + spacing
                        
                        let currentIndex = dragIndex + dragShift
                        
                        if index < dragIndex && index >= currentIndex {
                            return width * CGFloat(min(-dragShift, 1))
                        } else if index > dragIndex && index <= currentIndex {
                            return width * CGFloat(max(-dragShift, -1))
                        }
                        
                        return 0.0
                    }())
                    .zIndex(dragIndex == index ? 1 : 0)
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
