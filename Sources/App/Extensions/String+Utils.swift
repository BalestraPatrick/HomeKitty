//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor

extension String {

    var normalizedPrice: String {
        guard self.hasPrefix("$") == false else { return self }
        return "$\(self)"
    }
    
}
