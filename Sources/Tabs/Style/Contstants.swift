//
//  Created by Anton Heestand on 2022-09-26.
//

import CoreGraphics

extension CGFloat {
    
    /// Default at 2
    public static let tabSpacing: CGFloat = 2.0
    /// Default at 25 on macOS and 30 on iOS
    public static var tabHeight: CGFloat {
        CGSize.tabSize.height
    }
}

extension CGSize {
    
    /// Default width at 150 and height at 25 on macOS and 30 on iOS
    public static let tabSize = CGSize(width: 150, height: {
        #if os(macOS)
        return 25
        #else
        return 30
        #endif
    }())
}
