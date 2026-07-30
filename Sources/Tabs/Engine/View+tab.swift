//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-10-09.
//

import SwiftUI

private struct TabLongPressDragEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private extension EnvironmentValues {
    var tabLongPressDragEnabled: Bool {
        get { self[TabLongPressDragEnabledKey.self] }
        set { self[TabLongPressDragEnabledKey.self] = newValue }
    }
}

extension View {

    public func tabLongPressDragEnabled(_ enabled: Bool) -> some View {
        environment(\.tabLongPressDragEnabled, enabled)
    }

    public func tab(id: UUID, ids: [UUID], gesture: Binding<TabGesture> = .constant(.auto), engine: TabEngine, coordinateSpace: CoordinateSpace, move: @escaping (Int, Int) -> ()) -> some View {
        self
            .tabGesture(id: id, ids: ids, gesture: gesture, engine: engine, coordinateSpace: coordinateSpace, move: move)
            .tabTransform(id: id, engine: engine)
    }
    
    public func tabGesture(id: UUID, ids: [UUID], gesture: Binding<TabGesture> = .constant(.auto), engine: TabEngine, coordinateSpace: CoordinateSpace, move: @escaping (Int, Int) -> ()) -> some View {
        modifier(
            TabGestureModifier(
                id: id,
                ids: ids,
                gesture: gesture,
                engine: engine,
                coordinateSpace: coordinateSpace,
                move: move
            )
        )
    }

    public func tabTransform(id: UUID, engine: TabEngine) -> some View {
        self.offset(x: engine.axis == .horizontal ? engine.offset(id: id) : 0.0,
                    y: engine.axis == .vertical ? engine.offset(id: id) : 0.0)
            .zIndex(engine.id == id ? 1 : 0)
    }
}

private struct TabGestureModifier: ViewModifier {

    @Environment(\.tabLongPressDragEnabled) private var longPressDragEnabled

    let id: UUID
    let ids: [UUID]
    @Binding var gesture: TabGesture
    let engine: TabEngine
    let coordinateSpace: CoordinateSpace
    let move: (Int, Int) -> Void

    @State private var sequencedDragIsActive: Bool = false
    @GestureState private var sequencedGestureIsRecognized: Bool = false

    @ViewBuilder
    func body(content: Content) -> some View {
#if os(iOS)
        if longPressDragEnabled {
            if #available(iOS 18.0, *) {
                content
                    .gesture(
                        TabLongPressDragGesture(
                            isEnabled: true,
                            onActivated: activateLongPressDrag,
                            onChanged: updateLongPressDrag(translation:),
                            onEnded: endLongPressDrag
                        )
                    )
            } else {
                sequencedTouchBody(content: content)
            }
        } else {
            legacyTouchBody(content: content)
        }
#elseif os(visionOS)
        if longPressDragEnabled {
            sequencedTouchBody(content: content)
        } else {
            legacyTouchBody(content: content)
        }
#else
        content
            .simultaneousGesture(legacyDragGesture)
#endif
    }

#if os(iOS) || os(visionOS)
    private func legacyTouchBody(content: Content) -> some View {
        content
            .onLongPressGesture {
                gesture = .drag
            } onPressingChanged: { isPressing in
                if isPressing {
                    gesture = .potentialDrag
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        guard gesture == .potentialDrag else { return }
                        gesture = .drag
                        engine.onChanged(id: id, ids: ids, translation: nil)
                    }
                } else {
                    gesture = .scroll
                }
            }
            .simultaneousGesture(legacyDragGesture)
    }

    private func sequencedTouchBody(content: Content) -> some View {
        content
            .simultaneousGesture(sequencedDragGesture)
            .onChange(of: sequencedGestureIsRecognized) { isRecognized in
                guard !isRecognized, sequencedDragIsActive else { return }
                endSequencedDrag()
            }
    }
#endif

    private var legacyDragGesture: some Gesture {
        DragGesture(coordinateSpace: coordinateSpace)
            .onChanged { value in
#if os(iOS) || os(visionOS)
                guard gesture.canDrag else { return }
#endif
                engine.onChanged(id: id, ids: ids, translation: value.translation)
            }
            .onEnded { _ in
                engine.onEnded(id: id, ids: ids, move: move)
#if os(iOS) || os(visionOS)
                gesture = .scroll
#endif
            }
    }

    private var sequencedDragGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(
                before: DragGesture(
                    minimumDistance: 0.0,
                    coordinateSpace: coordinateSpace
                )
            )
            .updating($sequencedGestureIsRecognized) { value, isRecognized, _ in
                switch value {
                case .first(true), .second(true, _):
                    isRecognized = true
                default:
                    break
                }
            }
            .onChanged { value in
                switch value {
                case .first(true):
                    activateSequencedDragIfNeeded()
                case .second(true, let dragValue):
                    activateSequencedDragIfNeeded()
                    guard let dragValue else { return }
                    engine.onChanged(id: id, ids: ids, translation: dragValue.translation)
                default:
                    break
                }
            }
            .onEnded { _ in
                endSequencedDrag()
            }
    }

    private func activateSequencedDragIfNeeded() {
        guard !sequencedDragIsActive else { return }
        sequencedDragIsActive = true
        gesture = .drag
        engine.onChanged(id: id, ids: ids, translation: nil)
    }

    private func endSequencedDrag() {
        guard sequencedDragIsActive else { return }
        engine.onEnded(id: id, ids: ids, move: move)
        sequencedDragIsActive = false
        gesture = .scroll
    }

#if os(iOS)
    private func activateLongPressDrag() {
        gesture = .auto
        engine.onChanged(id: id, ids: ids, translation: nil)
    }

    private func updateLongPressDrag(translation: CGSize) {
        engine.onChanged(id: id, ids: ids, translation: translation)
    }

    private func endLongPressDrag() {
        engine.onEnded(id: id, ids: ids, move: move)
        gesture = .scroll
    }
#endif
}
