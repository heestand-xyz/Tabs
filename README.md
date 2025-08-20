# Tabs

Tabs built in SwiftUI for iOS and macOS.

<img height=50 src="https://github.com/heestand-xyz/Tabs/blob/main/Assets/Tabs.gif?raw=true"/>

Move and close tabs in UI. Open tabs via binding. Style in a content closure.

## Swift Package

```swift
.package(url: "https://github.com/heestand-xyz/Tabs", from: "1.4.0")
```

## Setup

```swift
import SwiftUI
import Tabs

struct MyTab: Identifiable {
    let id: UUID
    let name: String
}

struct ContentView: View {
    
    private static let myTabsStyle = TabsStyle(
        padding: 4.0,
        spacing: .tabSpacing,
        width: nil,
        height: .tabHeight,
        shape: .capsule
    )
    
    private static let myTabsInteraction = TabsInteraction(
        dragActivation: .onEnd
    )
    
    @State private var myTabs: [MyTab] = [
        MyTab(id: UUID(), name: "First"),
        MyTab(id: UUID(), name: "Second"),
        MyTab(id: UUID(), name: "Third"),
    ]
    
    private var myTabIDs: Binding<[UUID]> {
        Binding {
            myTabs.map(\.id)
        } set: { newIDs in
            myTabs = newIDs.compactMap { id in
                myTabs.first { myTab in
                    myTab.id == id
                }
            }
        }
    }
    
    @State private var myActiveTabID: UUID?
    
    var body: some View {
        Tabs(
            style: Self.myTabsStyle,
            interaction: Self.myTabsInteraction,
            openIDs: myTabIDs,
            activeID: $myActiveTabID,
            showClose: true
        ) { tabValue in
            if let myTab = myTabs.first(where: { $0.id == tabValue.id }) {
                MyTabView(myTab: myTab, tabValue: tabValue)
            }
        } xmark: { tabValue in
            Image(systemName: "xmark")
                .imageScale(.small)
                .padding(4.0)
                .foregroundStyle(tabValue.isActive ? .white : .primary)
        }
        .padding(.vertical, .tabSpacing)
        .clipShape(.capsule)
        .background {
            Capsule()
                .opacity(0.1)
        }
        .onAppear {
            myActiveTabID = myTabs.first?.id
        }
    }
}

struct MyTabView: View {
    
    let myTab: MyTab
    let tabValue: TabValue
    
    var body: some View {
        ZStack {
            background
            foreground
                .padding(.horizontal, 24.0)
                .padding(.vertical, 2.0)
        }
    }
    
    private var background: some View {
        if tabValue.isActive {
            Color.accentColor
        } else  {
            Color.primary
                .opacity(0.1)
        }
    }
    
    private var foreground: some View {
        Text(myTab.name)
            .foregroundStyle(tabValue.isActive ? .white : .primary)
    }
}

#Preview {
    ContentView()
        .padding()
}

```

## Tabs

```swift
Tabs(
    style: TabsStyle = TabsStyle(shape: .rectangle),
    interaction: TabsInteraction = TabsInteraction(dragActivation: nil),
    enabledIDs: [UUID]? = nil,
    openIDs: Binding<[UUID]>,
    activeID: Binding<UUID?>,
    showClose: Bool = true,
    closeConfirmation: ((UUID) async -> Bool)? = nil,
    @ViewBuilder content: @escaping (TabValue) -> Content,
    @ViewBuilder xmark: @escaping (TabValue) -> Xmark = { _ in EmptyView() }
)
```

## Tabs Style

```swift
TabsStyle(
    padding: CGFloat = 0.0,
    spacing: CGFloat = .tabSpacing,
    width: CGFloat? = nil,
    height: CGFloat = CGSize.tabSize.height,
    shape: Shape
)
```

## Tabs Interaction

```swift
TabsInteraction(
    dragActivation: DragActivation? = nil
)
```
