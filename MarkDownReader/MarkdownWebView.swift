import SwiftUI
import WebKit

class WebViewStore: ObservableObject {
    var webView: WKWebView?

    func scrollToHeading(_ headingID: String) {
        let escaped = headingID.jsEscaped
        webView?.evaluateJavaScript("scrollToHeading('\(escaped)')", completionHandler: nil)
    }

    func search(_ query: String, completion: @escaping (String) -> Void) {
        guard let webView = webView else { return }
        if query.isEmpty {
            clearSearch()
            completion("")
            return
        }
        let escaped = query.jsEscaped
        webView.evaluateJavaScript("searchText('\(escaped)')") { result, _ in
            if let json = result as? String {
                completion(json)
            }
        }
    }

    func nextMatch(completion: @escaping (String) -> Void) {
        webView?.evaluateJavaScript("nextMatch()") { result, _ in
            if let json = result as? String {
                completion(json)
            }
        }
    }

    func previousMatch(completion: @escaping (String) -> Void) {
        webView?.evaluateJavaScript("prevMatch()") { result, _ in
            if let json = result as? String {
                completion(json)
            }
        }
    }

    func clearSearch() {
        webView?.evaluateJavaScript("clearSearch()", completionHandler: nil)
    }

    func printDocument() {
        guard let webView = webView else { return }
        let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = false
        printInfo.topMargin = 40
        printInfo.bottomMargin = 40
        printInfo.leftMargin = 40
        printInfo.rightMargin = 40

        let printOp = webView.printOperation(with: printInfo)
        printOp.showsPrintPanel = true
        printOp.showsProgressPanel = true

        if let window = webView.window {
            printOp.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
        } else {
            printOp.run()
        }
    }

    func exportPDF(suggestedName: String) {
        guard let webView = webView else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = suggestedName
        savePanel.canCreateDirectories = true

        let window = webView.window

        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let url = savePanel.url else { return }
            let config = WKPDFConfiguration()
            webView.createPDF(configuration: config) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        try? data.write(to: url)
                    case .failure(let error):
                        let alert = NSAlert()
                        alert.messageText = "Export Failed"
                        alert.informativeText = error.localizedDescription
                        alert.alertStyle = .warning
                        if let window = window {
                            alert.beginSheetModal(for: window)
                        } else {
                            alert.runModal()
                        }
                    }
                }
            }
        }

        if let window = window {
            savePanel.beginSheetModal(for: window, completionHandler: handler)
        } else {
            handler(savePanel.runModal())
        }
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let markdown: String
    let zoomLevel: CGFloat
    @ObservedObject var store: WebViewStore
    var onTOCUpdate: ([TOCItem]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "tocUpdate")
        config.userContentController.add(context.coordinator, name: "linkClicked")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")

        if let templateURL = Bundle.main.url(forResource: "template", withExtension: "html") {
            webView.loadFileURL(templateURL, allowingReadAccessTo: templateURL.deletingLastPathComponent())
        }

        DispatchQueue.main.async {
            store.webView = webView
        }

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if markdown != context.coordinator.lastMarkdown {
            context.coordinator.lastMarkdown = markdown
            if context.coordinator.isLoaded {
                context.coordinator.injectMarkdown(into: webView, markdown: markdown)
            } else {
                context.coordinator.pendingMarkdown = markdown
            }
        }

        webView.pageZoom = zoomLevel
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: MarkdownWebView
        var isLoaded = false
        var lastMarkdown = ""
        var pendingMarkdown: String?

        init(parent: MarkdownWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoaded = true
            if let md = pendingMarkdown {
                injectMarkdown(into: webView, markdown: md)
                pendingMarkdown = nil
            } else {
                injectMarkdown(into: webView, markdown: parent.markdown)
            }
        }

        func injectMarkdown(into webView: WKWebView, markdown: String) {
            let escaped = markdown.jsEscaped
            webView.evaluateJavaScript("renderMarkdown('\(escaped)')") { _, _ in
                webView.evaluateJavaScript("getHeadings()") { result, _ in
                    if let json = result as? String,
                       let data = json.data(using: .utf8),
                       let items = try? JSONDecoder().decode([TOCItem].self, from: data) {
                        DispatchQueue.main.async {
                            self.parent.onTOCUpdate(items)
                        }
                    }
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            if message.name == "linkClicked", let urlString = message.body as? String,
               let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                if url.scheme == "http" || url.scheme == "https" {
                    NSWorkspace.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}

extension String {
    var jsEscaped: String {
        self.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
    }
}
