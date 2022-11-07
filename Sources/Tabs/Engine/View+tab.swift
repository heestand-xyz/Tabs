//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-10-09.
//

import SwiftUI

extension View {
    
    public func tab(at index: Int, count: Int, gesture: Binding<TabGesture> = .constant(.auto), engine: TabEngine, coordinateSpace: CoordinateSpace, move: @escaping (Int, Int) -> ()) -> some View {
        self
            .tabGesture(at: index, count: count, gesture: gesture, engine: engine, coordinateSpace: coordinateSpace, move: move)
            .tabTransform(at: index, engine: engine)
    }
    
    public func tabGesture(at index: Int, count: Int, gesture: Binding<TabGesture> = .constant(.auto), engine: TabEngine, coordinateSpace: CoordinateSpace, move: @escaping (Int, Int) -> ()) -> some View {
        self
            #if os(iOS)
            .onLongPressGesture {
                print("------------->>>")
                gesture.wrappedValue = .drag
            } onPressingChanged: { change in
                print("------------->", "change:", change)
                if change {
                    gesture.wrappedValue = .potentialDrag
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        print("-------------)))", "gesture:", gesture.wrappedValue)
                        guard gesture.wrappedValue == .potentialDrag
                        else { return }
                        gesture.wrappedValue = .drag
                    }
                } else {
                    gesture.wrappedValue = .scroll
                }
            }
            #endif
            .simultaneousGesture(
                DragGesture(coordinateSpace: coordinateSpace)
                    .onChanged { value in
                        #if os(iOS)
                        guard gesture.wrappedValue.canDrag
                        else { return }
                        #endif
                        engine.onChanged(index: index, value: value)
                    }
                    .onEnded { _ in
                        engine.onEnded(index: index, count: count, move: move)
                        #if os(iOS)
                        print("-------------<<<")
                        gesture.wrappedValue = .scroll
                        #endif
                    }
            )
    }
    
    public func tabTransform(at index: Int, engine: TabEngine) -> some View {
        self.offset(x: engine.axis == .horizontal ? engine.offset(at: index) : 0.0,
                    y: engine.axis == .vertical ? engine.offset(at: index) : 0.0)
            .zIndex(engine.index == index ? 1 : 0)
    }
}
