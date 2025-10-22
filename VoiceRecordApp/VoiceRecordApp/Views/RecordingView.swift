//
//  RecordingView.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/21/25.
//

import SwiftUI

struct RecordingView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @State private var isPopupVisible: Bool = false
    @State private var selectedIndex = 0
    private let options = ["녹음", "라이브러리"]
    
    init(viewModel: RecordingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color(red: 246/255, green: 245/255, blue: 254/255)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image(systemName: "music.note")
                        .tint(.purple)
                        .foregroundStyle(.purple)
                        .font(.system(size: 32))
                    Text("Voice Record")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.purple)
                        .padding(.leading, 8)
                }
                .padding(.top, 24)
                
                Text("음성 녹음 및 편집")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.gray)
                    .padding(.top, 12)
                
                Picker("Options", selection: $selectedIndex) {
                    ForEach(0..<options.count, id: \.self) {
                        Text(options[$0])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 24))
                
                Spacer()
                    .frame(height: 32)
                
                if selectedIndex == 0 {
                    RecorderBoxView(viewModel: viewModel, isPopupVisible: $isPopupVisible)
                        .background(.white)
                        .cornerRadius(20)
                        .overlay (
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                } else {
                    LibraryView(viewModel: viewModel)
                        .background(.white)
                        .cornerRadius(20)
                        .overlay (
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3),
                                        lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                }
                
                
                Spacer()
            }
            
            if isPopupVisible {
                PopupInputView(isVisible: $isPopupVisible, viewModel: viewModel)
            }
        }
    }
}

#Preview {
    RecordingView(viewModel: RecordingViewModel())
}
