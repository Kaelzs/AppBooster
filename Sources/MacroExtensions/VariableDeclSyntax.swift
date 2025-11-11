//
//  VariableDeclSyntax.swift
//  AppBooster
//
//  Created by Kael on 8/27/25.
//

import MacroToolkit
import SwiftSyntax

public extension VariableDeclSyntax {
    var isStatic: Bool {
        modifiers.contains { $0.name.text == "static" }
    }

    var isClass: Bool {
        modifiers.contains { $0.name.text == "class" }
    }

    var isLazy: Bool {
        modifiers.contains { $0.name.text == "lazy" }
    }

    var isStoredProperty: Bool {
        Variable(self).isStoredProperty
    }
}

public extension Variable {
    var isStatic: Bool {
        self._syntax.isStatic
    }

    var isClass: Bool {
        self._syntax.isClass
    }

    var isLazy: Bool {
        self._syntax.isLazy
    }
}
