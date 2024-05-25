//
//  PDFBuild+Text.swift
//  Chord Provider
//
//  © 2024 Nick Berendsen
//

import Foundation

extension PDFBuild {

    // MARK: A PDF **text** element

    /// A PDF **text** element
    class Text: PDFElement {

        /// The text
        let text: NSAttributedString

        /// Init the **text** element
        /// - Parameters:
        ///   - text: The text as `String`
        ///   - attributes: The ``StringAttributes`` for the text
        init(_ text: String, attributes: SWIFTStringAttribute = SWIFTStringAttribute()) {
            self.text = NSAttributedString(
                string: text,
                attributes: attributes
            )
        }

        /// Init the **text** element
        /// - Parameter text: The text as `NSAttributedString`
        init(_ text: NSAttributedString) {
            self.text = text
        }

        /// Draw the **text**
        /// - Parameters:
        ///   - rect: The available rectangle
        ///   - calculationOnly: Bool if only the size should be calculated
        ///   - pageRect: The page size of the PDF document
        func draw(rect: inout CGRect, calculationOnly: Bool, pageRect: CGRect) {
            let textRect = rect.insetBy(dx: textPadding, dy: textPadding)
            let textBounds = text.bounds(withSize: textRect.size)
            if !calculationOnly {
                text.draw(with: textRect, options: textDrawingOptions, context: nil)
            }
            let height = textBounds.height + 2 * textPadding
            rect.origin.y += height
            rect.size.height -= height
        }
    }
}
