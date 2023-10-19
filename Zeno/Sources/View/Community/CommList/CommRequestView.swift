//
//  CommReqestView.swift
//  Zeno
//
//  Created by Muker on 2023/10/08.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI

struct CommRequestView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var commViewModel: CommViewModel
    
    @Binding var isShowingCommRequestView: Bool
    @State var aplicationStatus: Bool
    @State private var showingAlert = false
    
    private let throttle: Throttle = .init(delay: 1)
    
    var comm: Community
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Spacer()
                // 이미지
                ZenoKFImageView(comm)
                    .frame(maxWidth: .screenWidth * 0.8, maxHeight: .screenWidth * 0.8)
                    .clipShape(Circle())
                    .shadow(radius: 2, y: 2)
                    .padding(20)
                // 커뮤니티 설명
                VStack(alignment: .leading, spacing: 7) {
                    Text(comm.name)
                        .font(.extraBold(24))
                        .lineLimit(2)
                        .padding(.bottom, 5)
                    
                    Section {
                        HStack {
                            Image(systemName: "person.2.fill")
                            Text("\(comm.joinMembers.count) / \(comm.personnel)")
                        }
                        
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("\(comm.createdAt.convertDate)")
                        }
                    }
                    .font(.thin(12))
                    
                    Text(comm.description)
                        .lineLimit(nil)
                        .font(.regular(15))
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                
                Spacer()
                
                Button {
                    throttle.run {
                        Task {
                            do {
                                try await commViewModel.requestJoinComm(comm: comm)
//                                try await userViewModel.addRequestComm(comm: comm)
                                self.showingAlert = true
                                self.aplicationStatus = true
                                print("성공\(self.showingAlert)")
                            } catch {
                                print("실패")
                            }
                        }
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(width: .screenWidth * 0.9, height: .screenHeight * 0.07)
                            .cornerRadius(15)
                            .foregroundColor(aplicationStatus ? .gray : .mainColor)
                            .opacity(0.8)
                            .shadow(radius: 3)
                        //						Image(systemName: "paperplane")
                        //							.font(.system(size: 21))
                        //							.offset(x: -.screenWidth * 0.3)
                        //							.foregroundColor(aplicationStatus ? .gray : .white)
						
							if comm.personnel <= comm.joinMembers.count {
								Text("인원이 꽉 찼습니다.")
									.font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 17))
									.foregroundColor(.gray)
							} else if aplicationStatus {
								Text("이미 신청한 그룹")
									.font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 17))
									.foregroundColor(.gray)
							} else {
								Text("가입 신청 하기")
									.font(ZenoFontFamily.NanumSquareNeoOTF.heavy.swiftUIFont(size: 17))
									.foregroundColor(.white)
							}
                    }
                    .offset(y: -20)
                    .padding(.top, 30)
                }
                .disabled(aplicationStatus)
            }
            .zenoWarning("그룹에 가입신청을 보냈습니다", isPresented: $showingAlert)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingCommRequestView = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct CommReqestView_Previews: PreviewProvider {
    static var previews: some View {
        CommRequestView(isShowingCommRequestView: .constant(true), aplicationStatus: true, comm: Community.dummy[0])
            .environmentObject(UserViewModel())
            .environmentObject(CommViewModel())
    }
}
