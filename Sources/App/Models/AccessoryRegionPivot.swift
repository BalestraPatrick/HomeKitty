//
//  Copyright © 2018 HomeKitty. All rights reserved.
//

import FluentPostgreSQL

final class AccessoryRegionPivot: PostgreSQLPivot, PostgreSQLMigration {
    typealias Left = Accessory
    typealias Right = Region

    static var entity = "accessory_region"

    var id: Int?
    var accessoryId: Int
    var regionId: Int

    init() {
        self.accessoryId = 0
        self.regionId = 0
    }

    static var leftIDKey: WritableKeyPath<AccessoryRegionPivot, Int> {
        return \AccessoryRegionPivot.accessoryId
    }

    static var rightIDKey: WritableKeyPath<AccessoryRegionPivot, Int> {
        return \AccessoryRegionPivot.regionId
    }
}
