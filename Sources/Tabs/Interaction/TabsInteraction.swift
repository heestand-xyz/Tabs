//
//  TabsInteraction.swift
//  Tabs
//
//  Created by Anton Heestand on 2025-08-19.
//

public struct TabsInteraction {
    public enum DragActivation {
        case onBegin
        case onEnd
    }
    public var dragActivation: DragActivation?
    public init(dragActivation: DragActivation?) {
        self.dragActivation = dragActivation
    }
    /// `dragActivation` is `nil` by default.
    public static let `default`: TabsInteraction = .init(dragActivation: nil)
}
