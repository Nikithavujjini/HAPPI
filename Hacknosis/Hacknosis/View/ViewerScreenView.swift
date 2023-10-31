//
//  ViewerScreenView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import SwiftUI

struct ViewerScreenView: View {
    @StateObject var viewModel:ViewerViewModel
    @Environment(\.presentationMode) var presentationMode
    var node:NodeModel?
    var updatedTime:String?
    init(node:NodeModel? = nil, updatedTime:String?) {
        self.updatedTime = updatedTime
        self.node = node
        _viewModel = StateObject(wrappedValue:  ViewerViewModel(fileItemData: node))
    }
    
    var body: some View {
        ZStack {
            if let fileUrl = viewModel.documentDownloadedUrl, viewModel.documentType == .documentViewer {
                PreviewController(nodeName: node?.name ?? EMPTY_STRING, nodeId: node?.id ?? EMPTY_STRING, documentLink: fileUrl, mimeType: node?.mimeType)
                    .ignoresSafeArea()
            }
            if viewModel.isLoading {
                LoadingSpinnerView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(COLOR_VIEWER_BACKGROUND))
        .navigationTitle(node?.name ?? EMPTY_STRING)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationGradientBarColor(shouldRefresh: true)
        .onAppear {
            viewModel.onViewAppear()
        }
    }
    
}


