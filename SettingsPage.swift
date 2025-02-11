import SwiftUI

struct SettingsPage: View {
    @Binding var showSettings: Bool
    @Binding var showMainMenu: Bool

    @State private var selectedVoice = "Female"
    private let voices = ["Male", "Female"]
    @State private var defaultLanguage = UserDefaults.standard.string(forKey: "defaultLanguage") ?? "English"
    private let languages = ["English", "Spanish", "Turkish", "French", "German"] // Add other languages as needed

    @EnvironmentObject var userAuth: UserAuth

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSettings = false
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

            Text("Settings")
                .font(.largeTitle)
                .foregroundColor(.white)

            HStack {
                Text("Choose Voice")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)

            Picker("Choose Voice", selection: $selectedVoice) {
                ForEach(voices, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onChange(of: selectedVoice, perform: { value in
                updateVoiceSetting()
            })

            HStack {
                Text("Default Language")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)

            Picker("Default Language", selection: $defaultLanguage) {
                ForEach(languages, id: \.self) {
                    Text($0)
                }
            }
            .padding(.horizontal)
            .frame(height: 40)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .onChange(of: defaultLanguage) { newValue in
                UserDefaults.standard.set(newValue, forKey: "defaultLanguage")
            }

            Spacer()

            Button(action: {
                userAuth.logout()
            }) {
                Text("Logout")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(5)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            // Set default value if not already set
            if UserDefaults.standard.string(forKey: "selectedVoice") == nil {
                UserDefaults.standard.set("Female", forKey: "selectedVoice")
                selectedVoice = "Female"
            } else {
                selectedVoice = UserDefaults.standard.string(forKey: "selectedVoice") ?? "Female"
            }
            updateVoiceSetting()
        }
    }

    private func updateVoiceSetting() {
        if selectedVoice == "Male" {
            // Set voice to "echo"
            UserDefaults.standard.set("echo", forKey: "voiceType")
        } else {
            // Set voice to "alloy"
            UserDefaults.standard.set("alloy", forKey: "voiceType")
        }
        UserDefaults.standard.set(selectedVoice, forKey: "selectedVoice")
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage(showSettings: .constant(true), showMainMenu: .constant(false))
            .environmentObject(UserAuth())
    }
}
