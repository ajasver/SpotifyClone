//
//  PlayStopButton.swift
//  SpotifyClone
//
//  Created by Gabriel on 10/21/21.
//

import SwiftUI

struct PlayStopButton: View {
  @EnvironmentObject var audioManager: RemoteAudio
  var media: SpotifyModel.MediaItem
  var size: CGFloat

  var body: some View {

    ZStack {
      // Add a darkish background to the play/stop button, so
      // it gets more visible even when the cover image is whitish.
      Color.spotifyMediumGray.opacity(0.3)

      // The play/stop/buffering icon
      ZStack(alignment: .center) {
        if audioManager.isBuffering && audioManager.lastItemPlayedID == media.id {
          ProgressView()
            .scaledToFit()
        } else {
          if audioManager.showPauseButton && audioManager.lastItemPlayedID == media.id {
            Image("stop")
              .resizeToFit()
              .onTapGesture {
                audioManager.pause()
              }
          } else {
            Image("play")
              .resizeToFit()
              .padding(.leading, 3)
              .onTapGesture {

                // set to true just to eliminate the small delay of the timer that checks if isBuffering
                audioManager.isBuffering = true
                audioManager.checkIfIsBuffering()

                if media.previewURL.isEmpty {
                  audioManager.playWithItunes(forItem: media, canPlayMoreThanOneAudio: true)
                } else {
                  audioManager.pause()
                  var uri = media.previewURL
                  switch media.mediaType {
                  case .track:
                    uri = "spotify:track:\(media.id)"
                  case .episode:
                    uri = "spotify:episode:\(media.id)"
                  case .show:
                    uri = "spotify:show:\(media.id)"
                  case .album:
                    uri = "spotify:album:\(media.id)"
                  default:
                    uri = media.id
                  }

                  audioManager.play(
                    uri, audioID: uri)
                }
              }
          }
        }
      }
      .frame(width: 25, height: 25)
//      .onReceive(audioManager.bufferingCheckerTimer!) { _ in
//        audioManager.checkIfIsBuffering()
//      }
      .onDisappear {
        audioManager.stopObservingForBufferingState()
      }
    }
    .frame(width: size, height: size, alignment: .center)
  }
}
