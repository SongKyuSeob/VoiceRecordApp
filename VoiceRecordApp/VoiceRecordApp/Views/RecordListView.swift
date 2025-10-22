//
//  RecordListView.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI

struct RecordListView: View {
    @ObservedObject var recordingViewModel: RecordingViewModel
    @ObservedObject var playerViewModel: PlayerViewModel
    @State private var expandedIndex: Int? = nil
    
    var body: some View {
        List(Array(recordingViewModel.records.enumerated()), id: \.element.id) { idx, record in
            LibraryRow(
                record: record,
                isExpanded: expandedIndex == recordingViewModel.records.firstIndex(where: {$0.id == record.id}),
                onRowTap: {
                    if expandedIndex == idx {
                        expandedIndex = nil
                    } else {
                        expandedIndex = idx
                        playerViewModel.trackFileName = record.fileName
                    }
                },
                playerViewModel: playerViewModel,
            )
        }
        .listStyle(.plain)
        .background(Color.white)
    }
}
