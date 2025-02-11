import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var transcribedText = ""
    @State private var chatResponse = ""
    @State private var audioPlayer: AVAudioPlayer?
    private let apiManager = APIManager()
    @State private var selectedLanguage = "English"
    @State private var showMainMenu = true
    @State private var showLanguageSelection = false
    @State private var showTranslateScreen = false
    @State private var showTranslatorScreen = false
    @State private var showSettings = false
    @State private var durationTime = 0.4
    @EnvironmentObject var userAuth: UserAuth

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Ensures the background is always black

            if !userAuth.isLoggedIn {
                LoginPage(userAuth: userAuth)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .animation(.easeInOut(duration: durationTime), value: userAuth.isLoggedIn)
            } else if showMainMenu {
                MainMenuPage(showMainMenu: $showMainMenu, showLanguageSelection: $showLanguageSelection, showTranslateScreen: $showTranslateScreen, showTranslatorScreen: $showTranslatorScreen, showSettings: $showSettings)
                    .transition(.move(edge: .leading)) // Move from right to left
                    .animation(.easeInOut(duration: durationTime), value: showMainMenu)
            } else if showLanguageSelection {
                LanguageSelectionView(selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection, showMainMenu: $showMainMenu, showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    .transition(.move(edge: showTranslatorScreen ? .leading : .trailing))
                    .animation(.easeInOut(duration: durationTime), value: showLanguageSelection)
            } else if showTranslateScreen {
                TranslateScreenView(showMainMenu: $showMainMenu)
                    .transition(.move(edge: .trailing)) // Move from left to right
                    .animation(.easeInOut(duration: durationTime), value: showTranslateScreen)
            } else if showTranslatorScreen {
                TranslatorView(selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection)
                    .transition(.move(edge: .trailing)) // Move from left to right
                    .animation(.easeInOut(duration: durationTime), value: showTranslatorScreen)
            } else if showSettings {
                SettingsPage(showSettings: $showSettings, showMainMenu: $showMainMenu)
                    .transition(.move(edge: .trailing)) // Move from left to right
                    .animation(.easeInOut(duration: durationTime), value: showSettings)
            }
        }
        .edgesIgnoringSafeArea(.top) // Ignore top safe area to prevent the dynamic island from blocking the content
    }

    private func resetState() {
        showMainMenu = true
        showLanguageSelection = false
        showTranslateScreen = false
        showTranslatorScreen = false
        showSettings = false
    }
}

#Preview {
    ContentView().environmentObject(UserAuth())
}
