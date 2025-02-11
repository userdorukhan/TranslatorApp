import SwiftUI

struct LanguageSelectionView: View {
    @Binding var selectedLanguage: String
    @Binding var showLanguageSelection: Bool
    @Binding var showMainMenu: Bool
    @Binding var showTranslatorScreen: Bool
    @Binding var showTranslateScreen: Bool

    @State private var durationTime = 0.4


    var body: some View {
        VStack {
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

            HStack {
                Spacer()
                Text("Select Language")
                    .font(.custom("AvenirNext-Bold", size: 24))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 20) {
                    LanguageButton(language: "Arabic", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection, showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "Azerbaijani", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection, showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "Chinese", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "Dutch", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "English", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "Spanish", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "French", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "German", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "Italian", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "Japanese", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                    LanguageButton(language: "Turkish", selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct LanguageButton: View {
    let language: String
    @Binding var selectedLanguage: String
    @Binding var showLanguageSelection: Bool
    @Binding var showTranslatorScreen: Bool
    @Binding var showTranslateScreen: Bool

    @State private var durationTime = 0.4


    var body: some View {
        Button(action: {
            selectedLanguage = language
            withAnimation(.easeInOut(duration: 0.4)) {
                showLanguageSelection = false
                showTranslatorScreen = true
                showTranslateScreen = false
            }
        }) {
            Text(language)
                .font(.custom("AvenirNext-Bold", size: 20))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedLanguage == language ? Color.blue : Color.gray)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct LanguageSelectionView_Previews: PreviewProvider {
    @State static var selectedLanguage = "Turkish"
    @State static var showLanguageSelection = true
    @State static var showMainMenu = false
    @State static var showTranslatorScreen = true
    @State static var showTranslateScreen = false


    static var previews: some View {
        LanguageSelectionView(selectedLanguage: $selectedLanguage, showLanguageSelection: $showLanguageSelection, showMainMenu: $showMainMenu,showTranslatorScreen: $showTranslatorScreen, showTranslateScreen: $showTranslateScreen)
    }
}
