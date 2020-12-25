//
//  PSPImplementor.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/2.
//

import UIKit

class PSPImplementor: AbstractImplementor {
    override func loadCommand(command: ECommandType) {
        switch command {
        case .kUp:
            print("PSP up")
            break
        case .kDown:
            print("PSP down")
            break
        case .kLeft:
            print("PSP left")
            break
        case .kRight:
            print("PSP right")
            break
        case .kA:
            print("PSP A")
            break
        case .kB:
            print("PSP B")
            break
        default:
            print("PSP none")
        }
    }
}
