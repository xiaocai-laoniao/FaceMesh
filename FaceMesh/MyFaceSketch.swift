//
//  MyFaceSketch.swift
//  MyFaceSketch
//
//  Created by ChildhoodAndy on 2021/9/5.
//

import Foundation
import SwiftProcessing

class MyFaceSketch: Sketch, SketchDelegate {
    
    func setup() {
        faceMode()
    }
    
    func draw() {
        if frameCount % 200 == 0 {
            background(random(255), random(255), random(255))
        }
//        fill(255, 0, 0)
//        circle(125, 125, 50)
    }
}
