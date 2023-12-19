//
//  AuthSheetView.swift
//  SpotifyClone
//
//  Created by Gabriel on 9/13/21.
//

import SwiftUI
import WebKit

struct AuthSheetView: View {
  @Binding var isShowingSheetView: Bool

  var body: some View {
        ProgressView()
          .withSpotifyStyle()
          .onAppear {
            isShowingSheetView = false
          }
      }
  }

