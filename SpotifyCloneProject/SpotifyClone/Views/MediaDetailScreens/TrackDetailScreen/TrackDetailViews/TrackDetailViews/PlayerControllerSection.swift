//
//  PlayerControllerSection.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/26/21.
//

import SwiftUI
import AVKit

import Alamofire

struct PlayerControllerSection: View {
  @EnvironmentObject var mediaDetailVM: MediaDetailViewModel
  @EnvironmentObject var audioManager: RemoteAudio
  var isSmallDisplay: Bool = false

  private var urlString: String { mediaDetailVM.mainItem!.previewURL }

  var body: some View {
    VStack {
      audioManager.buildSliderForAudio()
        .padding(.bottom, isSmallDisplay ? -5 : 0)
      HStack {
        Spacer()
        BackwardButton(isSmallDisplay: isSmallDisplay).environmentObject(audioManager)
        Spacer()
        PlayStopButton( isSmallDisplay: isSmallDisplay).environmentObject(audioManager)
          .fixedSize()
        Spacer()
        ForwardButton( isSmallDisplay: isSmallDisplay).environmentObject(audioManager)
        Spacer()
        HeartButton(mediaDetailVM: mediaDetailVM, itemID: mediaDetailVM.mainItem!.id, itemType: .track)
          .frame(width: isSmallDisplay ? 20 : 25)
        Spacer()
      }
    }
    .padding(.bottom, isSmallDisplay ? -5 : 0)
    .onDisappear {
      // When this View isn't being shown anymore stop the player

    }
  }

//  private struct PlayingRateButton: View {
//    @EnvironmentObject var mediaDetailVM: MediaDetailViewModel
//    @EnvironmentObject var audioManager: RemoteAudio
//    var isSmallDisplay: Bool = false
//
//    var body: some View {
//      Button(action: { audioManager.changePlayingRate(audioManager: audioManager) },
//             label: {
//        Rectangle()
//          .fill(Color.clear)
//          .overlay(Text(audioManager.currentRateString)
//                    .font(.avenir(.medium, size: isSmallDisplay ? 15 : 18))
//                    .fixedSize())
//          .frame(width: isSmallDisplay ? 20 : 25)
//      })
//      .buttonStyle(PlainButtonStyle())
//      .disabled(audioManager.state != .active)
//    }
//  }

  private struct ForwardButton: View {
    @EnvironmentObject var mediaDetailVM: MediaDetailViewModel
    @EnvironmentObject var audioManager: RemoteAudio
    var isSmallDisplay: Bool = false

    var body: some View {
      Button(action: { audioManager.skipNext() },
             label: {
        Image("next")
          .resizeToFit()
          .frame(width: isSmallDisplay ? 25 : 30)
      })
      .buttonStyle(PlainButtonStyle())
      .disabled(audioManager.state != .active)
    }
  }

  private struct BackwardButton: View {
    @EnvironmentObject var mediaDetailVM: MediaDetailViewModel
    @EnvironmentObject var audioManager: RemoteAudio
    var isSmallDisplay: Bool = false

    var body: some View {
      Button(action: { audioManager.skipPrevious() },
             label: {
        Image("previous")
          .resizeToFit()
          .frame(width: isSmallDisplay ? 25 : 30)
      })
      .buttonStyle(PlainButtonStyle())
      .disabled(audioManager.state != .active)
    }
  }

  private struct PlayStopButton: View {
    @EnvironmentObject var mediaDetailVM: MediaDetailViewModel
    @EnvironmentObject var audioManager: RemoteAudio
    var isSmallDisplay: Bool = false

    var body: some View {
      Button {
        if audioManager.showPauseButton && !audioManager.lastPlayedURL.isEmpty {
          audioManager.pause()
        } else {
          if mediaDetailVM.mainItem!.previewURL.isEmpty {
            audioManager.playWithItunes(forItem: mediaDetailVM.mainItem!, canPlayMoreThanOneAudio: false)
          } else {
            var uri = mediaDetailVM.mainItem!.previewURL
            switch mediaDetailVM.mainItem!.mediaType {
            case .track:
              uri = "spotify:track:\(mediaDetailVM.mainItem!.id)"
            case .episode:
              uri = "spotify:episode:\(mediaDetailVM.mainItem!.id)"
            case .show:
              uri = "spotify:show:\(mediaDetailVM.mainItem!.id)"
            case .album:
              uri = "spotify:album:\(mediaDetailVM.mainItem!.id)"
            default:
              uri = mediaDetailVM.mainItem!.id
            }
            audioManager.play(uri, audioID: uri)
             }
        }
      } label: {
        ZStack {
          if audioManager.showPauseButton && !audioManager.lastPlayedURL.isEmpty {
            Image("circle-stop")
              .resizeToFit()
          } else {
            Image("circle-play")
              .resizeToFit()
          }
          if audioManager.state == .buffering {
            ZStack {
              Circle()
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                .padding(1)
            }
            .scaledToFit()
          }
        }
        .frame(width: isSmallDisplay ? 60 : 70)
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
}
