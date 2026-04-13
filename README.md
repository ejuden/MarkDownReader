# MarkDown Reader

A free, lightweight Markdown viewer for macOS. Double-click any `.md` file and read it beautifully rendered — no editor, no clutter, just your content.

## Features

- **Render Markdown** — headings, bold/italic, links, images, code blocks, tables, blockquotes, task lists, and more
- **Table of Contents** — auto-generated sidebar for quick navigation (toggle with Cmd+Shift+T)
- **Print** — print documents directly (Cmd+P)
- **Export to PDF** — save any document as a PDF (Cmd+Shift+E)
- **Search** — find text within documents (Cmd+F) with match navigation
- **Zoom** — adjust text size with Cmd+/Cmd+- (reset with Cmd+0)
- **Dark Mode** — automatically follows your macOS appearance setting
- **Recent Files** — quickly reopen previous documents from File > Open Recent
- **External Links** — links open in your default browser

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (to build from source)

## Build & Install

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/MarkDownReader.git
   ```
2. Open `MarkDownReader.xcodeproj` in Xcode
3. Select your development team under Signing & Capabilities (or choose "Sign to Run Locally")
4. Build and run (Cmd+R), or archive for distribution (Product > Archive)
5. Drag `MarkDownReader.app` to your Applications folder

## Set as Default Markdown Viewer

1. Right-click any `.md` file in Finder
2. Select **Get Info**
3. Under "Open with:", choose **MarkDown Reader**
4. Click **Change All...** to apply to all `.md` files

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd+P | Print |
| Cmd+Shift+E | Export as PDF |
| Cmd+F | Find in document |
| Cmd+G | Next search result |
| Cmd+Shift+G | Previous search result |
| Cmd++ | Zoom in |
| Cmd+- | Zoom out |
| Cmd+0 | Reset zoom |
| Cmd+Shift+T | Toggle table of contents |

## Supported Markdown

- ATX and Setext headings
- Bold, italic, and bold+italic
- Strikethrough (~~text~~)
- Inline code and fenced code blocks (with language labels)
- Links and images (with optional titles)
- Ordered and unordered lists (with nesting)
- Task lists / checkboxes
- GFM tables with alignment
- Blockquotes (nested)
- Horizontal rules
- Autolinks
- Line breaks

## Contributing

Contributions are welcome! Some ideas for improvement:

- Syntax highlighting for code blocks
- File watching (auto-reload on external changes)
- Custom themes / CSS
- App icon design
- Mathematical notation (LaTeX / KaTeX)
- Mermaid diagram support
- Footnotes

Please open an issue or submit a pull request.

## License

This project is released under the [MIT License](LICENSE).
