//
//  FilesScreenView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 17/10/23.
//

import SwiftUI
import UniformTypeIdentifiers
import SimpleToast

struct FilesScreenView: View {
    
    @StateObject var viewModel: FilesViewModel = FilesViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    //    private let toastOptions = SimpleToastOptions(
    //        hideAfter: 5
    //    )
    @Binding var nodes: [NodeModel]
    var body: some View {
        ZStack {
            //  Color.blue.opacity(0.1).ignoresSafeArea()
            VStack(spacing: 0) {
                if nodes.count == 0 {
                    if UserHelper.isCurrentUserADoctor() {
                        Text("No reports for review")
                        
                    } else {
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
                } else if nodes.count > 0 {
                    VStack(spacing:0) {
                        List(nodes) { node in
                            VStack(spacing: 0) {
                                addFilesContent(node: node)
                                    .swipeActions(edge: .trailing) {
                                        if !UserHelper.isCurrentUserADoctor() {
                                            Button {
                                                viewModel.nodeToViewer = node
                                                viewModel.isShowingHistoryView = true
                                                //add action
                                            } label: {
                                                VStack(spacing: 6) {
                                                    Image(systemName: "clock.arrow.circlepath")
                                                        .foregroundColor(Color.black)
                                                    Text("History")
                                                        .foregroundColor(Color.black)
                                                }
                                            }
                                            .tint(Color.brown.opacity(0.6))
                                        }
                                        
                                        Button {
                                            viewModel.nodeToViewer = node
                                            viewModel.isShowingCommentView = true
                                            //add action
                                        } label: {
                                            VStack(spacing: 6) {
                                                Image(systemName: "info.circle.fill")
                                                    .foregroundColor(Color.black)
                                                Text("Feedback")
                                                    .foregroundColor(Color.black)
                                            }
                                           
                                        }
                                        .tint(Color.accentColor)
                                        //  .background(Color.accentColor)
                                        if !UserHelper.isCurrentUserADoctor() {
                                            Button {
                                                //add action
                                                if node.shared {
                                                    //generate and copy link
                                                    // com.opentext.sha/shared/docs/4e047abb-c04a-4194-aae3-a7357022973c
                                                    var sharedLinkPrefix = "com.opentext.sha/shared/docs/"
                                                    let sharedLink = "\(sharedLinkPrefix)\(node.fileId)"
                                                    UIPasteboard.general.setValue(sharedLink, forPasteboardType: "public.plain-text")
                                                } else {
                                                    viewModel.getShareLink(nodeId: node.id) { sharedLink in
                                                        if sharedLink.isNotEmpty {
                                                            UIPasteboard.general.setValue(viewModel.sharedLink, forPasteboardType: "public.plain-text")
                                                        }
                                                    }
                                                }
                                            } label: {
                                                VStack(spacing: 6) {
                                                  //  node.shared ? "square.and.arrow.down.on.square" :
                                                    Image(systemName: "doc.on.doc.fill")
                                                        .foregroundColor(Color.black)
                                                    Text("Copy link")
                                                        .foregroundColor(Color.black)
                                                 
                                                }
                                            }
                                            .tint(Color(GRID_ITEM_BORDER))
                                            
                                        }
                                    }
                                
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            
                            .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in
                                0
                            })
                            .listRowSeparatorTint(Color.black)
                            .listRowBackground(Color.white)
                        }
                        .listStyle(.plain)
                        
                        .background(Color.blue.opacity(0.1))
                        
                    }
                    // .background(BackgroundCleanerView())
                }
            }
            .onChange(of: viewModel.showUploadView, perform: { value in
                if value {
                    uploadFilesPopup()
                } else {
                    viewControllerHolder?.dismiss(animated: false)
                }
            })
            
            if viewModel.isLoading {
                //  Color.blue.opacity(0.1).ignoresSafeArea()
                LoadingSpinnerView()
            }
            
            
            NavigationLink(EMPTY_STRING, destination: ViewerScreenView(node: viewModel.nodeToViewer,updatedTime: viewModel.nodeToViewer?.updateTime), isActive:$viewModel.isShowingViewer).opacity(0).isHidden(true)
            NavigationLink(EMPTY_STRING, destination: CommentsView(node: viewModel.nodeToViewer), isActive: $viewModel.isShowingCommentView).opacity(0).isHidden(true)
            NavigationLink(EMPTY_STRING, destination: HistoryScreenView(node: viewModel.nodeToViewer), isActive: $viewModel.isShowingHistoryView).opacity(0).isHidden(true)
            
        }

        .uiKitOnAppear {
            viewModel.onViewAppear()
        }
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Reports")
        .navigationBarBackButtonHidden(false)
        .navigationGradientBarColor(shouldRefresh: true)
    }
    
    func addFilesContent(node: NodeModel) -> some View {
        return FilesListItemView(node: node)
            .background(BackgroundCleanerView())
            .onTapGesture(count: 1) {
                viewModel.showViewer(node: node)
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
                    viewModel.showUploadView = false
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


