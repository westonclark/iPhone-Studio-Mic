import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        VStack {
            AudioRoutingView()
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
    @State private var audioEngineRunning = false

    var body: some View {
        VStack {
            Image(systemName: "mic") // Google microphone icon
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(.bottom, 60)

            Button(action: {
                if audioEngineRunning {
                    stopAudioEngine(engine: audioHandler.engine)
                    audioEngineRunning = false
                } else {
                    audioHandler.setupAudioSession()
                    startAudioEngine(engine: audioHandler.engine)
                    audioEngineRunning = true
                }
            }) {
                Text(audioEngineRunning ? "Stop Audio" : "Start Audio")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(audioEngineRunning ? Color.red : Color.green)
            .cornerRadius(10)
        }
    }

    private func startAudioEngine(engine: AVAudioEngine) {
        engine.inputNode.installTap(onBus: 0, bufferSize: 0, format: engine.inputNode.outputFormat(forBus: 0)) { (buffer, _) in }
            engine.connect(engine.inputNode, to: engine.outputNode, format: engine.inputNode.outputFormat(forBus: 0))

            do {
                try engine.start()
                print()
            } catch {
                fatalError("Failed to start the audio engine: \(error)")
            }
        }

    private func stopAudioEngine(engine: AVAudioEngine) {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }
    }

class AudioHandler: ObservableObject {
    let engine = AVAudioEngine()

    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord)
//            try audioSession.setMode(.measurement)
            try audioSession.setPreferredIOBufferDuration(0.00005)
            try audioSession.setActive(true)
//            print(audioSession.ioBufferDuration)
        } catch {
            fatalError("Failed to configure audio session: \(error)")
        }
    }
}
