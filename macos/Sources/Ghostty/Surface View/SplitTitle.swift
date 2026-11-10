import Foundation

/// Presentation rules shared by the split title bar and its inline editor.
enum SplitTitle {
    static func display(
        override: String?,
        directory: String?,
        terminalTitle: String,
        homeDirectory: String = FileManager.default.homeDirectoryForCurrentUser.path
    ) -> String {
        if let override, !override.isEmpty { return override }
        if let directory, !directory.isEmpty {
            if directory == homeDirectory { return "~" }
            if directory == "/" { return "/" }
            let name = URL(fileURLWithPath: directory).lastPathComponent
            if !name.isEmpty { return name }
        }
        return terminalTitle.isEmpty ? "Terminal" : terminalTitle
    }

    /// Empty names release the existing terminal title override.
    static func override(from draft: String) -> String? {
        let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
