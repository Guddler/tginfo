//
//  tgaFile.swift
//  tgdump
//
//  Created by Martin White on 01/07/2023.
//

import Foundation

public extension FileHandle {
    func readHeader() -> Header? {
        let length = 18
        let header: Header

        do {
            let data = try read(upToCount: length)
            // Maybe a dubious way to do? Seems horribly verbose
            let colourMap = CMap(
                firstEntryIndex: wordFrom(inputData: data!, atOffset: 3),
                mapLength: wordFrom(inputData: data!, atOffset: 5),
                mapEntrySize: data![7])
            
            let image = ImageSpecification(
                xOrigin: wordFrom(inputData: data!, atOffset: 8),
                yOrigin: wordFrom(inputData: data!, atOffset: 10),
                width: wordFrom(inputData: data!, atOffset: 12),
                height: wordFrom(inputData: data!, atOffset: 14),
                pixelDepth: data![16],
                imageDescriptor: data![17])
            
            header = Header(
                idLen: data![0],
                mapType: data![1],
                imageType: data![2],
                colourMapSpec: colourMap,
                image: image
            )
        } catch {
            return nil
        }
        return header
    }

    func wordFrom(inputData d: Data, atOffset o: Int) -> UInt16 {
        UInt16(d[o + 1]) << 8 + UInt16(d[o])
    }
}

public struct Header {
    let idLen: UInt8
    let mapType: UInt8
    let imageType: UInt8
    let colourMapSpec: CMap
    let image: ImageSpecification
    
    func toString(verbose: Bool = false) -> String {
        if verbose {
        """
Header
----------------------------------------------------
ID Field Length     : \(idLen)
Colour Map?         : \(mapType == 0 ? "NO" : "YES")
Image Type          : \(parseImageType() )
Colour Map          :
\(colourMapSpec.toString())
Image Specification :
\(image.toString())
"""
        } else {
            if mapType == 1 {
                "\(parseImageType()) image, \(colourMapSpec.mapEntrySize)bit map, \(image.width)x\(image.height)"
            } else {
                "\(parseImageType()) image, no colour map, \(image.width)x\(image.height)"
            }
        }
    }
    
    func parseImageType() -> String {
        switch imageType {
        case 0 :
            "No image data"
        case 1:
            "Uncompressed color-mapped"
        case 2:
            "Uncompressed true-color"
        case 3:
            "Uncompressed black-and-white (grayscale)"
        case 4:
            "Run-length encoded color-mapped"
        case 5:
            "Run-length encoded true-color"
        case 6:
            "Run-length encoded black-and-white (grayscale)"
        default:
            "UNKNOWN !!"
        }
    }
}

public struct CMap {
    var firstEntryIndex: UInt16
    var mapLength: UInt16
    var mapEntrySize: UInt8
    
    func toString() -> String {
        """
\tFirst Entry   : \(firstEntryIndex)
\tMap Length    : \(mapLength)
\tEntry Size    : \(mapEntrySize)bit
"""
    }
}

public struct ImageSpecification {
    var xOrigin: UInt16
    var yOrigin: UInt16
    var width: UInt16
    var height: UInt16
    var pixelDepth: UInt8
    var imageDescriptor: UInt8      // Bitwise field, need further splitting
    
    func toString() -> String {
        """
\tX Origin      : \(xOrigin)
\tY Origin      : \(yOrigin)
\tWidth         : \(width)
\tHeight        : \(height)
\tPixel Depth   : \(pixelDepth)
\tDescriptor    : \(parseDescriptor())
"""
    }
    
    func parseDescriptor() -> String {
        let horizontalOrdering = (imageDescriptor & (1 << 4)) == 1 ? "right to left" : "left to right"
        let verticalOrdering = (imageDescriptor & (1 << 5)) == 1 ? "top to bottom" : "bottom to top"
        
        return "Ordering: \(horizontalOrdering), \(verticalOrdering), \(imageDescriptor & 15)bit alpha channel"
    }

}


//Image descriptor (1 byte): bits 3-0 give the alpha channel depth, bits 5-4 give pixel ordering
//Bit 4 of the image descriptor byte indicates right-to-left pixel ordering if set. Bit 5 indicates an ordering of top-to-bottom. Otherwise, pixels are stored in bottom-to-top, left-to-right order.
