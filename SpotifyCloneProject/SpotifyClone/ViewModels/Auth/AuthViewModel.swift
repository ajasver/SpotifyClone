//
//  AuthViewModel.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/13/21.


import Foundation

class AuthViewModel: ObservableObject {
  var mainViewModel: MainViewModel
  @Published var isLoading = true
  @Published var finishedAuthentication = false
  @Published var authKeyIsAvailable = false

  init(mainViewModel: MainViewModel) {
    self.mainViewModel = mainViewModel
  }

  static private var apiAuth = APIAuthentication()
  private var authKey: AuthKey?

  // Put your API id and secret inside YourSensitiveData and add it to .gitignore
  // How do I do I generate new api keys? Check APIAuthentication.swift
  static private var clientID = YourSensitiveData.clientID
  static private var clientSecret = YourSensitiveData.clientSecret

  // To know more about what all those variables are, check APIAuthentication.swift
  static private var scope = getScopesUsing([.userReadRecentlyPlayed, .userTopRead, .userReadPlaybackPosition,
                                             .userLibraryRead, .userLibraryModify, .userFollowRead, .userFollowModify,
                                             .playlistModifyPublic, .playlistModifyPrivate, .playlistReadPrivate])
  
  
  static private var redirectURI = "https://www.github.com"


  static var url = apiAuth.getAuthURL(clientID: clientID, scope: scope, redirectURI: redirectURI)

  private static func getScopesUsing(_ scopesList: [AuthScope]) -> String {
    let scopesListRawValues = scopesList.map { $0.rawValue }
    return scopesListRawValues.joined(separator: "+")
  }
}
