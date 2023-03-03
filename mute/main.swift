//
//  main.swift
//  mute
//
//  Created by Alexander Lais on 03.03.23.
//

import ArgumentParser
import CoreAudio
import Foundation

enum MuteMode: Int, Codable, ExpressibleByArgument {
    case Unmute = 0
    case Mute = 1
    case Toggle = 2
}

enum DeviceType: String, Codable, ExpressibleByArgument {
    case Input = "input"
    case Output = "output"
    case System = "system"
}

struct MuteOptions: ParsableArguments {
    @Option(help: ArgumentHelp("Mute mode", discussion: "Allows to mute, unmute or toggle the mute state of the selected device"))
    var mute: MuteMode = .Toggle

    @Option(help: ArgumentHelp("Input or output", discussion: "Selects the input or output channels for the selected device"))
    var type: DeviceType = .Input
    
    @Option(help: ArgumentHelp("Device name, UUID or ID"))
    var device: String? = nil
    
    @Flag(name: .shortAndLong, help: "Verbose output.")
    var verbose = false
}





// If you prefer writing in a "script" style, you can call `parseOrExit()` to
// parse a single `ParsableArguments` type from command-line arguments.
let options = MuteOptions.parseOrExit()

if options.verbose {
    print("Verbose!")
}

let deviceId = getDefaultDeviceID(type: options.type)


print("device: \(deviceId!), name: \(getDeviceName(device: deviceId!)), type: \(options.type), mode: \(options.mute)")

setMute(device: deviceId!, type: options.type, mute: options.mute)

