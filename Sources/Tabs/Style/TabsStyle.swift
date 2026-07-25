//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-23.
//

import Foundation
import SwiftUI

public struct TabsStyle {
    
    public let padding: EdgeInsets
    public let spacing: CGFloat
    public let width: CGFloat?
    public let height: CGFloat
    public let glass: Bool
    
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
    
    let clip: Bool

    @available(*, deprecated, renamed: "init(padding:spacing:width:height:shape:)")
    public init(
        padding: CGFloat = 0.0,
        spacing: CGFloat = .tabSpacing,
        width: CGFloat? = nil,
        height: CGFloat = CGSize.tabSize.height,
        cornerRadii: RectangleCornerRadii = RectangleCornerRadii(),
        clip: Bool = true
    ) {
        self.init(
            padding: padding,
            spacing: spacing,
            width: width,
            height: height,
            shape: .unevenRoundedRectangle(cornerRadii: cornerRadii),
            clip: clip
        )
    }
    
    public init(
        padding: CGFloat = 0.0,
        spacing: CGFloat = .tabSpacing,
        width: CGFloat? = nil,
        height: CGFloat = CGSize.tabSize.height,
        shape: Shape,
        clip: Bool = true,
        glass: Bool = false
    ) {
        self.padding = EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        self.spacing = spacing
        self.width = width
        self.height = height
        self.shape = shape
        self.clip = clip
        self.glass = glass
    }
    
    public init(
        padding: EdgeInsets,
        spacing: CGFloat = .tabSpacing,
        width: CGFloat? = nil,
        height: CGFloat = CGSize.tabSize.height,
        shape: Shape,
        clip: Bool = true,
        glass: Bool = false
    ) {
        self.padding = padding
        self.spacing = spacing
        self.width = width
        self.height = height
        self.shape = shape
        self.clip = clip
        self.glass = glass
    }
}
