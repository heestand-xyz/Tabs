//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-23.
//

import Foundation
import SwiftUI

public struct TabsStyle {
    
    public let padding: CGFloat
    public let spacing: CGFloat
    public let width: CGFloat?
    public let height: CGFloat
    
    public enum Shape {
        case rectangle
        case roundedRectangle(cornerRadius: CGFloat)
        case unevenRoundedRectangle(cornerRadii: RectangleCornerRadii)
        case capsule
        var shape: AnyShape {
            let shape: any SwiftUI.Shape = switch self {
            case .rectangle:
                Rectangle()
            case .roundedRectangle(let cornerRadius):
                RoundedRectangle(cornerRadius: cornerRadius)
            case .unevenRoundedRectangle(let cornerRadii):
                UnevenRoundedRectangle(cornerRadii: cornerRadii)
            case .capsule:
                Capsule()
            }
            return AnyShape(shape)
        }
    }
    let shape: Shape

    @available(*, deprecated, renamed: "init(padding:spacing:width:height:shape:)")
    public init(
        padding: CGFloat = 0.0,
        spacing: CGFloat = .tabSpacing,
        width: CGFloat? = nil,
        height: CGFloat = CGSize.tabSize.height,
        cornerRadii: RectangleCornerRadii = RectangleCornerRadii()
    ) {
        self.init(
            padding: padding,
            spacing: spacing,
            width: width,
            height: height,
            shape: .unevenRoundedRectangle(cornerRadii: cornerRadii)
        )
    }
    
    public init(
        padding: CGFloat = 0.0,
        spacing: CGFloat = .tabSpacing,
        width: CGFloat? = nil,
        height: CGFloat = CGSize.tabSize.height,
        shape: Shape
    ) {
        self.padding = padding
        self.spacing = spacing
        self.width = width
        self.height = height
        self.shape = shape
    }
}
