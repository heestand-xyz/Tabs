# Tabs

Tabs built in SwiftUI for iOS and macOS.

![](https://github.com/heestand-xyz/Tabs/blob/main/Assets/Tabs.png?raw=true)

Move and close tabs in UI. Open tabs via binding. Style via closure.

## Swift Package

```swift
.package(url: "https://github.com/heestand-xyz/Tabs", from: "1.0.0")
```

## Setup

```swift
var body: some View {
   
    Tabs(openIDs: $openIDs,
         activeID: $activeID) { id, isActive, size in
        
        if let thing = things.first(where: { $0.id == id }) {
        
            ZStack {
                
                if isActive {
                    Color.accentColor.opacity(0.75)
                } else {
                    Color.primary.opacity(0.1)
                }
                
                Label {
                    Text(thing.name)
                } icon: {
                    Image(systemName: "circle")
                }
                .padding(.horizontal, size.height)
            }
            .help(thing.name)
        }
    }
}
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
