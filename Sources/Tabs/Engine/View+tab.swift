//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-10-09.
//

import SwiftUI

extension View {
    
    public func tab(at index: Int, count: Int, engine: TabEngine, coordinateSpace: CoordinateSpace, move: @escaping (Int, Int) -> ()) -> some View {
        self.tabGesture(at: index, count: count, engine: engine, coordinateSpace: coordinateSpace, move: move)
            .tabTransform(at: index, engine: engine)
    }
    
    public func tabGesture(at index: Int, count: Int, engine: TabEngine, coordinateSpace: CoordinateSpace, move: @escaping (Int, Int) -> ()) -> some View {
        self.simultaneousGesture(
            DragGesture(coordinateSpace: coordinateSpace)
                .onChanged { value in
                    engine.onChanged(index: index, value: value)
                }
                .onEnded { _ in
                    engine.onEnded(index: index, count: count, move: move)
                }
        )
    }
    
    public func tabTransform(at index: Int, engine: TabEngine) -> some View {
        self.offset(x: engine.axis == .horizontal ? engine.offset(at: index) : 0.0,
                    y: engine.axis == .vertical ? engine.offset(at: index) : 0.0)
            .zIndex(engine.index == index ? 1 : 0)
    }
}
