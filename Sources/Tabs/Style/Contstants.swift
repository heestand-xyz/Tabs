//
//  Created by Anton Heestand on 2022-09-26.
//

import CoreGraphics

extension CGFloat {
    
    public static let tabSpacing: CGFloat = 2.0
    public static let tabPadding: CGFloat = 8.0
}

extension CGSize {
    
    public static let tabSize = CGSize(width: 150, height: {
        #if os(macOS)
        return 25
        #else
        return 30
        #endif
    }())
}
