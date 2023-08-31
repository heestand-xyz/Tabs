//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-10-09.
//

import SwiftUI

extension View {
    
    public func tab(id: UUID, ids: [UUID], gesture: Binding<TabGesture> = .constant(.auto), engine: TabEngine, coordinateSpace: CoordinateSpace, move: @escaping (Int, Int) -> ()) -> some View {
        self
            .tabGesture(id: id, ids: ids, gesture: gesture, engine: engine, coordinateSpace: coordinateSpace, move: move)
            .tabTransform(id: id, engine: engine)
    }
    
    public func tabGesture(id: UUID, ids: [UUID], gesture: Binding<TabGesture> = .constant(.auto), engine: TabEngine, coordinateSpace: CoordinateSpace, move: @escaping (Int, Int) -> ()) -> some View {
        self
            #if os(iOS) || os(visionOS)
            .onLongPressGesture {
                gesture.wrappedValue = .drag
            } onPressingChanged: { change in
                if change {
                    gesture.wrappedValue = .potentialDrag
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        guard gesture.wrappedValue == .potentialDrag
                        else { return }
                        gesture.wrappedValue = .drag
                        engine.onChanged(id: id, ids: ids, value: nil)
                    }
                } else {
                    gesture.wrappedValue = .scroll
                }
            }
            #endif
            .simultaneousGesture(
                DragGesture(coordinateSpace: coordinateSpace)
                    .onChanged { value in
                        #if os(iOS) || os(visionOS)
                        guard gesture.wrappedValue.canDrag
                        else { return }
                        #endif
                        engine.onChanged(id: id, ids: ids, value: value)
                    }
                    .onEnded { _ in
                        engine.onEnded(id: id, ids: ids, move: move)
                        #if os(iOS) || os(visionOS)
                        gesture.wrappedValue = .scroll
                        #endif
                    }
            )
    }
    
    public func tabTransform(id: UUID, engine: TabEngine) -> some View {
        self.offset(x: engine.axis == .horizontal ? engine.offset(id: id) : 0.0,
                    y: engine.axis == .vertical ? engine.offset(id: id) : 0.0)
            .zIndex(engine.id == id ? 1 : 0)
    }
}
