//
//  SpotifyCloneApp.swift
//  SpotifyClone
//
//  Created by Gabriel on 8/30/21.
//
import SwiftUI

@main
struct SpotifyCloneApp: App {
    var spotifyRemoteDelegate = SpotifyRemoteDelegate()


    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    let SpotifyClientID = YourSensitiveData.clientID

    var accessToken: String? = nil

    lazy var configuration = SPTConfiguration(
        clientID: SpotifyClientID,
        redirectURL: SpotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = spotifyRemoteDelegate.accessToken
        appRemote.delegate = spotifyRemoteDelegate
        return appRemote
    }()


    var body: some Scene {
      
        let mainViewModel = MainViewModel()

        WindowGroup {
            MainView(mainViewModel: mainViewModel)
                .onOpenURL { url in
                    let parameters = appRemote.authorizationParameters(from: url)

                    if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
                        spotifyRemoveDelegate.appRemote.connectionParameters.accessToken = access_token
                        self.accessToken = access_token
                    } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
                        print("Error: \(error_description)")
                    }
                }
        }
    }
}

