//
//  UploadFilesView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 23/10/23.
//

import SwiftUI
import SimpleToast

struct UploadFilesScreenView: View {
    @StateObject var viewModel: FilesViewModel = FilesViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
   // @State var showToast: Bool = false
    private let toastOptions = SimpleToastOptions(
        hideAfter: 5
    )
       
    var body: some View {
       // Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        ZStack {
            Color.blue.opacity(0.1).edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Text("Add reports for review")
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6.0)
                            .stroke(Color(GRID_ITEM_BORDER), lineWidth: 3.0))
                    .background(Color(GRID_ITEM_COLOR).cornerRadius(6))
                    .onTapGesture {
                        viewModel.showUploadView = true
                        
                    }
            }
            
            if viewModel.isUploadingFile {
                LoadingSpinnerView()
            }
            NavigationLink(EMPTY_STRING, destination: FilesScreenView(nodes: viewModel.nodes), isActive:$viewModel.isShowingFilesScreenView).opacity(0).isHidden(true)
        }
        .simpleToast(isPresented: $viewModel.isShowingToast, options: toastOptions) {
            HStack {
                      Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.green)
                      Text("Your report is uploaded successfully")
                  }
               .padding()
               .background(Color.white.opacity(0.8))
               .foregroundColor(Color.black)
               .cornerRadius(10)
               .padding(.top)
           }
        .onChange(of: viewModel.showUploadView, perform: { value in
            if value {
                uploadFilesPopup()
            } else {
                viewControllerHolder?.dismiss(animated: false)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Upload Reports")
        .navigationBarBackButtonHidden(false)
        .navigationGradientBarColor(shouldRefresh: true)
        .onAppear {
            viewModel.onViewAppear()
        }
        .uiKitOnAppear {
            viewModel.onViewAppear()
        }
    }
    
    fileprivate func uploadFilesPopup() {
        var uploadOptions = UploadHelper.uploadTypeList
        
        self.viewControllerHolder?.present(backgroundColor:UIColor(red: 0, green: 0, blue: 0, alpha: 0.5),
                                           shouldAnimate: false) {
            UploadFilesView(showUploadView: $viewModel.showUploadView,
                            uploadType:viewModel.uploadType,
                            node: viewModel.selectedNodeForUpload ?? NodeModel(id: rootFolderid, name: "patient_root_folder", mimeType: "", contentSize: 0), uploadHelper: uploadOptions,
                            onSelection: { mediaItems, duplicateFileNames in
                withOutAnimation(execute: {
                    DispatchQueue.main.async {
                        viewModel.showUploadView = false
                    }
                }, completion: {
                    if mediaItems.items.count > 0 {
                        viewModel.selectedMediaItems = mediaItems
                        
                        viewModel.uploadSelectedFiles()
                        
                    } else {
                        viewModel.selectedNodeForUpload = nil
                    }
                })
            })
        }
    }
    
}

