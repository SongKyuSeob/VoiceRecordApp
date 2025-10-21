//
//  VoiceRecordApp.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/21/25.
//

import SwiftUI

@main
struct VoiceRecordApp: App {
    @StateObject private var recordingViewModel = RecordingViewModel()
    
    var body: some Scene {
        WindowGroup {
            RecordingView(viewModel: recordingViewModel)
        }
    }
}
