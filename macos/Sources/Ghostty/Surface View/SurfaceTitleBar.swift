import SwiftUI

extension Ghostty {
    /// A title belongs to the terminal surface, so it follows a moved split and
    /// uses the same saved override as "Change Terminal Title" in the menu.
    struct SurfaceTitleBar: View {
        @ObservedObject var surfaceView: SurfaceView
        let isActive: Bool

        @State private var isEditing = false
        @State private var draft = ""
        @FocusState private var editorFocused: Bool

        private var displayTitle: String {
            SplitTitle.display(
                override: surfaceView.titleOverride,
                directory: surfaceView.pwd,
                terminalTitle: surfaceView.title
            )
        }

        var body: some View {
            HStack(spacing: 6) {
                Circle()
                    .fill(isActive ? Color.accentColor : Color.secondary.opacity(0.35))
                    .frame(width: 5, height: 5)
                    .accessibilityHidden(true)

                if isEditing {
                    TextField("Split name", text: $draft)
                        .textFieldStyle(.plain)
                        .focused($editorFocused)
                        .onAppear { editorFocused = true }
                        .onSubmit { finishEditing(commit: true, restoreFocus: true) }
                        .onExitCommand { finishEditing(commit: false, restoreFocus: true) }
                        .onChange(of: editorFocused) { focused in
                            if !focused {
                                // A click into another split must keep its new focus.
                                finishEditing(commit: true, restoreFocus: false)
                            }
                        }
                        .help("Leave blank to use the directory name")
                } else {
                    Text(displayTitle)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) { beginEditing() }
                        .onTapGesture { focusTerminal() }
                        .help(surfaceView.pwd ?? displayTitle)
                        .accessibilityLabel("Split title: \(displayTitle)")
                        .accessibilityHint("Double-click to rename this split")
                        .accessibilityAction(named: "Rename Split") { beginEditing() }
                        .contextMenu {
                            Button("Rename Split…") { beginEditing() }
                            Button("Use Directory Name") { surfaceView.titleOverride = nil }
                                .disabled(surfaceView.titleOverride == nil)
                        }
                }
            }
            .font(.system(size: 11, weight: isActive ? .medium : .regular))
            .foregroundStyle(isActive ? .primary : .secondary)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(.ultraThinMaterial)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(height: 1)
            }
        }

        private func beginEditing() {
            draft = surfaceView.titleOverride ?? displayTitle
            isEditing = true
        }

        private func finishEditing(commit: Bool, restoreFocus: Bool) {
            guard isEditing else { return }
            // End the edit before changing focus: Escape must not be committed
            // by the subsequent focus-loss callback.
            isEditing = false
            if commit {
                surfaceView.titleOverride = SplitTitle.override(from: draft)
            }
            editorFocused = false
            if restoreFocus {
                focusTerminal()
            }
        }

        private func focusTerminal() {
            surfaceView.window?.makeFirstResponder(surfaceView)
        }
    }
}
