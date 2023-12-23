//
//  AuthScreen.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/13/21.
//

import SwiftUI

struct AuthScreen: View {
  @StateObject var mainViewModel: MainViewModel
  @State var isShowingAuthWebView: Bool = false


  var body: some View {
    GeometryReader { geometry in
      ZStack {
        LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9989100099, green: 0.7796276808, blue: 0.7581660151, alpha: 1)), Color(#colorLiteral(red: 0.4884283543, green: 0.7279313803, blue: 0.7800245881, alpha: 1))]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .ignoresSafeArea()
        VStack {
          Spacer()
          if isShowingAuthWebView {
            ProgressView()
              .withSpotifyStyle()
          } else {
            RoundedButton(text: "Sign in with Spotify") {
              self.isShowingAuthWebView = true
              mainViewModel.authorize()
            }.padding(.horizontal, Constants.paddingLarge)
          }
          Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.paddingLarge)
      }
      // .padding(.horizontal, Constants.paddingLarge)
//    }.onAppear(){
//      mainViewModel.authorize()
//      isShowingAuthWebView = true
    }
    .sheet(isPresented: $isShowingAuthWebView, content: {
      AuthSheetView(isShowingSheetView: $isShowingAuthWebView)
    })
  }

  fileprivate struct RoundedButton: View {
    var text: String
    var isFilled = true
    var isStroked = false
    var icon: Image?
    var action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack {
          if icon != nil {
            icon!
              .resizable()
              .renderingMode(.template)
              .scaledToFit()
              .padding(.vertical, 10)
          }
          Text(text)
            .font(.avenir(.heavy, size: Constants.fontXSmall))
            .tracking(1.5)
        }
        .padding(.horizontal, Constants.paddingSmall)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
      }
      .background( isFilled ? Capsule().foregroundColor(Color(.spotifyDarkGray)) : Capsule().foregroundColor(.white.opacity(0)))
      .background( isStroked ? Capsule().strokeBorder(Color.spotifyDarkGray) : Capsule().strokeBorder(Color.white.opacity(0)))
    }
  }

}
