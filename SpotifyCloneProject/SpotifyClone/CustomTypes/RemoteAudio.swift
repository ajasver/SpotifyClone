//
//  RemoteAudio.swift
//  SpotifyClone
//
//  Created by Gabriel on 10/4/21.
//

// The code is an adaptation of github.com/ChrisMash/AVPlayer-SwiftUI

import SwiftUI
import AVKit
import Combine

class RemoteAudio: NSObject, SPTAppRemotePlayerStateDelegate, ObservableObject {

  var timeObserver: PlayerTimeObserver? = nil

  private var mainVM: MainViewModel
  @EnvironmentObject var mediaDetailVM: MediaDetailViewModel
  @Published var currentTime: TimeInterval = 0
  @Published var currentDuration: TimeInterval = 0
  @Published private(set) var currentRateString: String = "1x"
  // We need this because the player resets it's own rate tracker when user pauses, skips 5sec, etc...
  @Published private var currentRate: Float = 1.0
  @Published var state = PlaybackState.waitingForSelection

  @Published private(set) var lastPlayedURL = ""
  @Published private(set) var lastItemPlayedID = ""
  @Published private(set) var showPauseButton = false

  // Used to check buffering. This is a workaround for cases where the `RemoteAudio.state` doesn't work
  @Published var isBuffering = false
  private(set) var bufferingCheckerTimer: Publishers.Autoconnect<Timer.TimerPublisher>?
  private var playerState: SPTAppRemotePlayerState?
  private var lastPlaybackPosition: TimeInterval = 0

  private var appRemote: SPTAppRemote {
    mainVM.appRemote
  }

  init(mainVM: MainViewModel) {
    self.mainVM = mainVM
    super.init()
  }

  var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print(error)
                }
            }
        }
    }

  func appRemoteConnecting() {
        
    }

  func appRemoteConnected() {
    self.timeObserver = PlayerTimeObserver(appRemote: appRemote)
    appRemote.playerAPI?.delegate = self
    appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
      if let error = error {
        print(error.localizedDescription)
      }
      self.playerState = result as? SPTAppRemotePlayerState
    })
  }

  func appRemoteDisconnect() {
    }

  func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
    self.playerState = playerState
    updatePlayPauseButtonState(playerState.isPaused)
    updateCurrentPlayingTrack(playerState: playerState)
}

  func updatePlayPauseButtonState(_ paused: Bool) {
    showPauseButton = !paused
  }

  func updateCurrentPlayingTrack(playerState: SPTAppRemotePlayerState) {
    let track = playerState.track
    if track.uri != lastItemPlayedID {
        let currentTrackArtist = track.artist.name
        let currentTrackName = track.name
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize(width: 60, height: 60), callback: { (image, error) in
            if let error = error {
                print("Failed to fetch image: \(error)")
            } else if let image = image as? UIImage {
              self.mainVM.currentTrack = SpotifyModel.MediaItem(
                title: track.name,
                previewURL: currentTrackName,
                imageURL: "",
                lowResImageURL: "",
                authorName: [currentTrackArtist],
                author: nil,
                mediaType: .track,
                id: track.uri,
                details: .tracks(trackDetails: SpotifyModel.TrackDetails(
                  popularity: 0,
                  explicit: false,
                  durationInMs: Double(track.duration),
                  id: track.uri))
              )
            }
    })
    }

  }


  func play(_ audioURL: String, audioID: String) {
    if lastPlayedURL != audioURL {
      print("play!")
      appRemote.playerAPI?.play(audioURL, callback: defaultCallback)
    } else {
      appRemote.playerAPI?.resume()
    }
    lastItemPlayedID = audioURL
    lastPlayedURL = audioURL
    showPauseButton = true}

  func pause() {
    appRemote.playerAPI?.pause(defaultCallback)
    showPauseButton = false
  }

  func stop() {
    appRemote.playerAPI?.pause(defaultCallback)
    showPauseButton = false
  }


  func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }

  func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }

  func moveToStartTime() {
    let minimumTime = CMTime(seconds: 0, preferredTimescale: 600)

    appRemote.playerAPI?.seek(toPosition: 0) { [weak self] _, error in
      if let error = error {
        print(error)
      } else {
        self?.timeObserver!.pause(false)
        self?.state = .active
      }
    }

    refreshPlayerCasePaused()
  }

  func checkIfIsBuffering() {
    guard let playerState = self.playerState else {
      isBuffering = false
      return
    }
    isBuffering = false
    return
//    let isPlaybackStalled = playerState.playbackSpeed == 0 && playerState.playbackPosition != lastPlaybackPosition
//    isBuffering = isPlaybackStalled
//    lastPlaybackPosition = playerState.playbackPosition
  }

  func startObservingForBufferingState() {
    bufferingCheckerTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  }

  func stopObservingForBufferingState() {
    bufferingCheckerTimer?.upstream.connect().cancel()
  }

  private func changeCurrentTime(by time: Double) {

    timeObserver!.pause(true)
    var targetTime = CMTime(seconds: currentTime + time, preferredTimescale: 600)
    let duration = CMTime(seconds: currentDuration, preferredTimescale: 600)
    let minimumTime = CMTime(seconds: 0, preferredTimescale: 600)

    if time > 0 {
      if targetTime > duration {
        let oneSecond = CMTime(seconds: 1, preferredTimescale: 600)
        targetTime = duration - oneSecond
      }
    } else {
      if targetTime < minimumTime {
        targetTime = minimumTime
      }
    }

    appRemote.playerAPI?.seek(toPosition: Int(targetTime.seconds)*100) { [weak self] _, error in
      if let error = error {
        print(error)
      } else {
        self?.timeObserver!.pause(false)
        self?.state = .active
      }
    }

    refreshPlayerCasePaused()
  }

  private func refreshPlayerCasePaused() {
    // Play and stop stop immediately to refresh the view if `isPaused`.
    appRemote.playerAPI?.play("")
    appRemote.playerAPI?.pause(defaultCallback)
    self.showPauseButton = true
  }

  @ViewBuilder func buildSliderForAudio() -> some View {
    AudioSlider(remoteAudio: self)
  }

  // MARK: Private functions

  // Returns true or false, based on if the user is currently dragging the slider's thumb.
  func sliderEditingChanged(editingStarted: Bool) {
    if editingStarted {
      // Tell the PlayerTimeObserver to stop publishing updates while the user is interacting
      // with the slider (otherwise it would keep jumping from where they've moved it to, back
      // to where the player is currently at)
      timeObserver!.pause(true)
    } else {
      // Editing finished, start the seek
      state = .buffering
      let targetTime = CMTime(seconds: currentTime,
                              preferredTimescale: 600)
      appRemote.playerAPI?.seek(toPosition: Int(targetTime.seconds)*100) { [weak self] _, error in
        if let error = error {
          print(error)
        } else {
        // Now the (async) seek is completed, resume normal operation
        self?.timeObserver!.pause(false)
        self?.state = .active
        }
      }
    }
  }
        
  enum PlaybackState: Int {
    case waitingForSelection
    case buffering
    case active
  }

}

// MARK: - Observers

class PlayerTimeObserver {
  let publisher = PassthroughSubject<TimeInterval, Never>()
  private weak var appRemote: SPTAppRemote?
  private var timeObservation: Any?
  private var paused = false

  init(appRemote: SPTAppRemote) {
    self.appRemote = appRemote

    // Periodically observe the player's current time, whilst playing
    appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
       // If we've not been told to pause our updates
      guard !self.paused else { return }
      // If there's no error in getting the player state
      if let playerState = result as? SPTAppRemotePlayerState, error == nil {
        // Publish the new player time
        self.publisher.send(Double(playerState.playbackPosition)/100)
      }
    })
  }

  deinit {
    if let appRemote = appRemote,
       let observer = timeObservation {
      appRemote.playerAPI?.unsubscribe(){ _, error in
        if let error = error {
          print(error)
        }
      }
    }
  }

  func pause(_ pause: Bool) {
    paused = pause
  }
}
