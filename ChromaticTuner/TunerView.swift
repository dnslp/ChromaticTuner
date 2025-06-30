//
//  TunerView.swift
//  ChromaticTuner
//
//  Created by David Nyman on 6/30/25.
//

import SwiftUI

import Combine // Required for ObservableObject and Published

// Define TunerSubject as an ObservableObject
class TunerSubject: ObservableObject {
    // Example property that might be used to control view state
    @Published var detectedPitch: String = "C"
    @Published var isTuningActive: Bool = false // A boolean property for conditions
}

struct TunerView: View {
    // Use @StateObject to manage the lifecycle of TunerSubject
    @StateObject private var subject = TunerSubject()

    var body: some View {
        VStack {
            Text("TunerView")
            Text("Detected Pitch: \(subject.detectedPitch)")
            // Example of how to use a boolean property from the subject in a condition:
            if subject.isTuningActive {
                Text("Tuning is active")
            } else {
                Text("Tuning is not active")
            }
            Button(subject.isTuningActive ? "Stop Tuning" : "Start Tuning") {
                subject.isTuningActive.toggle()
            }
        }
    }
}

#Preview {
    TunerView()
}
