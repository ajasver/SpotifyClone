//
//  BottomBar.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/1/21.
//

import SwiftUI

// TODO: Get the real currently played media.

struct BottomBar: View {
  @StateObject var mainVM: MainViewModel
  @EnvironmentObject var audioManager: RemoteAudio

  private var lowestResImageURL: String {
    if let media = mainVM.currentTrack {
      if media.lowResImageURL != "" {
        return media.lowResImageURL ?? ""
      } else {
        return media.imageURL
      }
    } else {
      return ""
    }
  }
  private var songName: String { mainVM.currentTrack?.title ?? "" }
  private var authorName: [String] { mainVM.currentTrack?.authorName ?? [] }


  var body: some View {
    let cover =
    ZStack {
      VStack(spacing: 0) {
        Rectangle()
          .fill(Color.spotifyXLightGray)
          .frame(height: 3)
        HStack {
          HStack {
            Rectangle()
              .foregroundColor(.spotifyMediumGray)
              .overlay(RemoteImage(urlString: lowestResImageURL))
              .frame(width: 60)
            VStack(alignment: .leading) {
              Text(songName).font(.avenir(.medium, size: Constants.fontSmall))
                .frame(maxWidth: .infinity, alignment: .topLeading)
              Text(authorName.joined(separator: ", ")).font(.avenir(.medium, size: Constants.fontXSmall))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .opacity(Constants.opacityStandard)
            }
            .padding(.vertical, 10)
          }
          Spacer()
          HStack(spacing: 30) {
            Image("devices")
              .resizeToFit()
              .frame(width: 25, height: 25)
              .opacity(Constants.opacityStandard)
            PlayStopButton(media: mainVM.currentTrack!, size: 60).environmentObject(audioManager)
              .fixedSize()
        }
        }
        .frame(height: 80)
        .background(Color.spotifyLightGray)
        Rectangle()
          .fill(Color.spotifyDarkGray)
          .ignoresSafeArea()
          .frame(height: 0.3)

      }
    }
  }
}

private struct BottomNavigationBar: View {
  @StateObject var mainVM: MainViewModel

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        HStack {
          BottomNavigationItem(mainVM: mainVM,
                               assignedPage: .home,
                               itemName: "Home",
                               iconWhenUnselected: Image("home-unselected"),
                               iconWhenSelected: Image("home-selected"))
          BottomNavigationItem(mainVM: mainVM,
                               assignedPage: .search,
                               itemName: "Search",
                               iconWhenUnselected: Image("search-unselected"),
                               iconWhenSelected: Image("search-selected"))
          BottomNavigationItem(mainVM: mainVM,
                               assignedPage: .myLibrary,
                               itemName: "My Library",
                               iconWhenUnselected: Image("library-unselected"),
                               iconWhenSelected: Image("library-selected"))
        }
        .frame(height: 60)
        .background(Color.spotifyLightGray)

        // To fill the bottom safe area
        Rectangle()
          .fill(Color.spotifyLightGray)
          .ignoresSafeArea()
          .frame(height: 0)
      }
    }
  }

  private struct BottomNavigationItem: View {
    @StateObject var mainVM: MainViewModel
    var assignedPage: MainViewModel.Page

    var itemName: String
    var iconWhenUnselected: Image
    var iconWhenSelected: Image

    var thisPageIsTheCurrentPage: Bool {
      mainVM.currentPage == assignedPage
    }

    var body: some View {
      VStack(alignment: .center, spacing: 5) {
        Spacer()
        buildIcon()
        Text(itemName).font(.avenir(.medium, size: Constants.fontXXSmall))
      }.frame(maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
      .onTapGesture {
        mainVM.currentPage = assignedPage
        if mainVM.currentPage == assignedPage {
          mainVM.currentPageWasRetapped = true
        }
      }
      .foregroundColor(thisPageIsTheCurrentPage ? .white : .white.opacity(Constants.opacityHigh))
    }

    func buildIcon() -> some View {
      var icon: Image

      if thisPageIsTheCurrentPage {
        icon = iconWhenSelected
      } else {
        icon = iconWhenUnselected
      }

      return icon.resizeToFit()
        .colorMultiply(thisPageIsTheCurrentPage ? .white : .white.opacity(Constants.opacityHigh))
        .frame(width: 25)
    }
  }

}
