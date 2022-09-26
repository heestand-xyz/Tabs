# Tabs

Tabs built in SwiftUI for iOS and macOS.

Move and close tabs in UI. Open tabs via binding. Style via closure.

## Swift Package

```swift
.package(url: "https://github.com/heestand-xyz/Tabs", from: "1.0.0")
```

## Constructors

```swift
public init(
    openIDs: Binding<[UUID]>,
    activeID: Binding<UUID?>,
    spacing: CGFloat = .tabSpacing,
    size: CGSize = .tabSize,
    @ViewBuilder content: @escaping (UUID, Bool, CGSize) -> Content
) { ... }
```

```swift
public init(
    count: Int,
    activeIndex: Binding<Int?>,
    spacing: CGFloat = .tabSpacing,
    size: CGSize = .tabSize,
    @ViewBuilder content: @escaping (Int, Bool, CGSize) -> Content,
    move: @escaping (Int, Int) -> (),
    close: @escaping (Int) -> ()
) { ... }
```
