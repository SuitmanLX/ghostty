import Testing
@testable import Ghostty

struct SplitTitleTests {
    @Test func pinnedTitleTakesPriorityOverDirectoryAndShell() {
        #expect(SplitTitle.display(
            override: "Build logs", directory: "/work/maiga", terminalTitle: "zsh"
        ) == "Build logs")
    }

    @Test(arguments: [
        ("/work/maiga", "maiga"),
        ("/work/mtl4/", "mtl4"),
        ("/work/研发", "研发"),
        ("/", "/"),
        ("/Users/example", "~"),
    ])
    func directoryNames(directory: String, expected: String) {
        #expect(SplitTitle.display(
            override: nil, directory: directory, terminalTitle: "zsh", homeDirectory: "/Users/example"
        ) == expected)
    }

    @Test func missingDirectoryFallsBackToTerminalTitle() {
        #expect(SplitTitle.display(override: nil, directory: nil, terminalTitle: "ssh server") == "ssh server")
        #expect(SplitTitle.display(override: nil, directory: "", terminalTitle: "") == "Terminal")
    }

    @Test func clearingNameRestoresDirectoryAndPreservesUnicodeNames() {
        #expect(SplitTitle.override(from: " \n ") == nil)
        #expect(SplitTitle.override(from: "  前端构建  ") == "前端构建")
        #expect(SplitTitle.display(
            override: SplitTitle.override(from: ""), directory: "/work/maiga", terminalTitle: "Old title"
        ) == "maiga")
    }
}
