//
//  LibraryEmptyView.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI

struct LibraryEmptyView: View {
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "headphones.slash")
                    .foregroundStyle(.gray)
                    .font(.system(size: 32))
                    .padding(EdgeInsets(top: 24, leading: 0, bottom: 36, trailing: 0))
                
                Text("녹음된 파일이 없습니다")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.gray)
                    .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

#Preview {
    LibraryEmptyView()
}
