////
////  Store.swift
////  Zeno
////
////  Created by gnksbm on 2023/10/11.
////  Copyright © 2023 https://github.com/APPSCHOOL3-iOS/final-zeno. All rights reserved.
////
//
//import Foundation
//import Combine
//
//public typealias StoreOf<R: Reducer> = Store<R.State, R.Action>
//
//public final class Store<State, Action>: ObservableObject {
//  @Published public private(set) var state: State
//
//  private let reducer: AnyReducer<State, Action>
//
//  private let queue = DispatchQueue(label: "serial_queue", qos: .userInitiated)
//  private var cancellables: Set<AnyCancellable> = []
//  private var tasks: Set<Task<(), Never>> = []
//
//  // MARK: - Initialization
//
//  public init<R: ReducerProtocol>(
//    reducer: R
//  ) where R.State == State, R.Action == Action {
//    self.reducer = AnyReducer(reducer)
//    self.state = reducer.initialState
//  }
//
//  deinit {
//    tasks.forEach {
//      $0.cancel()
//    }
//  }
//
//  // MARK: - Public Methods
//
//  public func dispatch(_ action: Action) {
//    queue.sync {
//      dispatch(&state, action)
//    }
//  }
//
//  // MARK: - Private Methods
//
//  private func dispatch(_ state: inout State, _ action: Action) {
//    let effect = reducer.reduce(state: &state, action: action)
//
//    // effect에 의해 트리거 된 새로운 액션을 비동기적으로 실행 (dispatch)
//    switch effect {
//    case let .publisher(publisher):
//      publisher
//        .receive(on: DispatchQueue.main)
//        .sink(receiveValue: dispatch)
//        .store(in: &cancellables)
//
//    case let .task(task):
//      let newTask = Task {
//        let action = await task.value
//        await MainActor.run {
//          dispatch(action)
//        }
//      }
//      tasks.insert(newTask)
//
//    case .none:
//      break
//    }
//  }
//}
