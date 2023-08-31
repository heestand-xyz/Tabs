//
//  Created by Anton Heestand on 2022-10-09.
//

import SwiftUI

public class TabEngine: ObservableObject {
    
    let axis: Axis
    
    let staticLength: CGFloat?
    let spacing: CGFloat

    @Published var active: Bool = false
    @Published var id: UUID?
    public var draggingID: UUID? { id }
    @Published var ids: [UUID] = []
    var index: Int? {
        guard let id else { return nil }
        return ids.firstIndex(of: id)
    }
    @Published private var translation: CGFloat = 0.0
    @Published private var shift: Int = 0
    
    @Published public var dynamicLengths: [UUID: CGFloat] = [:]
    
    public init(axis: Axis, length: CGFloat? = nil, spacing: CGFloat = 0.0) {
        self.axis = axis
        self.staticLength = length
        self.spacing = spacing
    }
    
    func length(at index: Int) -> CGFloat? {
        if let staticLength {
            return staticLength
        }
        guard ids.indices.contains(index)
        else { return nil }
        let id: UUID = ids[index]
        return dynamicLengths[id]
    }
    
    func lengths(below index: Int) -> CGFloat? {
        guard index >= 0
        else { return nil }
        var lengths: CGFloat = 0.0
        for i in 0..<index {
            guard let length = length(at: i)
            else { return nil }
            lengths += length
        }
        return lengths
    }
    
    func lengths(above index: Int) -> CGFloat? {
        guard index >= 0
        else { return nil }
        var lengths: CGFloat = 0.0
        for i in 0...index {
            guard let length = length(at: i)
            else { return nil }
            lengths += length
        }
        return lengths
    }
    
    func lengths(centerdAt index: Int) -> CGFloat? {
        guard let lengths = lengths(below: index),
              let length = length(at: index)
        else { return nil }
        return lengths + length / 2
    }
   
    func offset(id: UUID) -> CGFloat {
        
        let index = ids.firstIndex(of: id) ?? 0
        
        guard active,
              let tabIndex = self.index
        else { return 0.0 }
        
        if tabIndex == index {
            
            return translation
            
        } else {
            
            let currentIndex = tabIndex + shift

            guard let length = length(at: tabIndex)
            else { return 0.0 }

            if index < tabIndex && index >= currentIndex {
                return (length + spacing) * CGFloat(min(-shift, 1))
            } else if index > tabIndex && index <= currentIndex {
                return (length + spacing) * CGFloat(max(-shift, -1))
            } else {
                return 0.0
            }
        }
    }
    
    func onChanged(id: UUID, ids: [UUID], value: DragGesture.Value?) {
        
        let index = ids.firstIndex(of: id) ?? 0
        
        if self.index == nil {
            self.active = true
            self.id = id
            self.ids = ids
        }
        
        guard let value else { return }
        
        switch axis {
        case .horizontal:
            translation = value.translation.width
        case .vertical:
            translation = value.translation.height
        }

        guard let indexLength = lengths(centerdAt: index)
        else { return }
        
        let currentLengths: CGFloat = indexLength + translation
        
        var shift: Int = 0
        if translation > 0.0 {
            while lengths(below: index + shift + 1) != nil
                    && currentLengths > lengths(below: index + shift + 1)! {
                shift += 1
            }
        } else {
            while lengths(above: index + shift - 1) != nil
                    && currentLengths < lengths(above: index + shift - 1)! {
                shift -= 1
            }
        }
        if shift != self.shift {
            withAnimation {
                self.shift = shift
            }
        }
    }
    
    func onEnded(id: UUID, ids: [UUID], move: (Int, Int) -> ()) {
        
        let index = ids.firstIndex(of: id) ?? 0
        let count = ids.count
        
        if shift != 0 {
            var newIndex = index + shift
            newIndex = min(max(newIndex, 0), count - 1)
            if newIndex > index {
                newIndex += 1
            }
            move(index, newIndex)
        }
        
        self.id = nil
        self.ids = []
        self.translation = 0.0
        self.shift = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            guard self.index == nil
            else { return }
            self.active = false
        }
    }
}
