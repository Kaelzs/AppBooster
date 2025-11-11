//
//  DiagnosticBuilder.swift
//  AppBooster
//
//  Created by Kael on 8/27/25.
//

import MacroToolkit

public protocol Diagnostiable {
    var id: String { get }
    var domain: String { get }
    var description: String { get }
}

public extension DiagnosticBuilder {
    func error<E: Diagnostiable>(_ error: E) -> Self {
        self.message(error.description)
            .messageID(domain: error.domain, id: error.id)
    }
}
