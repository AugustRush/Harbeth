//
//  C7LuminanceThreshold.swift
//  MetalQueenDemo
//
//  Created by Condy on 2021/8/8.
//

import Foundation

/// 阈值滤镜 阈值的大小是动态（根据图片情况）
public struct C7LuminanceThreshold: C7FilterProtocol {
    
    public var threshold: Float = 0.5
    
    public var modifier: Modifier {
        return .compute(kernel: "LuminanceThreshold")
    }
    
    public var factors: [Float] {
        return [threshold]
    }
    
    public init() { }
}