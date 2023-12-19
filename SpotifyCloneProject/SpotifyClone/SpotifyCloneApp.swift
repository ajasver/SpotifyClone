import SwiftUI


@main
struct SpotifyCloneApp: App {

    @StateObject private var mainViewModel = MainViewModel()
    var body: some Scene {
      let mainViewModel = MainViewModel()
        WindowGroup {
            MainView(mainViewModel: mainViewModel)
                .onAppear {
                    self.mainViewModel.connect()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    self.mainViewModel.disconnect()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    self.mainViewModel.connect()
                }
                .onOpenURL { url in
                    self.mainViewModel.handleURL(url)
                }
        }
    }

}
