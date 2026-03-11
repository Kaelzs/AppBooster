import Foundation
import LocalizationCodegenCore

enum MainError: Error, CustomStringConvertible {
    case invalidArguments

    var description: String {
        switch self {
        case .invalidArguments:
            return "usage: LocalizationCodegenGenerator <input> <output>"
        }
    }
}

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    guard arguments.count == 2 else {
        throw MainError.invalidArguments
    }

    let inputPath = arguments[0]
    let outputPath = arguments[1]

    let input = try String(contentsOfFile: inputPath, encoding: .utf8)
    let output = try L10nCodegen.renderFile(from: input)
    try output.write(toFile: outputPath, atomically: true, encoding: .utf8)
} catch {
    fputs("error: \(error)\n", stderr)
    exit(1)
}
