//
//  Shift.swift
//  AppBooster
//
//  Created by Kael on 12/3/25.
//

import Foundation

public extension String {
    func shifting(offset: Int) -> String? {
        var result = ""
        do {
            let array = try self.unicodeScalars.map { scalar throws -> UnicodeScalar in
                guard let result = UnicodeScalar(UInt32(Int(scalar.value) + offset)) else {
                    throw NSError()
                }
                return result
            }
            result.unicodeScalars.append(contentsOf: array)
        } catch {
            return nil
        }

        return result
    }
}
