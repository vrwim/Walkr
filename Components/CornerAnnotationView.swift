//
//  CornerAnnotationView.swift
//  Walkr (iOS)
//

import MapKit

/// A large draggable circle handle shown at each corner of an ImageOverlay during fine-tuning.
class CornerAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "CornerAnnotationView"

    private let circleSize: CGFloat = 28

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isDraggable = true
        canShowCallout = false

        let circle = UIView(frame: CGRect(x: 0, y: 0, width: circleSize, height: circleSize))
        circle.backgroundColor = UIColor.systemBlue
        circle.layer.cornerRadius = circleSize / 2
        circle.layer.borderColor = UIColor.white.cgColor
        circle.layer.borderWidth = 2
        circle.layer.shadowColor = UIColor.black.cgColor
        circle.layer.shadowOpacity = 0.3
        circle.layer.shadowRadius = 3
        circle.layer.shadowOffset = CGSize(width: 0, height: 1)

        frame = CGRect(x: 0, y: 0, width: circleSize, height: circleSize)
        addSubview(circle)
        centerOffset = .zero
    }
}
