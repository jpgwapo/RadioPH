import SwiftUI

@main
struct RadioPHApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environment(appModel)
                .preferredColorScheme(appModel.isDarkMode ? .dark : .light)
        }
    }
}
