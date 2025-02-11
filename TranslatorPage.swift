import SwiftUI
import AVFoundation

struct TranslatorView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var transcribedText = ""
    @State private var chatResponse = ""
    @State private var audioPlayer: AVAudioPlayer?
    private let apiManager = APIManager()
    @Binding var selectedLanguage: String
    @Binding var showLanguageSelection: Bool
    @State private var durationTime = 0.4
    private let defaultLanguage = UserDefaults.standard.string(forKey: "defaultLanguage") ?? "English"
    @State private var currentTargetLanguage: String?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: durationTime)) {
                        showLanguageSelection = true
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
                .padding(.leading, 20)
                .padding(.top, 20)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)

                Spacer()

                Text(currentTargetLanguage ?? selectedLanguage)
                    .font(.custom("AvenirNext-Bold", size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            }

            Spacer()

            Text(audioRecorder.isRecording ? "Recording..." : "Press to Record")
                .font(.custom("AvenirNext-Bold", size: 24))
                .foregroundColor(audioRecorder.isRecording ? .red : .blue)

            Button(action: {
                if self.audioRecorder.isRecording {
                    self.audioRecorder.stopRecording()
                    self.transcribeAudio()
                } else {
                    self.audioRecorder.startRecording()
                }
            }) {
                Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(audioRecorder.isRecording ? .red : .blue)
            }
            .padding()

            ScrollView {
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Transcribed Text:")
                            .font(.custom("AvenirNext-Bold", size: 20))
                            .foregroundColor(.white)
                        Text(transcribedText)
                            .font(.custom("AvenirNext-Regular", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: geometry.size.width * 0.9)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Chat Response:")
                            .font(.custom("AvenirNext-Bold", size: 20))
                            .foregroundColor(.white)
                        Text(chatResponse)
                            .font(.custom("AvenirNext-Regular", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: geometry.size.width * 0.9)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            self.currentTargetLanguage = selectedLanguage
        }
    }

    func transcribeAudio() {
        let audioURL = self.audioRecorder.getAudioFileURL()
        apiManager.transcribeAudio(audioURL: audioURL) { transcribedText in
            DispatchQueue.main.async {
                self.transcribedText = transcribedText ?? "Transcription failed"
                if let transcribedText = transcribedText {
                    self.sendToChatCompletion(text: transcribedText)
                }
            }
        }
    }

    func sendToChatCompletion(text: String) {
        guard let targetLanguage = currentTargetLanguage else { return }
        apiManager.chatCompletion(with: text, language: targetLanguage) { response in
            DispatchQueue.main.async {
                self.chatResponse = response ?? "Failed to get response from chat completion"
                if let response = response {
                    self.convertTextToSpeech(text: response)
                    self.toggleTargetLanguage()
                }
            }
        }
    }

    func toggleTargetLanguage() {
        currentTargetLanguage = (currentTargetLanguage == selectedLanguage) ? defaultLanguage : selectedLanguage
    }

    func convertTextToSpeech(text: String) {
        apiManager.textToSpeech(text: text) { audioURL in
            guard let audioURL = audioURL else { return }
            DispatchQueue.main.async {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                    self.audioPlayer?.play()
                } catch {
                    print("Failed to play audio: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    TranslatorView(selectedLanguage: .constant("Turkish"), showLanguageSelection: .constant(false))
}
