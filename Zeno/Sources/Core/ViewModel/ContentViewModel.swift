//
//  ContentViewModel.swift
//  Zeno
//
//  Created by Muker on 2023/10/01.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import SwiftUI
import FirebaseAuth
import Combine

class ContentViewModel: ObservableObject {
	@Published var userSession: FirebaseAuth.User?
	@Published var currentUser: User?
	
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		setupSubscribers()
	}
	
	func setupSubscribers() {
		/// Combine으로 싱글톤의 userSession를 해당 viewModel과 sink 맞추기
		AuthService.shared.$userSession.sink { [weak self] userSession in
			self?.userSession = userSession
		}.store(in: &cancellables)
		/// Combine으로 싱글톤의 currentUser를 해당 viewModel과 sink 맞추기
		AuthService.shared.$currentUser.sink { [weak self] currentUser in
			self?.currentUser = currentUser
		}.store(in: &cancellables)
	}
}
