//
//  MainViewModel.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/14/21.
//

import Foundation

class MainViewModel: NSObject, SPTAppRemoteDelegate, ObservableObject {

  private var api = MainViewModelAPICalls()
  @Published var currentPage: Page = .home
  @Published var currentPageWasRetapped = false
  @Published private(set) var homeScreenIsReady = false
  @Published var showBottomMediaPlayer = true
  @Published private(set) var currentUserProfileInfo: SpotifyModel.CurrentUserProfileInfo?
  @Published var state: SpotifyRemoteState = .disconnected
  @Published var playerState: SPTAppRemotePlayerState?
  @Published var playURI   = ""
  @Published var currentTrack: SpotifyModel.MediaItem?
  @Published var audioManager: RemoteAudio? = nil

  static private let kAccessTokenKey = "access-token-key"
  private let redirectUri = YourSensitiveData.clientRedirectURL!
  private let clientIdentifier = YourSensitiveData.clientID

  @Published private(set) var accessToken: String?

  lazy var appRemote: SPTAppRemote = {
      let configuration = SPTConfiguration(
        clientID: self.clientIdentifier,
        redirectURL: self.redirectUri
      )
      let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
      appRemote.connectionParameters.accessToken = self.accessToken
      appRemote.delegate = self
      return appRemote
  }()

  func getCurrentUserInfo() {
    api.getCurrentUserInfo(with: accessToken!) { [unowned self] userInfo in
      self.currentUserProfileInfo = userInfo
    }
  }
  func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
    self.audioManager = RemoteAudio(mainVM: self)
    self.audioManager!.appRemoteConnected()
    self.audioManager!.pause()
    homeScreenIsReady = true
    print("connected!")

    }

  func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        self.state = .disconnected
    self.audioManager!.appRemoteDisconnect()
        homeScreenIsReady = false
      print("disconnected!")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        self.state = .failed
        homeScreenIsReady = false
      print("failed!")
    }

    enum SpotifyRemoteState {
        case connected
        case disconnected
        case failed
    }

  func authorize() {
    appRemote.authorizeAndPlayURI(playURI)
  }

  func updateCurrentPlayingTrack(mediaItem: SpotifyModel.MediaItem) {
    currentTrack = mediaItem
  }

  func disconnect() {
    if appRemote.isConnected {
        appRemote.disconnect()
    }
  }

  func connect() {
    if self.accessToken != nil {
        appRemote.connect()
    }
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
