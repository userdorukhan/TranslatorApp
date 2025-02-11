import SwiftUI

struct TranslateScreenView: View {
    @State private var fromLanguage = "English"
    @State private var toLanguage = "Turkish"
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var isTranslating = false
    private let languages = ["English", "Spanish", "French", "German", "Italian", "Japanese", "Chinese", "Arabic", "Turkish", "Dutch"]
    private let apiManager = APIManager()
    @State private var durationTime = 0.3
    @Binding var showMainMenu: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: durationTime)) {
                        showMainMenu = true
                    }
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)

            Spacer()
                .frame(height: 130) // Adjust this value to decrease the space

            HStack {
                Picker("From", selection: $fromLanguage) {
                    ForEach(languages, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                Button(action: {
                    swap(&fromLanguage, &toLanguage)
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                
                Picker("To", selection: $toLanguage) {
                    ForEach(languages, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                VStack(spacing: 20) {
                    ZStack(alignment: .leading) {
                        if inputText.isEmpty {
                            Text("Enter text to translate")
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 36) // Adjusted padding to move text to the right
                        }
                        TextField("", text: $inputText)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .foregroundColor(.white) // Set the text color to white
                    }
                    .frame(width: geometry.size.width - 40) // Set width based on parent view's size

                    Button(action: translate) {
                        Text(isTranslating ? "Translating..." : "Translate")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Translated Text:")
                            .font(.custom("AvenirNext-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        Text(translatedText)
                            .font(.custom("AvenirNext-Regular", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .frame(width: geometry.size.width - 40) // Set width based on parent view's size
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private func translate() {
        isTranslating = true
        apiManager.translateText(from: fromLanguage, to: toLanguage, text: inputText) { result in
            DispatchQueue.main.async {
                self.translatedText = result ?? "Translation failed"
                self.isTranslating = false
            }
        }
    }
}

struct TranslateScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TranslateScreenView(showMainMenu: .constant(false))
    }
}
