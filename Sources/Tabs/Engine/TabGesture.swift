
public enum TabGesture {
    case auto
    case scroll
    case potentialDrag
    case drag
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
