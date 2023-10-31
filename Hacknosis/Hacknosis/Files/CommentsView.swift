//
//  CommentsView.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 25/10/23.
//

import SwiftUI

struct CommentsView: View {
    
    @State private var profileText = ""
    @StateObject var viewModel: CommentsViewModel = CommentsViewModel()
    @Environment(\.presentationMode) var presentationMode

    var node:NodeModel? = nil

    var body: some View {
        
        ZStack {
            Color.blue.opacity(0.1).edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                if UserHelper.isCurrentUserADoctor() && !(node?.properties?.reviewed ?? false) {
                    TextEditor(text: $profileText)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        
                        .frame(height: 80)
                       // .navigationTitle("Add comments")
                    
                    
                    Button {
                        viewModel.addComment(nodeId: node?.fileId ?? "" , comment: profileText) { node, error in
                            if error == nil {
                                Task {
                                    await viewModel.getReports()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                        print("make API call")
                        //add action
                    } label: {
                        HStack(spacing: 0) {
                            Spacer()
                            Text("Submit")
                                .font(.interBold(size: 18, relativeTo: .headline))
                                .foregroundColor(Color.black)
                                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                                .frame(height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6.0)
                                        .stroke(Color(GRID_ITEM_BORDER), lineWidth: 3.0))
                                .background(Color(GRID_ITEM_COLOR).cornerRadius(6))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                } else {
                    if let comments = node?.properties?.doctors_comments {
                        HStack(spacing: 8) {
                            Text("Comments: ")
                                .font(.interBold(size: 18, relativeTo: .headline))
                                .foregroundColor(Color(FILTER_BORDER_COLOR))
                                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                            Text(comments)
                                .font(.interRegular(size: 16))
                            Spacer()
                        }
                    } else {
                        Text("Review in progress.No comments yet")
                            .font(.interRegular(size: 16))
                    }
                }
                Spacer()
            }
            .padding(.top, 16)
            .sheet(isPresented: $viewModel.isShowingMail) {
                MailView(result: $viewModel.isShowingMail, email: .constant(UserHelper.getCurrentUserFromRealm()?.email ?? ""))
                    }
        }
        .navigationTitle("Add comments")
        .navigationGradientBarColor(shouldRefresh: true)
    }
}
