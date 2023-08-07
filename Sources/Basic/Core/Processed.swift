//
//  Processed.swift
//  Harbeth
//
//  Created by Condy on 2022/2/13.
//

import Foundation
import MetalKit
import MetalPerformanceShaders
import CoreImage

internal struct Processed {
    
    /// Create a new texture based on the filter content.
    /// Synchronously wait for the execution of the Metal command buffer to complete.
    /// - Parameters:
    ///   - intexture: Input texture
    ///   - outTexture: Output texture
    ///   - filter: It must be an object implementing C7FilterProtocol
    /// - Returns: Output texture after processing
    @inlinable @discardableResult static func IO(inTexture: MTLTexture, outTexture: MTLTexture, filter: C7FilterProtocol) throws -> MTLTexture {
        if case .coreimage(let name) = filter.modifier {
            return try filter.renderCoreImage(with: inTexture, name: name)
        }
        let (commandBuffer, destTexture) = try filter.applyAtTexture(form: inTexture, to: outTexture)
        // Commit a command buffer so it can be executed as soon as possible.
        commandBuffer.commit()
        // Wait to make sure that output texture contains new data.
        commandBuffer.waitUntilCompleted()
        return destTexture
    }
    
    /// Whether to synchronously wait for the execution of the Metal command buffer to complete.
    /// - Parameters:
    ///   - intexture: Input texture
    ///   - outTexture: Output texture
    ///   - filter: It must be an object implementing C7FilterProtocol
    ///   - complete: Add a block to be called when this command buffer has completed execution.
    static func runAsynIO(inTexture: MTLTexture, outTexture: MTLTexture, filter: C7FilterProtocol, complete: @escaping (Result<MTLTexture, CustomError>) -> Void) {
        if case .coreimage(let name) = filter.modifier {
            filter.renderCoreImage(with: inTexture, name: name, complete: complete)
            return
        }
        do {
            let (commandBuffer, destTexture) = try filter.applyAtTexture(form: inTexture, to: outTexture)
            commandBuffer.addCompletedHandler { (buffer) in
                switch buffer.status {
                case .completed:
                    complete(.success(destTexture))
                case .error where buffer.error != nil:
                    complete(.failure(.error(buffer.error!)))
                default:
                    break
                }
            }
            commandBuffer.commit()
        } catch {
            complete(.failure(CustomError.toCustomError(error)))
        }
    }
}

extension C7FilterProtocol {
    
    /// Add the filter into the output texture.
    func applyAtTexture(form sourceTexture: MTLTexture, to destinationTexture: MTLTexture) throws -> (MTLCommandBuffer, MTLTexture) {
        guard let commandBuffer = Device.commandQueue().makeCommandBuffer() else {
            throw CustomError.commandBuffer
        }
        switch self.modifier {
        case .compute(let kernel):
            let pipelineState = try Compute.makeComputePipelineState(with: kernel)
            var textures = [destinationTexture, sourceTexture]
            textures += self.otherInputTextures
            Compute.drawingProcess(pipelineState, commandBuffer: commandBuffer, textures: textures, filter: self)
            return (commandBuffer, destinationTexture)
        case .render(let vertex, let fragment):
            let pipelineState = try Rendering.makeRenderPipelineState(with: vertex, fragment: fragment)
            Rendering.drawingProcess(pipelineState, commandBuffer: commandBuffer, texture: sourceTexture, filter: self)
            return (commandBuffer, destinationTexture)
        case .mps:
            var textures = [destinationTexture, sourceTexture]
            textures += self.otherInputTextures
            let destTexture = try (self as! MPSKernelProtocol).encode(commandBuffer: commandBuffer, textures: textures)
            return (commandBuffer, destTexture)
        default:
            return (commandBuffer, destinationTexture)            
        }
    }
    
    /// Metal texture compatibility uses CoreImage filter.
    func renderCoreImage(with texture: MTLTexture, name: String) throws -> MTLTexture {
        let outputImage = try outputCIImage(with: texture, name: name)
        try outputImage.mt.renderImageToTexture(texture, colorSpace: Device.colorSpace())
        return texture
    }
    
    func renderCoreImage(with texture: MTLTexture, name: String, complete: @escaping (Result<MTLTexture, CustomError>) -> Void) {
        do {
            let outputImage = try outputCIImage(with: texture, name: name)
            outputImage.mt.writeCIImageAtTexture(texture, complete: complete, colorSpace: Device.colorSpace())
        } catch {
            complete(.failure(CustomError.toCustomError(error)))
        }
    }
    
    private func outputCIImage(with texture: MTLTexture, name: String) throws -> CIImage {
        guard let cgImage = texture.mt.toCGImage() else {
            throw CustomError.texture2CGImage
        }
        guard let ciFiter = CIFilter.init(name: name) else {
            throw CustomError.createCIFilter(name)
        }
        let inputCIImage = CIImage.init(cgImage: cgImage)
        let ciImage = try (self as! CoreImageProtocol).coreImageApply(filter: ciFiter, input: inputCIImage)
        ciFiter.setValue(ciImage, forKeyPath: kCIInputImageKey)
        guard let outputImage = ciFiter.outputImage else {
            throw CustomError.outputCIImage(name)
        }
        // Return a new image cropped to a rectangle.
        return outputImage.cropped(to: inputCIImage.extent)
    }
}
