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
    @State private var audioEngineRunning = false
    @State private var isMeasurementMode = false
    
    private let engine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    let session = AVAudioSession.sharedInstance()

    var body: some View {
        VStack {

            // Google microphone icon
            Image(systemName: "mic")
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(.bottom, 30)
            
            // Start Button
            Button(action: {
                audioEngineRunning ? engine.stop() : startAudio()
                audioEngineRunning.toggle()
            }) {
                Text(audioEngineRunning ? "Stop Audio" : "Start Audio")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(audioEngineRunning ? Color.red : Color.green)
            .cornerRadius(10)
            .padding(.bottom, 10)

            // Crush Button
            Button(action: {
                toggleMeasurementMode()
            }) {
                Text("Crush")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
            }
            .background(!audioEngineRunning ? Color.gray : (isMeasurementMode ? Color.gray : Color.blue))
            .cornerRadius(10)
        }
    }
    
    func startAudio() {
        
        // Connect the input to the mixer, then the mixer to the output
        engine.attach(mixer)
        mixer.outputVolume = 0.5
        engine.connect(engine.inputNode, to: mixer, format: engine.inputNode.inputFormat(forBus: 0))
        engine.connect(mixer, to: engine.outputNode, format: engine.inputNode.inputFormat(forBus: 0))
        
        // Set category, buffer, and start engine
        do {
            try session.setCategory(.playAndRecord)
            try session.setPreferredIOBufferDuration(0.0005)
            try engine.start()
                        
        } catch { fatalError("Can't start audio engine") }
    }
    
    func toggleMeasurementMode() {
        do {
            
            // Check if the audio engine is running before attempting to set the mode
            if audioEngineRunning {
                
                // Toggle state and set mode based on state
                isMeasurementMode.toggle()
                try session.setMode(isMeasurementMode ? .measurement : .default)
                
                // Decrease volume if in default mode to compensate for auto-leveling, otherwise reset to normal
                mixer.outputVolume = isMeasurementMode ? 1 : 0.5
            }
        } catch {
            print("Failed to change mode")
        }
    }
}


