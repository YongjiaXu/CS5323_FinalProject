// The MIT License (MIT)
// Copyright © 2021 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/**
 SPConfetti: Wrapper of particles settings.
 */
public struct SPConfettiParticlesConfig {
    
    /**
     SPConfetti: Fill image with color.
     If disabled, image will use without any fill color.
     */
    public var colored: Bool = true
    
    /**
     SPConfetti: Style of particles. Can be custom image.
     */
    public var colors: [UIColor] = [UIColor(rgb: 0xe599d4),  UIColor(rgb: 0x6ac0fa), UIColor(rgb: 0xeb593a), UIColor(rgb: 0xee8335), UIColor(rgb: 0xf6c950)]
    
    /**
     SPConfetti: The number of emitted objects created every second.
     */
    public var birthRate: Float = 80
    
    /**
     SPConfetti: The lifetime of the cell, in second.
     */
    public var lifetime: Float = 14
    
    /**
     SPConfetti: The initial velocity of the cell.
     */
    public var velocity: CGFloat = 400
    
    /**
     SPConfetti: The amount by which the velocity of the cell can vary.
     */
    public var velocityRange: CGFloat = 40
    
    /**
     SPConfetti: The rotational velocity, measured in radians per second, to apply to the cell.
     */
    public var spin: CGFloat = 1.75
    
    /**
     SPConfetti: The amount by which the spin of the cell can vary over its lifetime.
     */
    public var spinRange: CGFloat = 2
    
    /**
     SPConfetti: Default element side size factor.
     
     Calculated of parent width.
     */
    public var particleSideSizeFactor: CGFloat = 0.03
    
    /**
     SPConfetti: The scale factor.
     */
    public var contentsScale: CGFloat = 0.5
    /**
     SPConfetti: Specifies the range over which the scale value can vary.
     */
    public var scaleRange: CGFloat = 1
    
    /**
     SPConfetti: The speed at which the scale changes over the lifetime of the cell.
     */
    public var scaleSpeed: CGFloat = -0.05
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
