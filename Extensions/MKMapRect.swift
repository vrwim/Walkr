//
//  MKMapRect.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 07/09/2021.
//

import MapKit

extension MKMapRect: Equatable {
    public static func == (lhs: MKMapRect, rhs: MKMapRect) -> Bool {
        lhs.origin == rhs.origin && lhs.size == rhs.size
    }
}

extension MKMapPoint: Equatable {
    public static func == (lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension MKMapSize: Equatable {
    public static func == (lhs: MKMapSize, rhs: MKMapSize) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
}
