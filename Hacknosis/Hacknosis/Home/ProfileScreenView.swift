//
//  ProfileScreenView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 25/10/23.
//

import SwiftUI
import SimpleToast

struct ProfileScreenView: View {
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1).edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                Spacer().frame(height: 100)
                if let user = viewModel.user {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80,height: 80)
                        .padding(.bottom, 16)
                        .foregroundColor(Color.accentColor)
                    Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                        .font(.interBlack(size: 32))
                        .padding(.bottom, 16)
                    Text("\(user.email ?? "")")
                        .font(.interBlack(size: 26))
                }
                
                Spacer()
                    .frame(height: 120)
                
                Button {
                    UserHelper.clearCurrentUserFromRealm()
                    NotificationCenter.default.post(name: .returnToLogin, object: nil)
                } label: {
                    Text("Sign Out")
                        .foregroundColor(Color.black)
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .frame(width: 200, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 6.0)
                        .stroke(Color(GRID_ITEM_BORDER), lineWidth: 3.0))
                .background(Color(GRID_ITEM_COLOR).cornerRadius(6))
                .contentShape(Rectangle())
                Spacer()
            }
        }
        
        .navigationTitle("Profile")
        .navigationGradientBarColor(shouldRefresh: true)
        .onAppear {
            viewModel.onViewAppear()
            //viewModel.isShowingToast = true
        }
    }
    
    
}

struct ProfileScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreenView()
    }
}
