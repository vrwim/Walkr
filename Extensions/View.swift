//
//  View.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 07/09/2021.
//

import SwiftUI

extension View {
    func andPrint(_ obj: Any) -> some View {
        print(obj)
        return self
    }
}
