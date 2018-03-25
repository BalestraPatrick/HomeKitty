//
//  Created by Kim de Vos on 24/03/2018.
//

import Foundation
import Vapor

/// Calls the supplied callback when all three futures have completed.
public func flatMap<A, B, C, D, Result>(
    to result: Result.Type,
    _ futureA: Future<A>,
    _ futureB: Future<B>,
    _ futureC: Future<C>,
    _ futureD: Future<D>,
    _ callback: @escaping (A, B, C, D) throws -> (Future<Result>)
    ) -> Future<Result> {
    return futureA.flatMap(to: Result.self) { a in
        return futureB.flatMap(to: Result.self) { b in
            return futureC.flatMap(to: Result.self) { c in
                return futureD.flatMap(to: Result.self) { d in
                    return try callback(a, b, c, d)
                }
            }
        }
    }
}

public func flatMap<A, B, C, D, E, Result>(
    to result: Result.Type,
    _ futureA: Future<A>,
    _ futureB: Future<B>,
    _ futureC: Future<C>,
    _ futureD: Future<D>,
    _ futureE: Future<E>,
    _ callback: @escaping (A, B, C, D, E) throws -> (Future<Result>)
    ) -> Future<Result> {
    return futureA.flatMap(to: Result.self) { a in
        return futureB.flatMap(to: Result.self) { b in
            return futureC.flatMap(to: Result.self) { c in
                return futureD.flatMap(to: Result.self) { d in
                    return futureE.flatMap(to: Result.self) { e in
                        return try callback(a, b, c, d, e)
                    }
                }
            }
        }
    }
}
