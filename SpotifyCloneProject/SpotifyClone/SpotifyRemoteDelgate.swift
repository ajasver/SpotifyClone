import Foundation

class SpotifyRemoteDelegate: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("connected")
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("failed")
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("player state changed")
    }
}

