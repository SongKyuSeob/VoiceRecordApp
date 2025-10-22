//
//  LibraryView.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @StateObject var playerViewModel = PlayerViewModel()
    
    var body: some View {
        if viewModel.records.count == 0 {
            LibraryEmptyView()
        } else {
            RecordListView(
                recordingViewModel: viewModel,
                playerViewModel: playerViewModel
            )
        }
    }
  
}

#Preview {
    LibraryView(viewModel: RecordingViewModel())
}
