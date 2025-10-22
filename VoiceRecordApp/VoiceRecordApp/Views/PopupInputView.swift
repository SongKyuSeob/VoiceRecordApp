//
//  PopupInputView.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI

struct PopupInputView: View {
    @Binding var isVisible: Bool
    @ObservedObject var viewModel: RecordingViewModel
    @State private var localTitle: String = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack {
                HStack {
                    Text("타이틀")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(EdgeInsets(top: 16, leading: 20, bottom: 4, trailing: 0))
                    Spacer()
                }
                
                HStack {
                    Spacer()
                        .frame(width: 20)
                    TextField("타이틀을 입력해주세요.", text: $localTitle)
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray, lineWidth: 0.5)
                        )
                    Spacer()
                        .frame(width: 20)
                }
                .padding(.bottom, 8)
                
                HStack {
                    Spacer()
                        .frame(width: 20)
                    Button {
                        Task {
                            await viewModel.saveTitleAndRecord(title: localTitle)
                            isVisible = false
                        }
                    } label: {
                        Text("저장")
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                Rectangle()
                                    .fill(Color.black.opacity(0.8))
                            )
                            .cornerRadius(12)
                    }
                    Spacer()
                        .frame(width: 20)
                }
                .padding(.bottom, 12)
                
                
            }
            .frame(width: 300)
            .background(.white)
            .cornerRadius(15)
            .shadow(radius: 16)
        }
    }
}

#Preview {
    PopupInputView(isVisible: .constant(true), viewModel: RecordingViewModel())
}
