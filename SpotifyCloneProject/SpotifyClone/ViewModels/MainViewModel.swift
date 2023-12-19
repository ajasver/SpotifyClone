//
//  MainViewModel.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/14/21.
//

import Foundation

class MainViewModel: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, ObservableObject {

  private var api = MainViewModelAPICalls()
  @Published private(set) var authKey: AuthKey?
  @Published var currentPage: Page = .home
  @Published var currentPageWasRetapped = false
  @Published private(set) var homeScreenIsReady = false
  @Published var showBottomMediaPlayer = true
  @Published private(set) var currentUserProfileInfo: SpotifyModel.CurrentUserProfileInfo?
  @Published var state: SpotifyRemoteState = .disconnected
  @Published var playerState: SPTAppRemotePlayerState?
  @Published var playURI   = ""

  static private let kAccessTokenKey = "access-token-key"
  private let redirectUri = YourSensitiveData.clientRedirectURL!
  private let clientIdentifier = YourSensitiveData.clientID

  private var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
      didSet {
          let defaults = UserDefaults.standard
          defaults.set(accessToken, forKey: MainViewModel.kAccessTokenKey)
      }
  }

  lazy var appRemote: SPTAppRemote = {
      let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
      let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
      appRemote.connectionParameters.accessToken = self.accessToken
      appRemote.delegate = self
      return appRemote
  }()

  func getCurrentUserInfo() {
    api.getCurrentUserInfo(with: authKey!.accessToken) { [unowned self] userInfo in
      self.currentUserProfileInfo = userInfo
    }
  }
  func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            self.playerState = result as? SPTAppRemotePlayerState
        })
        self.state = .connected
        homeScreenIsReady = true
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        self.state = .disconnected
        homeScreenIsReady = false
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

  func connect() {
    if let _ = appRemote.connectionParameters.accessToken {
        appRemote.connect()
    }
  }

  func disconnect() {
    if appRemote.isConnected {
        appRemote.disconnect()
    }
  }

  func authorize() {
    appRemote.authorizeAndPlayURI(playURI)
  }

  func handleURL(_ url: URL) {
      let parameters = appRemote.authorizationParameters(from: url)

      if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
          appRemote.connectionParameters.accessToken = access_token
          self.accessToken = access_token
      } else if let _ = parameters?[SPTAppRemoteErrorDescriptionKey] {
          // Show the error
      }
  }

  enum Page {
    case home
    case search
    case myLibrary
  }

}
