//
//  ViewModelObject.swift
//  NextSunnyDay
//
//  Created by rMac on 2020/10/12.
//

import Combine

// MARK: - ViewModelObject
protocol ViewModelObject: ObservableObject {
    associatedtype Input: InputObject
    associatedtype Binding: BindingObject
    associatedtype Output: OutputObject

    var input: Input { get }
    var binding: Binding { get }
    var output: Output { get }
}

extension ViewModelObject where Binding.ObjectWillChangePublisher == ObservableObjectPublisher, Output.ObjectWillChangePublisher == ObservableObjectPublisher {
    var objectWillChange: AnyPublisher<Void, Never> {
        Publishers.Merge(binding.objectWillChange, output.objectWillChange).eraseToAnyPublisher()
    }
}

// MARK: - InputObject
protocol InputObject: AnyObject {
}

// MARK: - BindingObject
protocol BindingObject: ObservableObject {
}

// MARK: - OutputObject
protocol OutputObject: ObservableObject {
}
