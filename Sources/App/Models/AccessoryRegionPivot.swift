//
//  Created by Kim de Vos on 02/04/2018.
//

import FluentPostgreSQL

final class AccessoryRegionPivot: PostgreSQLPivot {
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
