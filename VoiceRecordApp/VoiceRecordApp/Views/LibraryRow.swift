//
//  LibraryRow.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI

struct LibraryRow: View {
    let record: Record
    let isExpanded: Bool
    let onRowTap: () -> Void
    let playerViewModel: PlayerViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text(record.title.isEmpty ? "Untitled" : record.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                    
                    Text(dateFormat(date: record.date))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.gray)
                        .padding(.top, 4)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(TimeFormatter.shared.formatTime(record.duration))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.gray)
                }
            }
            .contentShape(Rectangle()) // HStack 전체 영역 이벤트 감지할 수 있도록
            .onTapGesture {
                onRowTap()
            }
            .alignmentGuide(.listRowSeparatorLeading, computeValue: { viewDimensions in
                return -viewDimensions.width
            })
            
            if isExpanded {
                PlayerView(viewModel: playerViewModel)
                    .transition(.slide)
            }
        }
        .background(.white)
        .listRowBackground(Color.white)
    }
    
    func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
