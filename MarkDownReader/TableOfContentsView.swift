import SwiftUI

struct TOCItem: Identifiable, Codable {
    let id: String
    let text: String
    let level: Int
}

struct TableOfContentsView: View {
    let items: [TOCItem]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "list.bullet.indent")
                Text("Contents")
                    .font(.headline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            if items.isEmpty {
                Text("No headings found")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(12)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(items) { item in
                            Button(action: { onSelect(item.id) }) {
                                Text(item.text)
                                    .font(fontForLevel(item.level))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, CGFloat((item.level - 1) * 12))
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 12)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                            .onHover { hovering in
                                if hovering {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .background(.ultraThinMaterial)
    }

    private func fontForLevel(_ level: Int) -> Font {
        switch level {
        case 1: return .body.bold()
        case 2: return .body
        case 3: return .callout
        default: return .caption
        }
    }
}
