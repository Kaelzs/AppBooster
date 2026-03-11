import Foundation
import PackagePlugin

@main
struct LocalizationBuildPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else {
            return []
        }

        let tool = try context.tool(named: "LocalizationCodegenGenerator")
        let templateFiles = try templateFiles(in: sourceTarget.directoryURL)

        return templateFiles.map { fileURL in
            let outputPath = context.pluginWorkDirectoryURL
                .appending(path: fileURL.deletingPathExtension().lastPathComponent + ".generated.swift")

            return .buildCommand(
                displayName: "Generating localization for \(fileURL.lastPathComponent)",
                executable: tool.url,
                arguments: [
                    fileURL.path(),
                    outputPath.path(),
                ],
                inputFiles: [fileURL],
                outputFiles: [outputPath]
            )
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
