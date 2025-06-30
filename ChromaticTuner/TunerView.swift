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
    @Published var pitchName: String = "--"
    @Published var frequency: Double = 0.0
    @Published var distanceToTarget: Double = 0.0
    @Published var detectionThreshold: Double = 0.1
    @Published var isTuningActive: Bool = false {
        didSet {
            if isTuningActive {
                startSimulation()
            } else {
                stopSimulation()
            }
        }
    }

    private var simulationTimer: Timer?
    private let pitches = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
    private let baseFrequency = 440.0 // A4

    func startSimulation() {
        stopSimulation() // Ensure no multiple timers
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Simulate a new pitch
            self.pitchName = self.pitches.randomElement() ?? "C"

            // Simulate frequency (e.g., A4 +/- some cents)
            // For simplicity, let's just vary it a bit around a central point.
            // A more realistic simulation would map pitchName to a base frequency.
            self.frequency = self.baseFrequency + Double.random(in: -5.0...5.0)

            // Simulate distance to target (how sharp or flat)
            // Randomly make it slightly off, or perfectly in tune
            let randomDistance = Double.random(in: -0.5...0.5)
            self.distanceToTarget = randomDistance
        }
    }

    func stopSimulation() {
        simulationTimer?.invalidate()
        simulationTimer = nil
        // Optionally reset values when stopping
        // pitchName = "--"
        // frequency = 0.0
        // distanceToTarget = 0.0
    }

    deinit {
        stopSimulation()
    }
}

struct TunerView: View {
    // Use @StateObject to manage the lifecycle of TunerSubject
    @StateObject private var subject = TunerSubject()

    var body: some View {
        ZStack { // Use ZStack to allow background material to span the whole screen
            // Potentially a Color or Gradient background for the whole view if desired
            // For now, let the system background show through the material

            VStack(spacing: 20) {
                Text(subject.pitchName)
                    .font(.system(size: 90, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary.opacity(0.85))
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 3)
                    .animation(.easeInOut(duration: 0.2), value: subject.pitchName)


                Text("\(subject.frequency, specifier: "%.1f") Hz")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .animation(.easeInOut(duration: 0.2), value: subject.frequency)

                // Visual Tuning Indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.regularMaterial) // Background for the indicator area
                        .frame(height: 60)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 3)

                    // Central "in-tune" line
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 2, height: 50)

                    // Indicator bar that moves and changes color
                    // For simplicity, this example bar will change color based on how close to target.
                    // A more advanced version could move a needle or shift this bar.
                    HStack {
                        Spacer()
                        Rectangle() // This represents the "current pitch" marker
                            .fill(indicatorColor())
                            .frame(width: 10, height: 50)
                            .offset(x: CGFloat(subject.distanceToTarget) * 50) // Max offset 50 points left/right
                            .animation(.easeInOut, value: subject.distanceToTarget)
                        Spacer()
                    }

                    // Alternative: A simpler color-changing bar without movement
                    /*
                    RoundedRectangle(cornerRadius: 10)
                        .fill(indicatorColor())
                        .frame(width: 200, height: 20)
                        .animation(.easeInOut, value: subject.distanceToTarget)
                    */
                }
                .frame(height: 60) // Ensure ZStack itself has a frame


                VStack(alignment: .leading) {
                    Text("Sensitivity: \(subject.detectionThreshold, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Slider(value: $subject.detectionThreshold, in: 0.01...0.5) {
                        Text("Threshold")
                    }
                    .tint(.accentColor) // Use accent color for slider
                }
                .padding()
                .background(.thinMaterial) // Material background for this section
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)


                Button(subject.isTuningActive ? "Stop Listening" : "Start Listening") {
                    subject.isTuningActive.toggle()
                }
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(.ultraThinMaterial) // Material for button
                .foregroundColor(.accentColor)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 5)

            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.thinMaterial) // Apply material to the main ZStack background
        .edgesIgnoringSafeArea(.all) // Extend material to screen edges
    }

    // Helper function to determine indicator color
    private func indicatorColor() -> Color {
        let tuningThreshold = 0.1 // How close to be considered "in tune"
        if abs(subject.distanceToTarget) < tuningThreshold {
            return .green
        } else if subject.distanceToTarget < 0 {
            return .red // Flat
        } else {
            return .orange // Sharp (using orange to differentiate from very flat red)
        }
    }
}

#Preview {
    TunerView()
}
