//
//  Matrix4x4.swift
//  Harbeth
//
//  Created by Condy on 2022/2/23.
//

import Foundation

/// 常见4x4颜色矩阵，考线性代数时刻😪
/// 第一行的值决定了红色值，第二行决定绿色，第三行蓝色，第四行是透明通道值
/// Common 4x4 color matrix
extension Matrix4x4 {
    
    public static let identity = Matrix4x4(values: [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
    
    /// 棕褐色，老照片
    public static let sepia = Matrix4x4(values: [
        0.3588, 0.7044, 0.1368, 0.0,
        0.2990, 0.5870, 0.1140, 0.0,
        0.2392, 0.4696, 0.0912, 0.0,
        0.0000, 0.0000, 0.0000, 1.0,
    ])
    
    /// 复古效果
    public static let retroStyle = Matrix4x4(values: [
        0.50, 0.50, 0.50, 0.0,
        0.33, 0.33, 0.33, 0.0,
        0.25, 0.25, 0.25, 0.0,
        0.00, 0.00, 0.00, 1.0,
    ])
    
    /// 绿色通道加倍
    public static let greenDouble = Matrix4x4(values: [
        1.0, 0.0, 0.0, 0.0,
        0.0, 2.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
    
    /// 天蓝色变绿色，天蓝色是由绿色和蓝色叠加
    public static let skyblue_turns_green = Matrix4x4(values: [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
    
    /// 灰度图矩阵
    public static let gray = Matrix4x4(values: [
        0.33, 0.33, 0.33, 0.0,
        0.33, 0.33, 0.33, 0.0,
        0.33, 0.33, 0.33, 0.0,
        0.00, 0.00, 0.00, 1.0,
    ])
    
    /// 去掉绿色和蓝色
    public static let remove_green_blue = Matrix4x4(values: [
        1.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
    
    /// 红色绿色对调位置
    public static let replaced_red_green = Matrix4x4(values: [
        0.0, 1.0, 0.0, 0.0,
        1.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ])
}
