//
//  LoginScreenView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 11/10/23.
//

import SwiftUI

struct LoginScreenView: View {
    @StateObject var viewModel: LoginViewModel = LoginViewModel()
    @State var isInputFocused: Bool = false
    @State var isTextFieldFocused: Bool = false
    var body: some View {
        ZStack {
            Color(ACCENT_COLOR).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 16) {
                Spacer()
                Image(LOGO)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100,alignment: .center)
                    
                //Spacer()
                VStack(spacing: 0) {
                    ZStack {
                        RoundedCorners(color: Color.white.opacity(0.4), topLeft: 6, topRight: 6, bottomLeft: 0, bottomRight: 0)
                            .frame(height: 40)
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + (isInputFocused ? 0.6 : 0)) {
                                viewModel.showEnvironmentMenu()
                            }
                            if isInputFocused {
                                isInputFocused = false
                            }
                        }, label: {
                            Text(viewModel.environmentTitle)
                            Spacer()
                            Image(systemName: "chevron.down")
                        })
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                        .foregroundColor(.blue)
                        .frame(height: 40, alignment: .center)
                    }
                    .actionSheet(isPresented: $viewModel.isShowingEnvironmentMenu) {
                        return self.generateActionSheet(environments: viewModel.environments)
                    }
                    .contentShape(Rectangle())
                }
                
                VStack(spacing: 0) {
                    ZStack {
                        RoundedCorners(color: Color.white.opacity(0.4), topLeft: 6, topRight: 6, bottomLeft: 0, bottomRight: 0)
                            .frame(height: 40)
                        CoreTextField(text: $viewModel.subscriptionNameInput,
                                      isFirstResponder: $isInputFocused,
                                      textColor:Color.blue,
                                      placeholderText:"Subscription name",
                                      accessibilityIdentifier: "TEST_ACCESSIBILITY_SUBSCRIPTION_NAME",
                                      placeholderColor: Color.black.opacity(0.3),
                                      keyboardType: .alphabet,
                                      returnKeyType: .next,
                                      autoCapitalizationType: .none,
                                      autoCorrectionType: .no,
                                      onCommit: {
                            viewModel.showBrowserAuthentication()
                        }
                        )
                        .padding((EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)))
                        .frame(height: 40)
                    }
                    Rectangle()
                        .fill(isInputFocused ? Color(GRID_ITEM_BORDER) : Color(GRID_ITEM_BORDER).opacity(0.5))
                        .frame(height: isInputFocused ? 2 : 1)
                }
                Button {
                    //call api
                    if EnvironmentManager.shared.currentEnvironment?.isHidden == true {
                        EnvironmentManager.shared.updateCurrentEnvironment(environmentKey: "environment_north_america")
                    }
                    viewModel.removeInputFocus()
                    viewModel.showBrowserAuthentication()
                } label: {
                    Text("Next")
                        .foregroundColor(Color.black)
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 6.0)
                        .stroke(Color(GRID_ITEM_BORDER), lineWidth: 3.0))
                .background(Color(GRID_ITEM_COLOR).cornerRadius(6))
                Spacer()
            }
            .frame(width: 300)
            
        }
    }
    
    fileprivate func generateActionSheet(environments: [EnvironmentModel]) -> ActionSheet {
        let buttons = environments.filter({$0.isHidden == false}).enumerated().map { i, environment in
            Alert.Button.default(Text(environment.nameLocalizedKey), action: { viewModel.updateCurrentEnvironment(environmentKey: environment.nameLocalizedKey) } )
        }
        return ActionSheet(title: Text("Select tenant"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
    }
}
