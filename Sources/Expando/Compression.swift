//
//  Compression.swift
//  expando
//
//  Created by Yosef Brown on 2017-01-02.
//  Copyright © 2017 Quantum Cheese Coding, LLC. All rights reserved.
//

import Foundation

// use empty enum as namespace
fileprivate enum Bits {
  static let One = UInt8(1)
  static let MaxNumberOfBits = UInt8(8)
}

public struct Compression {

    enum BoundaryConditions: Error {
        case emptyData
        case byteIndexTooHigh(index: Int)
        case bitIndexTooHigh(index: UInt8)
    }

    public static func startsWithZeroBit(bytes: Data) throws -> Bool {
        if bytes.isEmpty {
            throw BoundaryConditions.emptyData
        }

        return 0 == (bytes[0] & Bits.One)
    }

    public static func consecutiveBitsFromPosition(bytes: Data,
                                            byteIndex startingByteIndex: Int,
                                            bitIndex startingBitIndex: UInt8) throws -> Int {
        if bytes.isEmpty {
            throw BoundaryConditions.emptyData
        }
        if bytes.count <= startingByteIndex {
            throw BoundaryConditions.byteIndexTooHigh(index: startingByteIndex)
        }
        if Bits.MaxNumberOfBits <= startingBitIndex {
            throw BoundaryConditions.bitIndexTooHigh(index: startingBitIndex)
        }

        var byteIndex = startingByteIndex
        var bitIndex = startingBitIndex
        // get the bit at the current position
        var byte = bytes[byteIndex]
        let bitmask = (byte >> bitIndex) & Bits.One

        var count = 0
        while bitmask == ((byte >> bitIndex) & Bits.One) {
            count += 1
            bitIndex += 1
            if Bits.MaxNumberOfBits == bitIndex {
                bitIndex = 0
                byteIndex += 1
                if byteIndex == bytes.count {
                    break
                }
                byte = bytes[byteIndex]
            }
        }

        return count
    }

/*
    func countInitialZeros(_ data: Data) -> Int {
        var count = 0

        data.forEach({(_ byte: UInt8) -> () in
            for i in (0..<8).reversed() {
                let bitmask = (UInt8(1) << UInt8(i))
                let maskedByte = byte & bitmask
                if (0 != maskedByte) {
                    break
                }
                count += 1
            }
        })
        return count
    }
 */
}