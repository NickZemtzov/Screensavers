//
//  ChaosVisualizer.swift
//  ChaosSaver
//
//  Created by Nick Zemtzov on 12/2/20.
//

import ScreenSaver

class ChaosVisualizer: ScreenSaverView {
    struct planet {
        var position = CGPoint.zero
        var velocity = CGVector.zero
        var mass: CGFloat = 10
        var force = CGVector.zero
        var Color: NSColor = .black
    }
    private var currentPlanets = [planet]()
    private let initialNumPlanets = 100
    private var centerOfMass = CGPoint.zero
    private var centerOfMassVelocity = CGVector.zero
    private let GravitionalConstant: CGFloat = 0.01
    private let damper: CGFloat = 20
    private let BackgroundColor = NSColor(red:0, green:0, blue:0, alpha:0.01)

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        var xVelocity: CGFloat = 0
        var yVelocity: CGFloat = 0
        var xPosition: CGFloat = 0
        var yPosition: CGFloat = 0
        for _ in 0..<initialNumPlanets{
            xVelocity = CGFloat.random(in: -2...2)
            yVelocity = CGFloat.random(in: -2...2)
            xPosition = CGFloat.random(in: 0..<frame.width)
            yPosition = CGFloat.random(in: 0..<frame.height)
            currentPlanets.append(planet(position: CGPoint(x:xPosition, y:yPosition), velocity:CGVector(dx:xVelocity, dy:yVelocity)))
            centerOfMass.x += xPosition-(frame.width / 2)
            centerOfMass.y += yPosition-(frame.height / 2)
            centerOfMassVelocity.dx += xVelocity
            centerOfMassVelocity.dy += yVelocity
        }
    }
    
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: NSRect) {
        drawBackground(BackgroundColor)
        for planet in 0..<currentPlanets.count {
            drawPlanet(p: currentPlanets[planet])
        }
    }
    override func animateOneFrame() {
        super.animateOneFrame()
        var xForce: CGFloat = 0
        var yForce: CGFloat = 0
        var velocities: [CGFloat] = []
        for planet in 0..<currentPlanets.count {
            currentPlanets[planet].position.x += currentPlanets[planet].velocity.dx
            currentPlanets[planet].position.y += currentPlanets[planet].velocity.dy
            xForce = 0
            yForce = 0
            for i in 0..<currentPlanets.count{
                if i != planet {
                    xForce += (currentPlanets[i].position.x-currentPlanets[planet].position.x)*GravitionalConstant*currentPlanets[planet].mass*currentPlanets[i].mass/(pow((currentPlanets[i].position.x-currentPlanets[planet].position.x),2)+pow((currentPlanets[i].position.y-currentPlanets[planet].position.y),2))
                    yForce += (currentPlanets[i].position.y-currentPlanets[planet].position.y)*GravitionalConstant*currentPlanets[planet].mass*currentPlanets[i].mass/(pow((currentPlanets[i].position.x-currentPlanets[planet].position.x),2)+pow((currentPlanets[i].position.y-currentPlanets[planet].position.y),2))
                }
            }
            currentPlanets[planet].velocity.dx += xForce//update velocities with force
            currentPlanets[planet].velocity.dy += yForce
            if (pow(currentPlanets[planet].velocity.dx,2)+pow(currentPlanets[planet].velocity.dy,2)).squareRoot() > damper{
                currentPlanets[planet].velocity.dx *= 0.9
                currentPlanets[planet].velocity.dy *= 0.9
            }
            velocities.append((pow(currentPlanets[planet].velocity.dx,2)+pow(currentPlanets[planet].velocity.dy,2)).squareRoot())//add velocity magnitudes to array to normalize
            if currentPlanets[planet].position.x < -10 {
                currentPlanets[planet].position.x = bounds.width + 10
            }
            if currentPlanets[planet].position.y < -10 {
                currentPlanets[planet].position.y = bounds.height + 10
            }
            if currentPlanets[planet].position.x>bounds.width+10 {
                currentPlanets[planet].position.x = -10
            }
            if currentPlanets[planet].position.y>bounds.height+10 {
                currentPlanets[planet].position.y = -10
            }
        }
        var min: CGFloat = velocities[0]
        var max: CGFloat = velocities[0]
        for vel in 0..<velocities.count{
            if velocities[vel] > max {
                max = velocities[vel]
            }
            if velocities[vel] < min {
                min = velocities[vel]
            }
        }
        for vel in 0..<velocities.count{
            velocities[vel] = (velocities[vel]-min)/(max-min)
        }
        for planet in 0..<currentPlanets.count {
            currentPlanets[planet].Color = NSColor.init(hue: 1-velocities[planet],
                                                        saturation: 1-velocities[planet],
                                                        brightness: 1,
                                                        alpha: 1)
        }
        setNeedsDisplay(bounds)
    }
    
    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }
    private func drawPlanet(p: planet) {
        let ballRect = NSRect(x: p.position.x,
                              y: p.position.y,
                              width: 10,
                              height: 10)
        let ball = NSBezierPath(roundedRect: ballRect,
                                xRadius: 10,
                                yRadius: 10)
        p.Color.setFill()
        ball.fill()
    }
}
    /*
    private var ballPosition: CGPoint = .zero
    private var ballVelocity: CGVector = .zero
    private var paddlePosition: CGFloat = 0
    private let ballRadius: CGFloat = 15
    private let paddleBottomOffset: CGFloat = 100
    private let paddleSize = NSSize(width: 60, height: 20)

    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        ballPosition = CGPoint(x: frame.width / 2, y: frame.height / 2)
        ballVelocity = initialVelocity()
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        drawBackground(.white)
        drawBall()
        drawPaddle()
    }

    override func animateOneFrame() {
        super.animateOneFrame()

        let oobAxes = ballIsOOB()
        if oobAxes.xAxis {
            ballVelocity.dx *= -1
        }
        if oobAxes.yAxis {
            ballVelocity.dy *= -1
        }

        let paddleContact = ballHitPaddle()
        if paddleContact {
            ballVelocity.dy *= -1
        }

        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy
        paddlePosition = ballPosition.x

        setNeedsDisplay(bounds)
    }

    // MARK: - Helper Functions
    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }

    private func drawBall() {
        let ballRect = NSRect(x: ballPosition.x - ballRadius,
                              y: ballPosition.y - ballRadius,
                              width: ballRadius * 2,
                              height: ballRadius * 2)
        let ball = NSBezierPath(roundedRect: ballRect,
                                xRadius: ballRadius,
                                yRadius: ballRadius)
        NSColor.black.setFill()
        ball.fill()
    }

    private func drawPaddle() {
        let paddleRect = NSRect(x: paddlePosition - paddleSize.width / 2,
                                y: paddleBottomOffset - paddleSize.height / 2,
                                width: paddleSize.width,
                                height: paddleSize.height)
        let paddle = NSBezierPath(rect: paddleRect)
        NSColor.black.setFill()
        paddle.fill()
    }

    private func initialVelocity() -> CGVector {
        let desiredVelocityMagnitude: CGFloat = 10
        let xVelocity = CGFloat.random(in: 2.5...7.5)
        let xSign: CGFloat = Bool.random() ? 1 : -1
        let yVelocity = sqrt(pow(desiredVelocityMagnitude, 2) - pow(xVelocity, 2))
        let ySign: CGFloat = Bool.random() ? 1 : -1
        return CGVector(dx: xVelocity * xSign, dy: yVelocity * ySign)
    }

    private func ballIsOOB() -> (xAxis: Bool, yAxis: Bool) {
        let xAxisOOB = ballPosition.x - ballRadius <= 0 ||
            ballPosition.x + ballRadius >= bounds.width
        let yAxisOOB = ballPosition.y - ballRadius <= 0 ||
            ballPosition.y + ballRadius >= bounds.height
        return (xAxisOOB, yAxisOOB)
    }

    private func ballHitPaddle() -> Bool {
        let xBounds = (lower: paddlePosition - paddleSize.width / 2,
                       upper: paddlePosition + paddleSize.width / 2)
        let yBounds = (lower: paddleBottomOffset - paddleSize.height / 2,
                       upper: paddleBottomOffset + paddleSize.height / 2)
        return ballPosition.x >= xBounds.lower &&
            ballPosition.x <= xBounds.upper &&
            ballPosition.y - ballRadius >= yBounds.lower &&
            ballPosition.y - ballRadius <= yBounds.upper
    }

}*/
