//
//  RecorderBoxView.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI

struct RecorderBoxView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @Binding var isPopupVisible: Bool
    
    var body: some View {
        HStack {
            VStack {
                Text(viewModel.recordingTime)
                    .font(.system(size: 36))
                    .foregroundStyle(.black)
                    .padding(.top, 24)
                
                Spacer()
                    .frame(height: 80)
                
                Button {
                    print("녹음 버튼 탭")
                    if viewModel.isRecording {
                        isPopupVisible.toggle()
                    }
                    viewModel.handleRecordingEvent()
                } label: {
                    Image(systemName: viewModel.isRecording ? "stop.fill" : "microphone")
                        .font(.system(size: 24))
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .padding(28)
                        .background(
                            Circle()
                                .fill(Color.red)
                        )
                }
                .frame(height: 80)
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
}
