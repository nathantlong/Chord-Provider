//
//  PDFBuild+Chords+Diagram.swift
//  Chord Provider
//
//  © 2024 Nick Berendsen
//

import AppKit

extension PDFBuild.Chords {

    // MARK: A PDF **chord diagram** element

    /// A PDF **chord diagram** element
    ///
    /// Display a single chord diagram
    class Diagram: PDFElement {

        // MARK: Variables

        /// The chord to display in a diagram
        let chord: ChordDefinition
        /// The chord display options
        let options: AppSettings.DiagramDisplayOptions

        // MARK: Calculated constants

        /// Total amount of columns of the diagram
        let columns: Int
        /// The width of the grid
        let width: CGFloat
        /// The height of the grid
        let height: CGFloat
        /// The horizontal spacing between each grid cell
        let xSpacing: CGFloat
        /// The vertical spacing between each grid cell
        let ySpacing: CGFloat
        /// The frets of the chord; adjusted for left-handed if needed
        let frets: [Int]
        /// The fingers of the chord; adjusted for left-handed if needed
        let fingers: [Int]

        // MARK: Fixed constants

        /// The size of the grid
        let gridSize = CGSize(width: 50, height: 60)

        /// Init the **chord diagram** element
        /// - Parameters:
        ///   - chord: The chord to display in a diagram
        ///   - options: The chord display options
        init(chord: ChordDefinition, options: AppSettings.DiagramDisplayOptions) {
            self.chord = chord
            self.options = options
            self.columns = (chord.instrument.strings.count) - 1
            self.width = gridSize.width
            self.height = gridSize.height
            self.xSpacing = width / Double(columns)
            self.ySpacing = height / 5
            self.frets = options.mirrorDiagram ? chord.frets.reversed() : chord.frets
            self.fingers = options.mirrorDiagram ? chord.fingers.reversed() : chord.fingers
        }

        /// Draw the **chords** element as a `Section` element
        /// - Parameters:
        ///   - rect: The available rectangle
        ///   - calculationOnly: Bool if only the Bounding Rect should be calculated
        ///   - pageRect: The page size of the PDF document
        // swiftlint:disable:next function_body_length
        func draw(rect: inout CGRect, calculationOnly: Bool, pageRect: CGRect) {
            let initialRect = rect
            var currentDiagramHeight: CGFloat = 0
            drawChordName(rect: &rect)
            rect.origin.y = initialRect.origin.y + currentDiagramHeight
            rect.size.height = initialRect.size.height - currentDiagramHeight
            drawTopBar(rect: &rect)
            rect.origin.y = initialRect.origin.y + currentDiagramHeight
            rect.size.height = initialRect.size.height - currentDiagramHeight
            drawNut(rect: &rect, calculationOnly: calculationOnly)
            rect.origin.y = initialRect.origin.y + currentDiagramHeight
            rect.size.height = initialRect.size.height - currentDiagramHeight
            if chord.baseFret != 1 {
                drawBaseFret(rect: &rect)
            }
            drawGrid(rect: &rect, calculationOnly: calculationOnly)
            /// No need to draw dots and barres when we are calculating the size
            if !calculationOnly {
                drawFrets(rect: &rect)
                drawBarres(rect: &rect)
            }
            rect.origin.y = initialRect.origin.y + currentDiagramHeight
            rect.size.height = initialRect.size.height - currentDiagramHeight
            if options.showNotes {
                drawNotesBar(rect: &rect)
                rect.origin.y = initialRect.origin.y + currentDiagramHeight
                rect.size.height = initialRect.size.height - currentDiagramHeight
            }
            rect.origin.y = initialRect.origin.y + currentDiagramHeight
            rect.size.height = initialRect.size.height - currentDiagramHeight
            rect.origin.x += gridSize.width + 3 * xSpacing
            rect.size.width -= gridSize.width + 3 * xSpacing

            // MARK: Chord Name

            /// Draw the name of the chord
            /// - Parameter rect: The available rect
            func drawChordName(rect: inout CGRect) {
                var nameRect = CGRect(
                    x: rect.origin.x,
                    y: rect.origin.y,
                    width: gridSize.width + 3 * xSpacing,
                    height: rect.height
                )
                let chord = chord.display
                let name = PDFBuild.Text(chord, attributes: .diagramChordName + .alignment(.center))
                name.draw(rect: &nameRect, calculationOnly: calculationOnly, pageRect: pageRect)
                /// Add this item to the total height
                currentDiagramHeight += (nameRect.origin.y - rect.origin.y) * 0.8
            }

            // MARK: Top Bar

            /// Draw the top bar of the chord
            /// - Parameter rect: The available rect
            func drawTopBar(rect: inout CGRect) {
                var topBarRect = CGRect(
                    x: rect.origin.x + xSpacing,
                    y: rect.origin.y,
                    width: xSpacing,
                    height: ySpacing
                )
                var string = ""
                var height: CGFloat = 0
                for index in chord.frets.indices {
                    let fret = frets[index]
                    switch fret {
                    case -1:
                        string = "􀆄"
                    case 0:
                        string = "􀀀"
                    default:
                        string = " "
                    }
                    let symbol = PDFBuild.Text(string, attributes: .diagramTopBar)
                    var tmpRect = topBarRect
                    symbol.draw(rect: &tmpRect, calculationOnly: calculationOnly, pageRect: pageRect)
                    height = tmpRect.origin.y - rect.origin.y
                    topBarRect.origin.x += xSpacing
                }
                /// Add this item to the total height
                currentDiagramHeight += height
            }

            // MARK: Nut

            /// Draw the nut of the chord
            /// - Parameters:
            ///   - rect: The available rect
            ///   - calculationOnly: Bool if only the Bounding Rect should be calculated
            func drawNut(rect: inout CGRect, calculationOnly: Bool) {
                if !calculationOnly {
                    let nutRect = CGRect(
                        x: rect.origin.x + xSpacing * 1.25,
                        y: rect.origin.y,
                        width: gridSize.width + xSpacing * 0.55,
                        height: ySpacing / 5
                    )
                    if chord.baseFret == 1, let context = NSGraphicsContext.current?.cgContext {
                        context.setFillColor(NSColor.black.cgColor)
                        context.fill(nutRect)
                    }
                }
                /// Add this item to the total height
                currentDiagramHeight += ySpacing / 5
            }

            // MARK: Base Fret

            /// Draw the base fret of the chord
            /// - Parameter rect: The available rect
            func drawBaseFret(rect: inout CGRect) {
                var baseFretRect = CGRect(
                    x: rect.origin.x + xSpacing / 2.5,
                    y: rect.origin.y + ySpacing / 8,
                    width: gridSize.width,
                    height: rect.height
                )
                let name = PDFBuild.Text("\(chord.baseFret)", attributes: .diagramBaseFret + .alignment(.left))
                name.draw(rect: &baseFretRect, calculationOnly: calculationOnly, pageRect: pageRect)
            }

            // MARK: Grid

            /// Draw the grid of the chords
            /// - Parameters:
            ///   - rect: The available rect
            ///   - calculationOnly: Bool if only the Bounding Rect should be calculated
            func drawGrid(rect: inout CGRect, calculationOnly: Bool) {
                if !calculationOnly {
                    let gridPoint = CGPoint(
                        x: rect.origin.x + (xSpacing * 1.5),
                        y: rect.origin.y
                    )
                    var start = gridPoint
                    if let context = NSGraphicsContext.current?.cgContext {
                        /// Draw the strings
                        for _ in 0...columns {
                            context.move(to: start)
                            context.addLine(to: CGPoint(x: start.x, y: start.y + gridSize.height))
                            start.x += xSpacing
                        }
                        /// Move start back to the gridpoint
                        start = gridPoint
                        /// Draw the frets
                        for _ in 0...5 {
                            context.move(to: start)
                            context.addLine(to: CGPoint(x: start.x + gridSize.width, y: start.y))
                            start.y += ySpacing
                        }
                        context.setStrokeColor(NSColor.black.cgColor)
                        context.setLineWidth(0.2)
                        context.setLineCap(.round)
                        context.strokePath()
                    }
                }
                /// Add this item to the total height
                currentDiagramHeight += gridSize.height
            }

            // MARK: Frets

            /// Draw the frets in the grid
            /// - Parameters:
            ///   - rect: The available rect
            func drawFrets(rect: inout CGRect) {
                /// The circle radius is the same for every instrument
                let circleRadius = gridSize.width / 5
                /// Below should be 0 for a six string instrument
                let xOffset = (xSpacing - circleRadius) / 2
                /// Set the rect for the grid
                var dotRect = CGRect(
                    x: rect.origin.x + xSpacing + xOffset,
                    y: rect.origin.y,
                    width: circleRadius,
                    height: ySpacing
                )
                for fret in 1...5 {
                    for string in chord.instrument.strings {
                        if frets[string] == fret && !chord.barres.map(\.fret).contains(fret) {
                            let finger = options.showFingers && fingers[string] != 0 ?
                            "\(fingers[string])" : " "
                            let text = PDFBuild.Text(finger, attributes: .diagramFinger)
                            let background = PDFBuild.Background(color: .gray, text)
                            let shape = PDFBuild.Clip(.circle, background)
                            var tmpRect = dotRect
                            shape.draw(rect: &tmpRect, calculationOnly: calculationOnly, pageRect: pageRect)
                        }
                        /// Move X one string to the right
                        dotRect.origin.x += xSpacing
                    }
                    /// Move X back to the left
                    dotRect.origin.x = rect.origin.x + xSpacing + xOffset
                    /// Move Y one fret down
                    dotRect.origin.y += ySpacing
                }
            }

            // MARK: Barres

            /// Draw the barres in the grid
            /// - Parameter rect: The available rect
            func drawBarres(rect: inout CGRect) {
                /// The circle radius is the same for every instrument
                let circleRadius = gridSize.width / 5
                /// Below should be 0 for a six string instrument
                let xOffset = (xSpacing - circleRadius) / 2
                /// Set the rect for the grid
                var barresRect = CGRect(
                    x: rect.origin.x + xSpacing,
                    y: rect.origin.y,
                    width: xSpacing,
                    height: ySpacing
                )
                for fret in 1...5 {
                    if var barre = chord.barres.first(where: { $0.fret == fret }) {
                        /// Mirror for left-handed if needed
                        barre = options.mirrorDiagram ? chord.mirrorBarre(barre) : barre
                        let finger = options.showFingers ? "\(barre.finger)" : " "
                        let text = PDFBuild.Text(finger, attributes: .diagramFinger)
                        let background = PDFBuild.Background(color: .gray, text)
                        let shape = PDFBuild.Clip(.roundedRect(radius: circleRadius / 2), background)
                        var tmpRect = CGRect(
                            x: barresRect.origin.x + (CGFloat(barre.startIndex) * xSpacing) + xOffset,
                            y: barresRect.origin.y,
                            width: (CGFloat(barre.length) * xSpacing) - (2 * xOffset),
                            height: ySpacing
                        )
                        shape.draw(rect: &tmpRect, calculationOnly: calculationOnly, pageRect: pageRect)
                    }
                    /// Move Y one fret down
                    barresRect.origin.y += ySpacing
                }
            }

            // MARK: Notes Bar

            /// Draw the notes bar underneath the grid
            /// - Parameter rect: The available rect
            func drawNotesBar(rect: inout CGRect) {
                let notes = options.mirrorDiagram ? chord.components.reversed() : chord.components
                var notesBarRect = CGRect(
                    x: rect.origin.x + xSpacing,
                    y: rect.origin.y,
                    width: xSpacing,
                    height: ySpacing
                )
                var height: CGFloat = 0
                for note in notes {
                    switch note.note {
                    case .none:
                        break
                    default:
                        let string = ("\(note.note.display)")
                        let note = PDFBuild.Text(string, attributes: .diagramBottomBar)
                        var tmpRect = notesBarRect
                        note.draw(rect: &tmpRect, calculationOnly: calculationOnly, pageRect: pageRect)
                        height = tmpRect.origin.y - rect.origin.y
                    }
                    notesBarRect.origin.x += xSpacing
                }
                /// Add this item to the total height
                currentDiagramHeight += height
            }
        }
    }
}

extension PDFStringAttribute {

    // MARK: Diagram string styling

    /// Style attributes for the diagram chord name
    static var diagramChordName: PDFStringAttribute {
        [
            .foregroundColor: NSColor.gray,
            .font: NSFont.systemFont(ofSize: 10, weight: .regular)
        ]
    }

    /// Style attributes for the diagram finger
    static var diagramFinger: PDFStringAttribute {
        [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 6, weight: .regular)
        ] + .alignment(.center)
    }

    /// Style attributes for the diagram top bar
    static var diagramTopBar: PDFStringAttribute {
        [
            .foregroundColor: NSColor.black,
            .font: NSFont.systemFont(ofSize: 4, weight: .regular)
        ] + .alignment(.center)
    }

    /// Style attributes for the diagram base fret
    static var diagramBaseFret: PDFStringAttribute {
        [
            .foregroundColor: NSColor.black,
            .font: NSFont.systemFont(ofSize: 4, weight: .regular)
        ] + .alignment(.left)
    }

    /// Style attributes for the diagram top bar
    static var diagramBottomBar: PDFStringAttribute {
        [
            .foregroundColor: NSColor.black,
            .font: NSFont.systemFont(ofSize: 4, weight: .regular)
        ] + .alignment(.center)
    }
}
