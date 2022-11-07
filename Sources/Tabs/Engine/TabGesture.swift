
public enum TabGesture {
    case auto
    case scroll
    case potentialDrag
    case drag
}

extension TabGesture {
    var canDrag: Bool {
        [.auto, .drag].contains(self)
    }
}

extension TabGesture {
    var canScroll: Bool {
        [.auto, .scroll, .potentialDrag].contains(self)
    }
}
