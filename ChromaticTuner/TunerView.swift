//
//  TunerView.swift
//  ChromaticTuner
//
//  Created by David Nyman on 6/30/25.
//

import SwiftUI

struct TunerView: View {
    @StateObject private var vm = TunerViewModel()

    var body: some View {
        VStack(spacing: 50) {
            Text(vm.noteName)
                .font(.system(size: 120, weight: .bold))
            ZStack {
                Circle()
                    .stroke(lineWidth: 3)
                    .frame(width: 250, height: 250)
                Rectangle()
                    .frame(width: 3, height: 120)
                    .offset(y: -60)
                    .rotationEffect(.degrees(vm.centsOff * 1.8))
            }
            Button(action: vm.start) {
                Text("Start Tuner")
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background($vm.didReceiveAudio ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView()
    }
}
