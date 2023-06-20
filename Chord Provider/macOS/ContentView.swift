//
//  ContentView.swift
//  Chord Provider
//
//  © 2023 Nick Berendsen
//

import SwiftUI

/// SwiftUI `View` for the content
struct ContentView: View {
    /// The ChordPro document
    @Binding var document: ChordProDocument
    /// The optional file location
    let file: URL?
    /// The ``Song``
    @State var song = Song()
    /// The body of the `View`
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(song: song, file: file)
                .background(Color.accentColor)
                .foregroundColor(.white)
            MainView(document: $document, song: $song, file: file)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .toolbar {
            ToolbarView(song: $song)
            ExportSongView(song: song)
        }
    }
}
