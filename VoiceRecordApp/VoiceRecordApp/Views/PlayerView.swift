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
            HStack {
                Button {
                    viewModel.isPlaying ? viewModel.pause() : viewModel.play()
                    print("재생 버튼 탭")
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 12)
                
                Slider(
                    value: $viewModel.currentTime,
                    in: 0...viewModel.duration,
                    step: 1
                )
                .frame(maxWidth: .infinity)
                
                if let originalURL = viewModel.getOriginalFileURL() {
                    ShareLink(item: originalURL) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 12)
                }
                
            }
            .padding(.bottom, 16)
            
            HStack {
                Text("리버브")
                    .font(.system(size: 12))
                    .foregroundStyle(.black)
                    .padding(.leading, 12)
                Spacer()
                Toggle("리버브", isOn: $viewModel.isReverbEnabled)
                    .onChange(of: viewModel.isReverbEnabled) { oldValue, newValue in
                        viewModel.toggleReverb(newValue)
                    }
                    .padding(.trailing, 12)
            }
        }
        .padding(.vertical, 20)
    }
}
