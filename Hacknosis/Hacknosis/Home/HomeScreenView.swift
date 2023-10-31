//
//  HomeScreenView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import SwiftUI

class Reports:  Hashable {
    static func < (lhs: Reports, rhs: Reports) -> Bool {
        return lhs == rhs
    }
    
    static func == (lhs: Reports, rhs: Reports) -> Bool {
        return lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    var title: String
    var image: String
    var screenType: ScreenType
 //   var reports: [NodeModel]
    init(title: String, image: String, screenType: ScreenType) {
        self.title = title
        self.image = image
        self.screenType = screenType
      //  self.reports = reports
    }
}
enum ScreenType {
    case upload
    case view
    case reviewed
    case unreviewed
}

struct HomeScreenView: View {
    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    @State var selectedType: ScreenType = .view
    @Binding var isDoctorLoggedIn: Bool
    let adaptiveColumns = [
        GridItem(.adaptive(minimum: 180))
    ]
    
     var data:[Reports] {

         if viewModel.isDoctoreSignedIn || UserHelper.isCurrentUserADoctor() {
           return [Reports(title: "View reports", image: VIEW_ICON, screenType: .unreviewed), Reports(title: "Reviewed reports", image: REVIEWED, screenType: .reviewed)]
        }
         return [Reports(title: "Upload reports", image: UPLOAD_ICON, screenType: .upload), Reports(title: "View reports", image: VIEW_ICON, screenType: .view)]

    }
    
//    var data = [Reports(title: "Upload reports", image: UPLOAD_ICON, screenType: .upload), Reports(title: "View reports", image: VIEW_ICON, screenType: .view)]
    var body: some View {
        ZStack {
        
            Color.accentColor.edgesIgnoringSafeArea(.all)
            
                VStack(spacing: 0) {
                    
                    HStack {
                        Text("Welcome !! \(UserHelper.isCurrentUserADoctor() ? "Dr." : "") \(viewModel.getUsername())")
                            .foregroundColor(Color(FILTER_BORDER_COLOR))
                            .font(.title)
                        Spacer()
                        if UserHelper.isCurrentUserADoctor() {
                            Image(DOC_IMAGE)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 140, height: 140)
                                .padding(.trailing, 16)
                        } else {
                            Image(PATIENT_IMAGE)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 140, height: 140)
                                .padding(.trailing, 16)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 24)
                    
                    
                    Spacer().frame(height: 120)
                    LazyVGrid(columns: adaptiveColumns,spacing:16) {
                        
                        ForEach(data, id: \.self) { item in
                            ZStack {
                                VStack(alignment: .center) {
                                    Image(item.image)
                                        .resizable()
                                        .aspectRatio( contentMode: .fit)
                                        .frame(width: 60,height: 60, alignment: .center)
                        
                                    Text("Upload reports")
                                        .opacity(0)
                                        .font(.title3)
                                    Text(item.title)
                                        .font(.title3)
                                }
                                .onTapGesture {
                                    // viewModel.onViewAppear()
                                    selectedType = item.screenType
                                    if item.screenType == .upload {
                                        viewModel.isShowingUploadScreenView = true
                                    } else {
                                        viewModel.isShowingFilesScreenView = true
                                    }
                                    
                                }
                                .padding(EdgeInsets(.init(top: 24, leading: 16, bottom: 24, trailing: 16)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16.0)
                                        .stroke(Color(GRID_ITEM_BORDER), lineWidth: 3.0))
                                .background(Color(GRID_ITEM_COLOR).cornerRadius(16))
                                .shadow(radius: 4)
                            }
                        }
                    }
                    Spacer()
                    Text("© HAPPI 2023")
                        .foregroundColor(Color.black)
                        .font(.interRegular(size: 14))
                }
            
//            if viewModel.isLoading {
//                LoadingSpinnerView()
//            }
            
            NavigationLink(EMPTY_STRING, destination: FilesScreenView(nodes: viewModel.getReportsFiltered(type: selectedType)), isActive:$viewModel.isShowingFilesScreenView).opacity(0).isHidden(true)
            NavigationLink(EMPTY_STRING, destination: UploadFilesScreenView(), isActive:$viewModel.isShowingUploadScreenView).opacity(0).isHidden(true)
            NavigationLink(EMPTY_STRING, destination: ProfileScreenView(), isActive:$viewModel.isShowingProfileScreen).opacity(0).isHidden(true)

            NavigationLink(destination: EmptyView()) { EmptyView() }.opacity(0).isHidden(true)
        }
        .uiKitOnAppear {
            viewModel.onViewAppear()
        }
        .navigationTitle("HAPPI")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: profileButton())
       
    }
    
    func profileButton() -> some View {
        return Button {
            viewModel.isShowingProfileScreen = true
        } label: {
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24,height: 24)
                .foregroundColor(Color(COLOR_NAVIGATION_BAR_DARK))
        }

    }
}

//struct HomeScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeScreenView()
//    }
//}

