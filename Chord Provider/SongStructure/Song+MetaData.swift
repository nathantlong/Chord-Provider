//
//  Song+MetaData.swift
//  Chord Provider
//
//  © 2024 Nick Berendsen
//

import Foundation

extension Song {

    // MARK: The structure for meta data about the song

    /// Structure for meta data about the song
    struct MetaData {

        // MARK: Meta-data directives

        /// The title
        var title: String = "No title"
        /// The artist
        var artist: String = "Unknown Artist"
        /// The optional capo
        var capo: String?
        /// The optional key
        var key: ChordDefinition?
        /// The optional tempo
        var tempo: String?
        /// The optional time
        var time: String?
        /// The optional year
        var year: String?
        /// The optional album
        var album: String?
        /// The optional tuning
        var tuning: String?
        /// The optional path to the audio file
        var musicPath: String?
        /// The optional tag(s)
        var tags: [String] = []
        /// The optional transpose
        var transpose: Int = 0
        /// The instrument
        var instrument: Instrument = .guitarStandardETuning

        /// The optional file URL
        var fileURL: URL?

        // MARK: Song export

        /// The default name for the export
        var exportName: String {
            "\(artist) - \(title)"
        }
    }
}
