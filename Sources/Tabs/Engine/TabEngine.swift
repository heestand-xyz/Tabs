//
//  Created by Anton Heestand on 2022-10-09.
//

import SwiftUI

public class TabEngine: ObservableObject {
    
    let axis: Axis
    
    let length: CGFloat
    let spacing: CGFloat

    @Published var active: Bool = false
    @Published var index: Int?
    @Published private var translation: CGFloat = 0.0
    @Published private var shift: Int = 0
    
    public init(axis: Axis, length: CGFloat, spacing: CGFloat = 0.0) {
        self.axis = axis
        self.length = length
        self.spacing = spacing
    }
   
    func offset(at index: Int) -> CGFloat {
        
        guard active
        else { return 0.0 }
        
        if self.index == index {
            
            return translation
            
        } else {
            
            guard let tabIndex = self.index
            else { return 0.0 }
            
            let currentIndex = tabIndex + shift
            
            if index < tabIndex && index >= currentIndex {
                return (length + spacing) * CGFloat(min(-shift, 1))
            } else if index > tabIndex && index <= currentIndex {
                return (length + spacing) * CGFloat(max(-shift, -1))
            } else {
                return 0.0
            }
        }
    }
    
    func onChanged(index: Int, value: DragGesture.Value) {
       
        if self.index == nil {
            self.active = true
            self.index = index
        }
        
        switch axis {
        case .horizontal:
            translation = value.translation.width
        case .vertical:
            translation = value.translation.height
        }
        
        let shift = Int(translation / (length + spacing) + (translation > 0.0 ? 0.5 : -0.5))
        if shift != self.shift {
            withAnimation {
                self.shift = shift
            }
        }
    }
    
    func onEnded(index: Int, count: Int, move: (Int, Int) -> ()) {
        
        if shift != 0 {
            var newIndex = index + shift
            newIndex = min(max(newIndex, 0), count - 1)
            if newIndex > index {
                newIndex += 1
            }
            move(index, newIndex)
        }
        
        self.index = nil
        self.translation = 0.0
        self.shift = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            guard self.index == nil
            else { return }
            self.active = false
        }
    }
}
