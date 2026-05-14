//
//  CustomHotkeySheet.swift
//  PromptTap
//
//  Created by Gemini on 2026/05/15.
//

import SwiftUI
import AppKit

struct CustomHotkeySheet: View {
    let title: String

    @Binding var candidateHotkey: CustomHotkey?

    let currentHotkey: CustomHotkey
    let onCancel: () -> Void
    let onSave: (CustomHotkey) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)

            HotkeyCaptureField(candidateHotkey: $candidateHotkey)
                .frame(height: 34)

            HStack {
                Spacer()

                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)

                Button("Save") {
                    if let candidateHotkey {
                        onSave(candidateHotkey)
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(candidateHotkey == nil || candidateHotkey == currentHotkey)
            }
        }
        .padding(20)
        .frame(width: 360)
        .onAppear {
            candidateHotkey = currentHotkey
        }
    }
}

struct HotkeyCaptureField: NSViewRepresentable {
    @Binding var candidateHotkey: CustomHotkey?

    func makeNSView(context: Context) -> CapturingHotkeyField {
        let view = CapturingHotkeyField()
        view.onCapture = { hotkey in
            self.candidateHotkey = hotkey
        }
        return view
    }

    func updateNSView(_ nsView: CapturingHotkeyField, context: Context) {
        nsView.candidateHotkey = candidateHotkey
        nsView.onCapture = { hotkey in
            self.candidateHotkey = hotkey
        }

        DispatchQueue.main.async {
            nsView.window?.makeFirstResponder(nsView)
        }
    }
}

final class CapturingHotkeyField: NSView {
    var candidateHotkey: CustomHotkey? {
        didSet {
            needsDisplay = true
        }
    }

    var onCapture: ((CustomHotkey) -> Void)?

    override var acceptsFirstResponder: Bool {
        true
    }

    override var focusRingType: NSFocusRingType {
        get { .exterior }
        set {}
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        guard let captured = CustomHotkey.from(event: event) else {
            return
        }
        onCapture?(captured)
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.textBackgroundColor.setFill()
        bounds.fill()

        let borderColor = window?.firstResponder === self ? NSColor.keyboardFocusIndicatorColor : NSColor.separatorColor
        let border = NSBezierPath(rect: bounds.insetBy(dx: 1, dy: 1))
        borderColor.setStroke()
        border.lineWidth = window?.firstResponder === self ? 2 : 1
        border.stroke()

        drawShortcutText()
    }

    private func drawShortcutText() {
        let font = NSFont.systemFont(ofSize: 18, weight: .regular)
        let text = NSMutableAttributedString()

        appendModifier("⌃", flag: .control, font: font, to: text)
        appendModifier("⌥", flag: .option, font: font, to: text)
        appendModifier("⇧", flag: .shift, font: font, to: text)
        appendModifier("⌘", flag: .command, font: font, to: text)

        let keyText = candidateHotkey?.keyEquivalent ?? ""
        text.append(
            NSAttributedString(
                string: keyText.isEmpty ? " Press Shortcut" : " \(keyText)",
                attributes: [
                    .font: font,
                    .foregroundColor: keyText.isEmpty ? NSColor.placeholderTextColor : NSColor.controlAccentColor
                ]
            )
        )

        let rect = NSRect(x: 8, y: (bounds.height - text.size().height) / 2, width: bounds.width - 16, height: text.size().height)
        text.draw(in: rect)
    }

    private func appendModifier(
        _ symbol: String,
        flag: NSEvent.ModifierFlags,
        font: NSFont,
        to text: NSMutableAttributedString
    ) {
        let isCandidateModifier = candidateHotkey?.modifiers.contains(flag) == true
        text.append(
            NSAttributedString(
                string: symbol,
                attributes: [
                    .font: font,
                    .foregroundColor: isCandidateModifier ? NSColor.controlAccentColor : NSColor.placeholderTextColor.withAlphaComponent(0.35)
                ]
            )
        )
    }
}
