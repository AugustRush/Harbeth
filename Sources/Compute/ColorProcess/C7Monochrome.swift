//
//  C7Monochrome.swift
//  ATMetalBand
//
//  Created by Condy on 2022/2/15.
//

import Foundation

/// 将图像转换为单色版本，根据每个像素的亮度进行着色
public struct C7Monochrome: C7FilterProtocol {
    
    public static let range: ParameterRange<Float, Self> = .init(min: 0.0, max: 1.0, value: 0.0)
    
    /// The degree to which the specific color replaces the normal image color, from 0.0 to 1.0, with 0.0 as the default.
    public var intensity: Float = range.value
    /// Keep the color scheme
    public var color: C7Color = .zero {
        didSet {
            color.mt.toRGB(red: &red, green: &green, blue: &blue)
        }
    }
    
    private var red: Float = 1
    private var green: Float = 1
    private var blue: Float = 1
    
    public var modifier: Modifier {
        return .compute(kernel: "C7Monochrome")
    }
    
    public var factors: [Float] {
        return [intensity, red, green, blue]
    }
    
    public init() { }
}
