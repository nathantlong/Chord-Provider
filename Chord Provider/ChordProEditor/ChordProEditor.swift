//
//  ChordProEditor.swift
//  Chord Provider
//
//  © 2024 Nick Berendsen
//

import SwiftUI

/// SwiftUI `NSViewRepresentable` for the ChordPro editor
struct ChordProEditor: SWIFTViewRepresentable {

    /// The text of the ChordPro file
    @Binding var text: String
    /// The observable ``Connector`` class for the editor
    var connector: Connector

    /// Init the **ChordProEditor**
    /// - Parameters:
    ///   - text: The text of the ``ChordProDocument``
    ///   - connector: The ``ChordProEditor/Connector`` class for the editor
    init(text: Binding<String>, connector: Connector) {
        self._text = text
        self.connector = connector
    }

    /// Make a `coordinator` for the ``SWIFTViewRepresentable``
    /// - Returns: A `coordinator`
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, connector: connector)
    }

#if os(macOS)

    // MARK: macOS

    func makeNSView(context: Context) -> Wrapper {

        let macEditor = Wrapper()

        macEditor.textView.connector = connector
        macEditor.textView.string = text
        connector.textView = macEditor.textView

        macEditor.textView.delegate = context.coordinator
        /// Wait for next cycle and set the textview as first responder
        Task { @MainActor in
            connector.processHighlighting(fullText: true)
            macEditor.textView.selectedRanges = [NSValue(range: NSRange())]
            macEditor.textView.window?.makeFirstResponder(macEditor.textView)
        }
        return macEditor
    }

    func updateNSView(_ nsView: Wrapper, context: Context) {}

#else

    // MARK: iOS and visionOS

    func makeUIView(context: Context) -> TextView {

        let textView = TextView()

        textView.delegate = context.coordinator
        textView.text = self.text
        textView.selectedRange = .init()
        textView.textContainerInset = .zero
        connector.textView = textView
        connector.processHighlighting(fullText: true)
        return textView
    }

    func updateUIView(_ view: TextView, context: Context) {}

#endif
}
