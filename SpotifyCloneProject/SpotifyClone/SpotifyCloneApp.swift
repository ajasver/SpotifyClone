//
//  SpotifyCloneApp.swift
//  SpotifyClone
//
//  Created by Gabriel on 8/30/21.
//
import SwiftUI

@main
class SpotifyCloneApp: App {

  required init(){}

    let spotifyRemoteDelegate = SpotifyRemoteDelegate()

    let SpotifyRedirectURL = !
    let SpotifyClientID = YourSensitiveData.clientID

    var accessToken: String? = nil
    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
        redirectURL: SpotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
      appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = spotifyRemoteDelegate
        return appRemote
    }()


    var body: some Scene {
      
        let mainViewModel = MainViewModel()

        WindowGroup {
            MainView(mainViewModel: mainViewModel)
                .onOpenURL { url in
                  let parameters = self.appRemote.authorizationParameters(from: url)

                    if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
                      self.appRemote.connectionParameters.accessToken = access_token
                      self.accessToken = access_token
                    } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
                        print("Error: \(error_description)")
                    }
                }
        }
    }
}

