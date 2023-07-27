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
    
    private let engine = AVAudioEngine()
    
    var body: some View {
        VStack {
            Image(systemName: "mic") // Google microphone icon
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(.bottom, 60)
            
            Button(action: {
                if audioEngineRunning {
                    stopAudio()
                    audioEngineRunning = false
                } else {
                    startAudio()
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
    
    func startAudio() {
        let session = AVAudioSession.sharedInstance()
        
        engine.connect(engine.inputNode, to: engine.outputNode, format: engine.inputNode.inputFormat(forBus: 0))
        
        do {
            try session.setCategory(.playAndRecord)
            try session.setPreferredIOBufferDuration(0.0005)
//            try session.setMode(.measurement)
            try engine.start()
//            print(session.ioBufferDuration)
        } catch { fatalError("Can't start audio engine") }
    }
    
    func stopAudio() {
        engine.stop()
    }
    
}


