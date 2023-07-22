import SwiftUI
import AVFoundation
import Accelerate

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
    @State private var audioEngineRunning = false // Updated variable name to follow Swift convention

    var body: some View {
        VStack {
            Image(systemName: "mic") // Google microphone icon
                .resizable()
                .frame(width: 50, height: 60)
                .foregroundColor(.white) // Set the icon color to white
                .padding(.bottom, 40)
            
            Button(action: {
                if audioEngineRunning {
                    stopAudioEngine(engine: audioHandler.engine)
                    audioEngineRunning = false // Set the flag to false when stopping the engine
                } else {
                    audioHandler.setupAudioSession()
                    startAudioEngine(engine: audioHandler.engine)
                    audioEngineRunning = true // Set the flag to true when starting the engine
                }
            }) {
                Text(audioEngineRunning ? "Stop Audio" : "Start Audio")
                    .font(.title)
                    .foregroundColor(.white) // Set the button text color to white
                    .padding()
            }
            .background(audioEngineRunning ? Color.red : Color.green) // Set the button background color based on state
            .cornerRadius(10)
        }
    }

    private func startAudioEngine(engine: AVAudioEngine) {
            // Create an audio input node to capture microphone data
            let audioInputNode = engine.inputNode

            // Set up a tap on the audio input node to process microphone data
            audioInputNode.installTap(onBus: 0, bufferSize: 64, format: audioInputNode.outputFormat(forBus: 0)) { (buffer, _) in
                
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
    private func stopAudioEngine(engine: AVAudioEngine) {
            engine.stop() // Stop the audio engine
            
            // Remove the tap on the input node to stop processing microphone data
            let audioInputNode = engine.inputNode
            audioInputNode.removeTap(onBus: 0)
        }
    
    }

class AudioHandler: ObservableObject {
//    @Published var audioLevel: Float = 0.0

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
