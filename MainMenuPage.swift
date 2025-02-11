import SwiftUI

struct MainMenuPage: View {
    @Binding var showMainMenu: Bool
    @Binding var showLanguageSelection: Bool
    @Binding var showTranslateScreen: Bool
    @Binding var showTranslatorScreen: Bool
    @Binding var showSettings: Bool
    @State private var durationTime = 0.4
    @EnvironmentObject var userAuth: UserAuth

    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                withAnimation(.easeInOut(duration: durationTime)) {
                    showMainMenu = false
                    showLanguageSelection = true
                }
            }) {
                Text("Translator")
                    .font(.custom("AvenirNext-Bold", size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)

            Button(action: {
                withAnimation(.easeInOut(duration: durationTime)) {
                    showTranslateScreen = true
                    showMainMenu = false
                    showLanguageSelection = false
                }
            }) {
                Text("Translate")
                    .font(.custom("AvenirNext-Bold", size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showSettings = true
                        showMainMenu = false
                        showTranslateScreen = false
                        showTranslatorScreen = false
                        showLanguageSelection = false
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 30)
                .padding(.trailing, 20)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    MainMenuPage(showMainMenu: .constant(true), showLanguageSelection: .constant(false), showTranslateScreen: .constant(false), showTranslatorScreen: .constant(false), showSettings: .constant(false))
}
