//
//  RootScreenView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import SwiftUI
import Foundation

struct RootScreenView: View {
    
    //MARK: - Variables
    @StateObject var viewModel: RootViewModel = RootViewModel()
    @State var isStatusBarHidden = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    
    //MARK: - View
    
    var body: some View {
        ZStack(){
            if viewModel.isShowingHome {
                NavigationView() {
                    HomeScreenView(isDoctorLoggedIn: $viewModel.isDoctorLoggedIn)
                        .transition(.opacity)
                        .navigationViewStyle(StackNavigationViewStyle())
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationGradientBarColor(shouldRefresh: true)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                NavigationView() {
                    LoginScreenView()
                        .transition(.opacity)
                        .padding(.top, safeAreaInsets.top)
                       // .navigationGradientBarColor(shouldRefresh: true)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(true)
                        .ignoresSafeArea()
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .onAppear() {
            viewModel.onViewAppear()
          //  UIApplication.shared.addInteractionRecognizer()
        }
        .statusBar(hidden: isStatusBarHidden)
        
        
    }
    
 
    
}

struct RootScreenView_Previews: PreviewProvider {
    static var previews: some View {
        RootScreenView()
    }
}



