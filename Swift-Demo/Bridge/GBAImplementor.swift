//
//  GBAImplementor.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/2.
//

import UIKit

class GBAImplementor: AbstractImplementor {
    
    override func loadCommand(command: ECommandType) {
        switch command {
        case .kUp:
            print("GBA up")
            break
        case .kDown:
            print("GBA down")
            break
        case .kLeft:
            print("GBA left")
            break
        case .kRight:
            print("GBA right")
            break
        case .kA:
            print("GBA A")
            break
        case .kB:
            print("GBA B")
            break
        default:
            print("GBA none")
        }
    }

}
