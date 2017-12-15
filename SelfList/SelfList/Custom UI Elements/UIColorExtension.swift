//
//  UIColorExtension.swift
//  SelfList
//
//  Created by Charles Penunia on 12/8/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//
//  Brightness formula source: https://www.w3.org/TR/AERT/#color-contrast
import Foundation
import UIKit

let brightnessThreshold: CGFloat = 190.0

extension UIColor {
    var brightness: CGFloat {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)
        let brightness = 255 * (red * 299 + green * 587 + blue * 114) / 1000
        return brightness
    }
    class func generateBrightColor() -> UIColor {
        var randomColor: UIColor?
        repeat {
            let redRandom: CGFloat = CGFloat(arc4random_uniform(UInt32(256))) / 255.0
            let greenRandom: CGFloat = CGFloat(arc4random_uniform(UInt32(256))) / 255.0
            let blueRandom: CGFloat = CGFloat(arc4random_uniform(UInt32(256))) / 255.0
            randomColor = UIColor(red: redRandom, green: greenRandom, blue: blueRandom, alpha: 1.0)
        } while randomColor!.brightness < brightnessThreshold
        return randomColor!
    }
}
