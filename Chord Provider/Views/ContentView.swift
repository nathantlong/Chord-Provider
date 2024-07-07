//
//  ContentView.swift
//  Chord Provider
//
//  © 2024 Nick Berendsen
//

import SwiftUI
import ChordProShared
import SwiftlyChordUtilities

/// SwiftUI `View` for the content
struct ContentView: View {
    /// The ChordPro document
    @Binding var document: ChordProDocument
    /// The optional file location
    let file: URL?
    /// The app state
    @Environment(AppState.self) private var appState
    /// The state of the scene
    @State private var sceneState = SceneState()
    /// The body of the `View`
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            MainView(document: $document)
                .background(Color.telecaster.opacity(0.2))
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                sceneState.showEditorButton
            }
        }
        .toolbar {
            ToolbarView(document: document)
        }
        /// Give the menubar access to the Scene State
        .focusedSceneValue(\.sceneState, sceneState)
        .task {
            if document.text == ChordProDocument.newText {
                sceneState.presentTemplate = true
            }
        }
        .task(id: file) {
            sceneState.file = file
        }
        .environment(sceneState)
    }
}
