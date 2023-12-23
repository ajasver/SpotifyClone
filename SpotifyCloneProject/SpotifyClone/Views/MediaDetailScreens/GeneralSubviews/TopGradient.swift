//
//  TopGradient.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/25/21.
//

import SwiftUI



struct TopGradient: View {
  @EnvironmentObject var mediaDetailVM: MediaDetailViewModel
  var userSpecifiedColor: Color?
  

  var height: CGFloat
  private var gradient: Gradient {
    if let userColor = userSpecifiedColor {
      return Gradient(colors: [userColor.opacity(0.8), userColor.opacity(0.4), userColor.opacity(0.2)])
    }

    if let albumTitle = mediaDetailVM.mainItem?.title {
      let albumGradient = AlbumGradient(albumTitle: albumTitle)
      return albumGradient.gradient
    } else {
      return Gradient(colors: [.clear])
    }
  }

  init(height: CGFloat, specificColor: Color? = nil) {
    self.height = height
    self.userSpecifiedColor = specificColor
  }

  var body: some View {
    Rectangle()
      .fill(LinearGradient(gradient: gradient,
                           startPoint: .top,
                           endPoint: .bottom))
      .frame(height: height)
  }
}


struct AlbumGradient {
  var albumTitle: String

  var gradient: Gradient {
    if albumTitle.contains("Fearless") {
      return Gradient(colors: [Color(red: 255/255, green: 215/255, blue: 0/255), Color(red: 255/255, green: 255/255, blue: 0/255)])
    } else if albumTitle.contains("Speak Now") {
      return Gradient(colors: [Color(red: 128/255, green: 0/255, blue: 128/255), Color(red: 148/255, green: 0/255, blue: 211/255)])
    } else if albumTitle.contains("Red") {
      return Gradient(colors: [Color(red: 255/255, green: 0/255, blue: 0/255), Color(red: 178/255, green: 34/255, blue: 34/255)])
    } else if albumTitle.contains("1989") {
      return Gradient(colors: [Color(red: 128/255, green: 128/255, blue: 128/255), Color(red: 192/255, green: 192/255, blue: 192/255)])
    } else if albumTitle.contains("Reputation") {
      return Gradient(colors: [Color(red: 255/255, green: 255/255, blue: 255/255), Color(red: 0/255, green: 0/255, blue: 0/255)])
    } else if albumTitle.contains("Lover") {
      return Gradient(colors: [Color(red: 255/255, green: 105/255, blue: 180/255), Color(red: 255/255, green: 20/255, blue: 147/255)])
    } else if albumTitle.contains("Folklore") {
      return Gradient(colors: [Color(red: 245/255, green: 245/255, blue: 220/255), Color(red: 255/255, green: 250/255, blue: 205/255)])
    } else if albumTitle.contains("Evermore") {
      return Gradient(colors: [Color(red: 34/255, green: 139/255, blue: 34/255), Color(red: 0/255, green: 128/255, blue: 0/255)])
      } else if albumTitle.contains("Midnights") {
        return Gradient(colors: [Color(red: 25/255, green: 25/255, blue: 112/255), Color(red: 112/255, green: 128/255, blue: 144/255)])
      } else {
      return Gradient(colors: [Color.spotifyDarkGray])
    }
  }
}
