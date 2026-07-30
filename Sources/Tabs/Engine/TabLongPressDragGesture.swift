//
//  TabLongPressDragGesture.swift
//  Tabs
//

#if os(iOS)
import SwiftUI
import UIKit

@available(iOS 18.0, *)
struct TabLongPressDragGesture: UIGestureRecognizerRepresentable {

    let isEnabled: Bool
    let onActivated: () -> Void
    let onChanged: (CGSize) -> Void
    let onEnded: () -> Void

    final class Coordinator {
        var startLocation: CGPoint?

        func reset() {
            startLocation = nil
        }
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0.5
        recognizer.allowableMovement = 10.0
        recognizer.cancelsTouchesInView = false
        recognizer.isEnabled = isEnabled
        return recognizer
    }

    func updateUIGestureRecognizer(
        _ recognizer: UILongPressGestureRecognizer,
        context: Context
    ) {
        recognizer.isEnabled = isEnabled
    }

    func handleUIGestureRecognizerAction(
        _ recognizer: UILongPressGestureRecognizer,
        context: Context
    ) {
        let coordinator = context.coordinator
        let location = recognizer.location(in: nil)

        switch recognizer.state {
        case .began:
            coordinator.startLocation = location
            onActivated()
        case .changed:
            guard let startLocation = coordinator.startLocation else { return }
            onChanged(
                CGSize(
                    width: location.x - startLocation.x,
                    height: location.y - startLocation.y
                )
            )
        case .ended:
            guard let startLocation = coordinator.startLocation else { return }
            onChanged(
                CGSize(
                    width: location.x - startLocation.x,
                    height: location.y - startLocation.y
                )
            )
            coordinator.reset()
            onEnded()
        case .cancelled:
            guard coordinator.startLocation != nil else { return }
            coordinator.reset()
            onEnded()
        case .failed:
            coordinator.reset()
        default:
            break
        }
    }
}
#endif
