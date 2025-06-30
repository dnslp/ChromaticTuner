//
//  TunerViewModel.swift
//  ChromaticTuner
//
//  Created by David Nyman on 6/30/25.
//

import Foundation
import Combine

@MainActor
class TunerViewModel: ObservableObject {
    @Published var detectedPitch: Double = 0
    @Published var noteName: String = "--"
    @Published var centsOff: Double = 0
    private let detector = MicrophonePitchDetector()
    private var cancellables = Set<AnyCancellable>()

    init() {
        detector.$pitch
            .sink { [weak self] freq in
                self?.process(freq)
            }
            .store(in: &cancellables)
    }

    func start() {
        Task {
            do {
                try await detector.activate()
            } catch {
                print("⚠️ Mic error:", error)
            }
        }
    }

    private func process(_ freq: Double) {
        detectedPitch = freq
        guard freq > 0 else {
            noteName = "--"; centsOff = 0; return
        }
        let midi  = 69 + 12 * log2(freq / 440)
        let rounded = Int(round(midi))
        centsOff = (midi - Double(rounded)) * 100

        let idx = (rounded % 12 + 12) % 12
        let names = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
        noteName = names[idx]
    }
}
