import Foundation
import PackagePlugin

@main
struct LocalizationCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let tool = try context.tool(named: "LocalizationCodegenGenerator")
        let sourceTargets = context.package.targets.compactMap { $0 as? SourceModuleTarget }

        for sourceTarget in sourceTargets {
            let templateFiles = try templateFiles(in: sourceTarget.directoryURL)

            for fileURL in templateFiles {
                let baseName = fileURL
                    .deletingPathExtension()
                    .deletingPathExtension()
                    .lastPathComponent
                let outputURL = fileURL.deletingLastPathComponent()
                    .appending(path: baseName + ".generated.swift")

                try runGenerator(
                    executableURL: tool.url,
                    inputURL: fileURL,
                    outputURL: outputURL
                )
            }
        }
    }

    private func runGenerator(executableURL: URL, inputURL: URL, outputURL: URL) throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = [
            inputURL.path(),
            outputURL.path(),
        ]

        let stderr = Pipe()
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = stderr.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            throw LocalizationCommandPluginError.generatorFailed(inputURL.lastPathComponent, message)
        }
    }

    private func templateFiles(in directoryURL: URL) throws -> [URL] {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        var results: [URL] = []
        while let item = enumerator?.nextObject() as? URL {
            guard item.pathExtension == "swift",
                  item.deletingPathExtension().pathExtension == "l10ndef" else {
                continue
            }

            results.append(item)
        }

        return results.sorted { $0.path < $1.path }
    }
}

private enum LocalizationCommandPluginError: Error, CustomStringConvertible {
    case generatorFailed(String, String?)

    var description: String {
        switch self {
        case let .generatorFailed(fileName, message):
            let suffix = message.map { ": \($0)" } ?? ""
            return "failed to generate \(fileName)\(suffix)"
        }
    }
}
