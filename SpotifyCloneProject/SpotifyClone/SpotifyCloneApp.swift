import SwiftUI


@main
struct SpotifyCloneApp: App {

    var body: some Scene {
      let mainViewModel = MainViewModel()
        WindowGroup {
            MainView(mainViewModel: mainViewModel)
                .onAppear {
                    mainViewModel.connect()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    mainViewModel.disconnect()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    mainViewModel.connect()
                }
                .onOpenURL { url in
                    mainViewModel.handleURL(url)
                }
        }
    }

}

