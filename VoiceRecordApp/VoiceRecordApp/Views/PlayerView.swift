//
//  PlayerView.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var viewModel: PlayerViewModel
    
    var body: some View {
        VStack {
            Slider(
                value: $viewModel.currentTime,
                in: 0...viewModel.duration,
                onEditingChanged: { editing in
                    if !editing {
                        viewModel.seekTo(time: viewModel.currentTime)
                    }
                }
            )
                .padding(.bottom, 16)
            Button {
                viewModel.isPlaying ? viewModel.pause() : viewModel.play()
                print("재생 버튼 탭")
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .foregroundStyle(.black)
            }

        }
        .padding(.vertical, 20)
    }
}
