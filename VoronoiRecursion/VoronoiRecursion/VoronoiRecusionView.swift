//
//  VoronoiRecusionView.swift
//  VoronoiRecursion
//
//  Created by Nick Zemtzov on 6/12/21.
//
import ScreenSaver

class VoronoiRecursion: ScreenSaverView {
    struct seedPoint {
        var position = CGPoint.zero
        //var color: NSColor
        //var isInFrame: Bool
        //var velocity = CGVector.zero
    }
    struct point {
        var position = CGPoint.zero
        var closestSeed = 0
        //var color: NSColor
        //var isInFrame: Bool
        //var velocity = CGVector.zero
    }
    
    private var numPoints = 2
    private var frame1Seeds = [seedPoint]()
    private var frame1Points = [point]()

    private var frame2Seeds = [seedPoint]()
    private var frame1Seeds = [point]()

    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        for _ in 0..<numPoints {
            let x = Int.random(in: 0..<frame.width)
            let y = Int.random(in: 0..<frame.height)
            frame1Seeds.append(seedPoint(position: CGPoint(x:CGFloat(x), y:CGFloat(y))))//, color: NSColor.init(red: 1.0, green: 1.0, blue: 1.0)))
        }

        for x in 0..<frame.width {
            for y in 0..<frame.height {
                frame1Points.append(seedPoint(position: CGPoint(x:CGFloat(x), y:CGFloat(y))))
                
                var minimumPoint = 0
                var minimumDistance: CGFloat = distanceBetweenTwoPoints(p1: frame1Points[x*y+y], p2: frame1Seeds[0])
                for p in 1..<numPoints {
                    var newDistance = distanceBetweenTwoPoints(p1: frame1Points[x*y+y], p2: frame1Seeds[0])
                    if newDistance < minimumDistance {
                        minimumDistance = newDistance
                        minimumPoint = p
                    }
                }
                
            }
        }

    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        // Draw a single frame in this function
    }

    override func animateOneFrame() {
        super.animateOneFrame()

        // Update the "state" of the screensaver in this function
    }
    
    private func distanceBetweenTwoPoints(p1: point, p2: seedPoint) -> CGFloat{
        return (pow(p1.position.x - p2.position.x,2) + pow(p1.position.y - p2.position.y,2)).squareRoot()
    }

}
