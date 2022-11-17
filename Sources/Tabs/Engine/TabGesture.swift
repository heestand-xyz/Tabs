
public enum TabGesture {
    case auto
    case scroll
    case potentialDrag
    case drag
}

extension TabGesture {
    public static var `default`: TabGesture {
        #if os(iOS)
        return .scroll
        #else
        return .auto
        #endif
    }
}

extension TabGesture {
    public var canDrag: Bool {
        [.auto, .drag].contains(self)
    }
}

extension TabGesture {
    public var canScroll: Bool {
        [.auto, .scroll, .potentialDrag].contains(self)
    }
}
