//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import App
import Vapor

let config = try Config()
try config.setUp()

let droplet = try Droplet(config)
try droplet.setUp()

try droplet.run()
