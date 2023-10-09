//
//  Created by Anton Heestand on 2022-09-26.
//

import SwiftUI

struct Tab: ButtonStyle {
    
    let isFirst: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 2.0 / 3.0 : 1.0)
    }
}
