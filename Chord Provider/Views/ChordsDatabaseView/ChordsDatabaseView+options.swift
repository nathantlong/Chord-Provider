//
//  ChordsDatabaseView+options.swift
//  Chord Provider
//
//  © 2024 Nick Berendsen
//

import SwiftUI

extension ChordsDatabaseView {
    var options: some View {
        Grid(alignment: .leading) {
            GridRow {
                appState.mirrorToggle
                appState.playToggle
                chordsDatabaseState.editChordsToggle
            }
            GridRow {

                appState.notesToggle

                appState.midiInstrumentPicker
                    .frame(maxWidth: 220)
                Button {
                    do {
                        chordsDatabaseState.exportData = try Chords.exportToJSON(definitions: chordsDatabaseState.allChords)
                        chordsDatabaseState.showExportSheet.toggle()
                    } catch {
                        print(error)
                    }
                } label: {
                    Text("Export Chords to **ChordPro** format")
                }
            }
        }
        .padding()
    }
}
