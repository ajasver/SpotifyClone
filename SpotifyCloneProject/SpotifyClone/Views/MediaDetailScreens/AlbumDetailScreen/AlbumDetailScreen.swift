//
//  AlbumDetailScreen.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/28/21.
//

import SwiftUI





struct AlbumDetailScreen: View {
  var mediaDetailVM: MediaDetailViewModel
  @EnvironmentObject var audioManager: RemoteAudio
  @State var scrollViewPosition = CGFloat.zero

  init(detailScreenOrigin: MediaDetailViewModel.DetailScreenOrigin, mediaDetailVM: MediaDetailViewModel) {
    self.mediaDetailVM = mediaDetailVM
    self.mediaDetailVM.detailScreenOrigin = detailScreenOrigin
  }

  var body: some View {
    ZStack {
      TopGradient(height: UIScreen.main.bounds.height).ignoresSafeArea()
      GeometryReader { geometry in
        ZStack {
          ReadableScrollView(currentPosition: $scrollViewPosition) {
            VStack {
              AlbumDetailContent( scrollViewPosition: $scrollViewPosition)
                .padding(.bottom, 180).environmentObject(audioManager)
            }
          }
          TopBarWithTitle(scrollViewPosition: $scrollViewPosition,
                          title: mediaDetailVM.mainItem!.title,
                          backButtonShouldReturnTo: mediaDetailVM.detailScreenOrigin!)
        }.ignoresSafeArea()
      }
    }
    .onDisappear {
      mediaDetailVM.cleanSectionFor(sectionMediaType: .album)
    }
  }
}

// MARK: - Detail Content

private struct AlbumDetailContent: View {
  @EnvironmentObject var mediaDetailVM: MediaDetailViewModel
  @EnvironmentObject var audioManager: RemoteAudio
  @Binding var scrollViewPosition: CGFloat
  @Environment(\.topSafeAreaSize) var topSafeAreaSize

  private var scale: CGFloat {
    let myScale = scrollViewPosition / UIScreen.main.bounds.height * 2
    return myScale > 0.8 ? 0.8 : myScale
  }

  private var details: SpotifyModel.AlbumDetails { SpotifyModel.getAlbumDetails(for: mediaDetailVM.mainItem!) }

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.spacingMedium) {
      ZStack {
        BigMediaCover(imageURL: mediaDetailVM.mainItem!.imageURL)
          .scaleEffect(1 / (scale + 1))
          .opacity(1 - Double(scale * 2 > 0.8 ? 0.8 : scale * 2))
      }
      .padding(.top, topSafeAreaSize)

      MediaTitle(mediaTitle: details.name, lineLimit: 2)

      if Utility.didEverySectionLoaded(in: .albumDetail, mediaDetailVM: mediaDetailVM) {
        AlbumAuthor()

        HStack {
          VStack(alignment: .leading) {
            AlbumInfo(releaseDate: details.releaseDate)
            LikeAndThreeDotsIcons()
          }
          BigPlayButton()
        }.frame(height: 65)

        TracksVerticalScrollView(tracksOrigin: .album(.tracksFromAlbum)).environmentObject(audioManager)
      } else {
        HStack {
          ProgressView()
            .withSpotifyStyle(useDiscreetColors: true)
            .onAppear {
              mediaDetailVM.getAlbumScreenData()
            }
        }.frame(maxWidth: .infinity, alignment: .center)
        Spacer()
      }

    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.horizontal, Constants.paddingStandard)
    .padding(.vertical, Constants.paddingSmall)
  }
}

// MARK: - Preview

struct AlbumDetailScreen_Previews: PreviewProvider {
  static var mainVM = MainViewModel()

  static var previews: some View {
    ZStack {
      // `detailScreenOrigin` doesn't matter on preview.
      PlaylistDetailScreen(detailScreenOrigin: .home(homeVM: HomeViewModel(mainViewModel: mainVM)),
                           mediaDetailVM: MediaDetailViewModel(mainVM: mainVM))
      VStack {
        Spacer()
        BottomBar(mainVM: mainVM, showMediaPlayer: true)
      }
    }
  }
}
