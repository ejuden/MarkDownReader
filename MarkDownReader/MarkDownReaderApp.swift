import SwiftUI
import UniformTypeIdentifiers

@main
struct MarkDownReaderApp: App {
    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { config in
            ContentView(document: config.document, fileURL: config.fileURL)
        }
        .commands {
            CommandGroup(after: .saveItem) {
                Button("Export as PDF...") {
                    NotificationCenter.default.post(name: .exportPDF, object: nil)
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }

            CommandGroup(after: .textEditing) {
                Button("Find...") {
                    NotificationCenter.default.post(name: .toggleSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: .command)

                Divider()

                Button("Zoom In") {
                    NotificationCenter.default.post(name: .zoomIn, object: nil)
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Zoom Out") {
                    NotificationCenter.default.post(name: .zoomOut, object: nil)
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Actual Size") {
                    NotificationCenter.default.post(name: .zoomReset, object: nil)
                }
                .keyboardShortcut("0", modifiers: .command)
            }

            CommandGroup(after: .sidebar) {
                Button("Toggle Table of Contents") {
                    NotificationCenter.default.post(name: .toggleTOC, object: nil)
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }
}

extension Notification.Name {
    static let exportPDF = Notification.Name("exportPDF")
    static let toggleSearch = Notification.Name("toggleSearch")
    static let zoomIn = Notification.Name("zoomIn")
    static let zoomOut = Notification.Name("zoomOut")
    static let zoomReset = Notification.Name("zoomReset")
    static let toggleTOC = Notification.Name("toggleTOC")
}
