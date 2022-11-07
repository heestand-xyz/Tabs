# Tabs

Tabs built in SwiftUI for iOS and macOS.

![](https://github.com/heestand-xyz/Tabs/blob/main/Assets/Tabs.png?raw=true)

Move and close tabs in UI. Open tabs via binding. Style via content callback.

## Swift Package

```swift
.package(url: "https://github.com/heestand-xyz/Tabs", from: "1.0.0")
```

## Setup

```swift
var body: some View {
   
    Tabs(openIDs: $openIDs,
         activeID: $activeID) { value in
        
        if let thing = things.first(where: { $0.id == value.id }) {
        
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
                .padding(.horizontal, value.height)
            }
            .help(thing.name)
        }
    }
}
```

## Constructor

```swift
public init(
    openIDs: Binding<[UUID]>,
    activeID: Binding<UUID?>,
    spacing: CGFloat = .tabSpacing,
    width: CGFloat? = nil,
    height: CGFloat = CGSize.tabSize.height,
    @ViewBuilder content: @escaping (Tabs.Value) -> Content
) { ... }
```
