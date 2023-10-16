//
//  Throttle.swift
//  Zeno
//
//  Created by Muker on 2023/10/16.
//  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
//

import Foundation

final class Throttle {
	private let delay: TimeInterval
	private var workItem: DispatchWorkItem?
	private let queue: DispatchQueue

	init(delay: TimeInterval, queue: DispatchQueue = .main) {
		self.delay = delay
		self.queue = queue
	}

	func run(action: @escaping () -> Void) {
		if self.workItem == nil {
			action()
			let workItem = DispatchWorkItem {
				self.workItem?.cancel()
				self.workItem = nil
			}
			self.workItem = workItem
			queue.asyncAfter(deadline: .now() + delay, execute: workItem)
		}
	}
}
