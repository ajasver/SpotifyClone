import Foundation

class SpotifyRemoteDelegate: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, ObservableObject {
    
    @Published var state: SpotifyRemoteState = .disconnected
    @Published var playerState: SPTAppRemotePlayerState?

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            self.playerState = result as? SPTAppRemotePlayerState
        })
        self.state = .connected
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        self.state = .disconnected
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        self.state = .failed
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("player state changed")
    }

    enum SpotifyRemoteState {
        case connected
        case disconnected
        case failed
    }
}

