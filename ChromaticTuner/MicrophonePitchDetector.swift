//
//  MicrophonePitchDetector.swift
//  ChromaticTuner
//
//  Created by David Nyman on 6/30/25.
//

import AVFoundation
import Combine
import AudioKit            // core engine
import AudioKitEX          // helpers / extensions
import SoundpipeAudioKit   // for PitchTap

public final class MicrophonePitchDetector: ObservableObject {
    private let engine = AudioEngine()
    private var tracker: PitchTap!
    @Published public var pitch: Double = 0
    @Published public var didReceiveAudio = false

    @MainActor
    public func activate() async throws {
        guard !engine.isRunning else { return }
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .mixWithOthers)
        try AVAudioSession.sharedInstance().setActive(true)
        tracker = PitchTap(engine.input ?? <#default value#>, handler: { freqs, _ in
            if let f = freqs.first {
                Task { @MainActor in
                    self.pitch = Double(f)
                    self.didReceiveAudio = true
                }
            }
        })
        engine.output = engine.input
        try engine.start()
        tracker.start()
    }
}
