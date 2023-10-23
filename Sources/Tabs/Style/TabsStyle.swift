//
//  File.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-10-23.
//

import Foundation

public struct TabsStyle {
    
    let padding: CGFloat
    let spacing: CGFloat
    let width: CGFloat?
    let height: CGFloat

    public init(padding: CGFloat = 0.0,
                spacing: CGFloat = .tabSpacing,
                width: CGFloat? = nil,
                height: CGFloat = CGSize.tabSize.height) {
        self.padding = padding
        self.spacing = spacing
        self.width = width
        self.height = height
    }
}
