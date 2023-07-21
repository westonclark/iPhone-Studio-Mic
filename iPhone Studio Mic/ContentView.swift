//
//  ContentView.swift
//  iPhone Studio Mic
//
//  Created by Weston Clark on 7/19/23.
//

import SwiftUI
import AVFoundation
import Accelerate
//import AVKit

struct ContentView: View {
    var body: some View {
        VStack {
            AudioRoutingView()
                .preferredColorScheme(.dark)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AudioRoutingView: View {
    @ObservedObject private var audioHandler = AudioHandler()
    @State private var isAudioEngineRunning = false // Add a state variable to track the engine's state

    var body: some View {
            VStack {
//                Text("iPhone Studio Mic")
//                    .font(.title)
//                    .padding()
                
                Button("Start Audio") {
                    if !isAudioEngineRunning { // Check if the engine is not running
                        audioHandler.setupAudioSession()
                        startAudioEngine(engine: audioHandler.engine)
                        isAudioEngineRunning = true // Set the flag to true when starting the engine
                    }
                }
                                    .font(.title)

                
                AudioMeter(level: $audioHandler.audioLevel) // Pass the binding to AudioMeter
                    .padding(25)

            }
        }

    private func startAudioEngine(engine: AVAudioEngine) {
            // Create an audio input node to capture microphone data
            let audioInputNode = engine.inputNode

            // Set up a tap on the audio input node to process microphone data
            audioInputNode.installTap(onBus: 0, bufferSize: 128, format: audioInputNode.outputFormat(forBus: 0)) { (buffer, _) in
                // Process the audio buffer to calculate the audio level
                let floatBuffer = buffer.floatChannelData![0]
                let bufferLength = UInt32(buffer.frameLength)

                var rms: Float = 0.0
                vDSP_rmsqv(floatBuffer, 1, &rms, vDSP_Length(bufferLength))

                // Update the audioLevel property on the main thread
                DispatchQueue.main.async {
                    audioHandler.audioLevel = rms
                }
            }

            // Connect the input node to the output node to route audio to headphones
            let audioOutputNode = engine.outputNode
            engine.connect(audioInputNode, to: audioOutputNode, format: audioInputNode.outputFormat(forBus: 0))

            // Start the audio engine
            do {
                try engine.start()
            } catch {
                fatalError("Failed to start the audio engine: \(error)")
            }
        }
    }

struct AudioMeter: View {
    @Binding var level: Float // Update the property to a Binding<Float>

    var body: some View {
        VStack {
//            Text("Audio Level: \(Int(level * 100))%")
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 200)
                .foregroundColor(.gray)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .frame( height: CGFloat(level * 200))
                        .foregroundColor(.green)
                )
        }
    }
}

class AudioHandler: ObservableObject {
    @Published var audioLevel: Float = 0.0

    let engine = AVAudioEngine()
    
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord)
            try audioSession.setActive(true)
        } catch {
            fatalError("Failed to configure audio session: \(error)")
        }
    }
}
