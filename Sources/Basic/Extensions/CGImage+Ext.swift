//
//  CGImage+Ext.swift
//  Harbeth
//
//  Created by Condy on 2022/10/9.
//

import Foundation
import MetalKit
import CoreGraphics
import CoreVideo

extension CGImage: C7Compatible { }

extension Queen where Base: CGImage {
    
    /// CGImage to texture
    ///
    /// Texture loader can not load image data to create texture
    /// Draw image and create texture
    /// - Parameter pixelFormat: Indicates the pixelFormat, The format of the picture should be consistent with the data.
    /// - Returns: MTLTexture
    public func toTexture(pixelFormat: MTLPixelFormat = .rgba8Unorm) -> MTLTexture? {
        let width = base.width, height = base.height
        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = pixelFormat
        descriptor.width  = width
        descriptor.height = height
        descriptor.usage  = [MTLTextureUsage.shaderRead, MTLTextureUsage.shaderWrite]
        guard let texture = Device.device().makeTexture(descriptor: descriptor) else {
            return nil
        }
        
        let bytesPerPixel: Int = 4
        let bytesPerRow = width * bytesPerPixel
        let context = CGContext(data: nil, width: width, height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: Device.colorSpace(),
                                bitmapInfo: Device.bitmapInfo())
        context?.draw(base, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let data = context?.data else {
            return nil
        }
        let region = MTLRegionMake3D(0, 0, 0, width, height, 1)
        texture.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: bytesPerRow)
        return texture
    }
    
    /// Creates a new Metal texture from a given bitmap image.
    /// - Parameter options: Dictonary of MTKTextureLoaderOptions
    /// - Returns: MTLTexture
    public func newTexture(options: [MTKTextureLoader.Option: Any]? = nil) -> MTLTexture? {
        let usage: MTLTextureUsage = [.shaderRead, .shaderWrite]
        let textureOptions: [MTKTextureLoader.Option: Any] = options ?? [
            .textureUsage: NSNumber(value: usage.rawValue),
            .generateMipmaps: NSNumber(value: false),
            .SRGB: NSNumber(value: false)
        ]
        let loader = Shared.shared.device?.textureLoader
        return try? loader?.newTexture(cgImage: base, options: textureOptions)
    }
    
    public func toPixelBuffer() -> CVPixelBuffer? {
        let imageWidth = Int(base.width)
        let imageHeight = Int(base.height)
        let attributes: [NSObject:AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
        ]
        var pxbuffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault,
                            imageWidth,
                            imageHeight,
                            kCVPixelFormatType_32ARGB,
                            attributes as CFDictionary?,
                            &pxbuffer)
        guard let pxbuffer = pxbuffer else {
            return nil
        }
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        CVPixelBufferLockBaseAddress(pxbuffer, flags)
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata,
                                width: imageWidth,
                                height: imageHeight,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        if let context = context {
            context.draw(base, in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
        } else {
            CVPixelBufferUnlockBaseAddress(pxbuffer, flags);
            return nil
        }
        CVPixelBufferUnlockBaseAddress(pxbuffer, flags);
        return pxbuffer
    }
    
    public func toC7Image() -> C7Image {
        #if os(iOS) || os(tvOS) || os(watchOS)
        return UIImage.init(cgImage: base)
        #elseif os(macOS)
        return NSImage(cgImage: base, size: .init(width: base.width, height: base.height))
        #else
        #error("Unsupported Platform")
        #endif
    }
}

extension Queen where Base: CGImage {
    
    public var hasAlphaChannel: Bool {
        switch base.alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true
        default:
            return false
        }
    }
    
    #if os(iOS) || os(tvOS) || os(watchOS)
    public var size: CGSize {
        CGSize(width: base.width, height: base.height)
    }
    #elseif os(macOS)
    public var size: NSSize {
        NSSize(width: base.width, height: base.height)
    }
    #endif
}
