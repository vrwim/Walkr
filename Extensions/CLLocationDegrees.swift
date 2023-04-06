//
//  CLLocationDegrees.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 06/04/2023.
//

import CoreLocation

extension CLLocationDegrees {
    var dms: (degrees: Int, minutes: Int, seconds: Int) {
        var seconds = Int(self * 3600)
        let degrees = seconds / 3600
        seconds = abs(seconds % 3600)
        return (degrees, seconds / 60, seconds % 60)
    }
}

extension CLLocationCoordinate2D {
    var latitudeString: String {
        let (degrees, minutes, seconds) = latitude.dms
        return "\(abs(degrees))° \(minutes)' \(seconds)\" \(degrees >= 0 ? "N" : "S")"
    }
    
    var longitudeString: String {
        let (degrees, minutes, seconds) = longitude.dms
        return "\(abs(degrees))° \(minutes)' \(seconds)\" \(degrees >= 0 ? "E" : "W")"
    }
}
