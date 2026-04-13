import SwiftUI

struct ContentView: View {
    let document: MarkdownDocument
    let fileURL: URL?

    @StateObject private var webViewStore = WebViewStore()
    @State private var showTOC = true
    @State private var zoomLevel: CGFloat = 1.0
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var searchResultInfo = ""
    @State private var tocItems: [TOCItem] = []

    var body: some View {
        VStack(spacing: 0) {
            // File path bar
            if let path = fileURL?.path {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 10))
                    Text(path)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.bar)
                Divider()
            }

        HSplitView {
            if showTOC {
                TableOfContentsView(items: tocItems) { headingID in
                    webViewStore.scrollToHeading(headingID)
                }
                .frame(minWidth: 180, idealWidth: 240, maxWidth: 320)
            }

            ZStack(alignment: .top) {
                MarkdownWebView(
                    markdown: document.text,
                    zoomLevel: zoomLevel,
                    store: webViewStore,
                    onTOCUpdate: { items in
                        tocItems = items
                    }
                )

                if isSearching {
                    SearchBar(
                        searchText: $searchText,
                        resultInfo: $searchResultInfo,
                        onSearch: { query in
                            webViewStore.search(query) { info in
                                searchResultInfo = info
                            }
                        },
                        onNext: {
                            webViewStore.nextMatch { info in
                                searchResultInfo = info
                            }
                        },
                        onPrevious: {
                            webViewStore.previousMatch { info in
                                searchResultInfo = info
                            }
                        },
                        onDismiss: {
                            isSearching = false
                            searchText = ""
                            searchResultInfo = ""
                            webViewStore.clearSearch()
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        } // HSplitView
        } // VStack
        .toolbar {
            ToolbarItemGroup {
                Button(action: { showTOC.toggle() }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Table of Contents")

                Spacer()

                Button(action: zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                }
                .help("Zoom Out")

                Text("\(Int(zoomLevel * 100))%")
                    .frame(width: 45)
                    .font(.caption)

                Button(action: zoomInAction) {
                    Image(systemName: "plus.magnifyingglass")
                }
                .help("Zoom In")

                Spacer()

                Button(action: { isSearching.toggle() }) {
                    Image(systemName: "magnifyingglass")
                }
                .help("Find in Document")

                Button(action: { webViewStore.printDocument() }) {
                    Image(systemName: "printer")
                }
                .help("Print")

                Button(action: { webViewStore.exportPDF(suggestedName: pdfFileName) }) {
                    Image(systemName: "arrow.down.doc")
                }
                .help("Export as PDF")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .exportPDF)) { _ in
            webViewStore.exportPDF(suggestedName: pdfFileName)
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleSearch)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                isSearching.toggle()
                if !isSearching {
                    searchText = ""
                    searchResultInfo = ""
                    webViewStore.clearSearch()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .zoomIn)) { _ in
            zoomInAction()
        }
        .onReceive(NotificationCenter.default.publisher(for: .zoomOut)) { _ in
            zoomOut()
        }
        .onReceive(NotificationCenter.default.publisher(for: .zoomReset)) { _ in
            zoomLevel = 1.0
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleTOC)) { _ in
            showTOC.toggle()
        }
        .frame(minWidth: 600, minHeight: 400)
        .navigationTitle(fileURL?.lastPathComponent ?? "Markdown")
    }

    private var pdfFileName: String {
        if let name = fileURL?.deletingPathExtension().lastPathComponent {
            return name + ".pdf"
        }
        return "document.pdf"
    }

    private func zoomInAction() {
        zoomLevel = min(zoomLevel + 0.1, 3.0)
    }

    private func zoomOut() {
        zoomLevel = max(zoomLevel - 0.1, 0.3)
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var resultInfo: String
    var onSearch: (String) -> Void
    var onNext: () -> Void
    var onPrevious: () -> Void
    var onDismiss: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onSubmit { onNext() }
                .onChange(of: searchText) { newValue in
                    onSearch(newValue)
                }

            if !resultInfo.isEmpty {
                Text(resultInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button(action: onPrevious) {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.borderless)

            Button(action: onNext) {
                Image(systemName: "chevron.down")
            }
            .buttonStyle(.borderless)

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)
        }
        .padding(8)
        .background(.regularMaterial)
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onAppear { isFocused = true }
        .onExitCommand { onDismiss() }
    }
}
