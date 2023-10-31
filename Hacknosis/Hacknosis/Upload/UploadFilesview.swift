//
//  UploadFilesview.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import SwiftUI


struct UploadFilesView: View {
    @StateObject var viewModel = UploadFilesViewModel()
    @Binding var showUploadView: Bool
    let uploadType:UploadType
    let node:NodeModel
    
   // let sharedLink: LinkShareModel?
    let uploadHelper:[UploadType]
    var onSelection:(PickedMediaItems, [String])->Void
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?

    @Environment(\.presentationMode) var presentationMode
    
    @State private var opacity: CGFloat = 0
    @State private var contentOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea().opacity(opacity)
                    
            VStack(alignment: .center, spacing: 0) {
             
                
                ForEach(uploadHelper, id: \.self) { action in
                    Button {
                        contentOpacity = 0
                        onClickAction(action)
                        closeUploadView()
                    } label: {
                       
                    }
                  //  .buttonStyle(CoreButtonHighlightStyle())
                    

                    Rectangle()
                        .fill(Color(ASSET_IMAGE_SEPERATOR_BACKGROUND))
                        .frame(height: 1)
                }
              
                Button {
                    closeUploadView()
                    withOutAnimation {
                        showUploadView = false
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("CANCEL")
                            .font(.subheadline)
                            .foregroundColor(Color.accentColor)
                        Spacer()
                    }
                    .frame(minHeight: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(CoreButtonHighlightStyle())
                
            }
            .frame(width: 310)
            .background(Color.white)
            .cornerRadius(6)
            .opacity(contentOpacity)
            
            if viewModel.isLoading {
                LoadingSpinnerView()
//                    .isHidden(!viewModel.internetConnected)
            }
        }
        .opacity(0)
        .background(BackgroundCleanerView().edgesIgnoringSafeArea(.all))
        .onAppear {
            contentOpacity = 0
            opacity = 0
            viewModel.isShowingSheet = true
            viewModel.isShowingPhotoPicker = true
            viewModel.onViewAppear(node: node, onSelection: onSelection)
            if uploadType == .camera || uploadType == .versionFile {
                contentOpacity = 0
                opacity = 0
            } else {
                contentOpacity = 1
                opacity = 0.5
            }
            if UIAccessibility.isVoiceOverRunning {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                }
            }
        }
        .uiKitOnAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if uploadType == .camera {
                    viewModel.showCamera()
                }
                else if uploadType == .versionFile {
                    viewModel.showDocumentPicker()
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingCamera) {
            ImagePicker(sourceType: .camera, mediaItems: viewModel.selectedMediaItems) { didSelectItems in
                if didSelectItems {
                    viewModel.photoPickerDidPickPhotos()
                    contentOpacity = 0
                } else {
                    self.onSelection(viewModel.selectedMediaItems, [])
                }
                viewModel.closeCamera()
            }
            .ignoresSafeArea()
        }
        Spacer()
            .frame(height: 0)
            .sheet(isPresented: $viewModel.isShowingSheet, onDismiss: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if viewModel.selectedMediaItems.items.count == 0 && viewModel.galleryItems.count == 0 {
                        self.onSelection(viewModel.selectedMediaItems, viewModel.duplicateFileNames)
                        viewModel.closeMediaPicker()
                        
                    }
                }
            })  {
                if viewModel.isShowingPhotoPicker {
                    PhotoPicker(mediaType: .media, limit: 1) { didSelectItems in
                        if didSelectItems.count > 0 {
                            viewModel.galleryItems = didSelectItems
                            viewModel.photoPickerDidSelectPhotos(results: didSelectItems)
                            contentOpacity = 0
                        } else {
                            self.onSelection(viewModel.selectedMediaItems, [])
                        }
                        viewModel.closeMediaPicker()
                    }
                }
            }
        
        Spacer()
            .frame(height: 0)
            .alert(isPresented: $viewModel.isShowingCameraErrorAlert) {
                Alert(title: Text(String.localizedStringWithFormat(CAMERA_UNAVAILABLE_TITLE)),
                      message: Text(String.localizedStringWithFormat(CAMERA_UNAVAILABLE_MESSAGE)),
                      primaryButton: .default(Text(OK)){ showUploadView = false },
                      secondaryButton: .default(Text("Settings")) { openSettings() }
                )
            }
    }
    
    func closeUploadView() {
        opacity = 0.0
    }
    
    func onClickAction(_ type:UploadType) {
        switch type {
        case .photosAndVideos, .gallery:
            viewModel.showMediaPicker()
        case .files:
            viewModel.showDocumentPicker()
        case .versionCamera:
            viewModel.showVersionPicker()
        default:
            return
        }
    }
    
    func openSettings(){
        showUploadView = false
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
   
}

 

struct CoreButtonHighlightStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
          //  .background(configuration.isPressed ? Color(COLOR_BUTTON_HIGHLIGHT) : Color.clear)
    }
}


struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
