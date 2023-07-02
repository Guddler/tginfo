//
//  main.swift
//  tgdump
//
//  Created by Martin White on 01/07/2023.
//

import Foundation
import ArgumentParser

// Maybe one day...
enum Language: String, CaseIterable, ExpressibleByArgument {
    case C
    case JAVA
}

func sizeOfFile(atPath path: String) -> Double {
    let attributes = try! FileManager.default.attributesOfItem(atPath: path)
    return attributes[.size] as? Double ?? 0
}

@main
struct App: ParsableCommand {
    
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "tginfo",
                                abstract: """
Dump header information from a TGA image
file. The dump can optionally output the image and
colour map data as a C/C++ header file.
""")}
    
    @Flag(name: .shortAndLong, help: "Provide extra info")
    var verbose: Bool = false
    
    @Flag(name: [.customShort("c"), .long], help: "Output as language file")
    var outputCode: Bool = false

    @Argument(help: "Full path and file name of TGA file")
    var inputFile: String
    
    mutating func run() {
        if sizeOfFile(atPath: inputFile) < 18 {
            print("File not big enough to contain TGA header")
            return
        }
        
        print("File: \(inputFile)")
        let handle = FileHandle.init(forReadingAtPath: inputFile)
        
        if let header: Header = handle?.readHeader() {
            print(header.toString(verbose: verbose))
        } else {
            print("Error reading header from file")
        }
    }
}
