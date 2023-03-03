//
//  audio.swift
//  mute
//
//  Created by Alexander Lais on 03.03.23.
//

import CoreAudio
import Foundation

let systemObject = AudioObjectID(kAudioObjectSystemObject)

func getDefaultDeviceID(type: DeviceType) -> AudioObjectID? {
    var size = UInt32(0)
    
    var address = AudioObjectPropertyAddress.init(
        mSelector: deviceTypeToSelector(type: type),
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    AudioObjectGetPropertyDataSize(systemObject, &address, 0, nil, &size)
    
    if size == 0 {
        // no devices found.
        return nil
    }
    let numDevices = size / UInt32(MemoryLayout<AudioObjectID>.size)
    var devices = [AudioObjectID](repeating: 0, count: Int(numDevices))
    
    AudioObjectGetPropertyData(systemObject, &address, 0, nil, &size, &devices)
    print("size: \(size), num: \(numDevices), devices: \(devices)")
    
    return devices[0]
}

// FIXME: Make this proper with RawConvertible
func deviceTypeToSelector(type: DeviceType) -> AudioObjectPropertySelector {
    switch(type){
        case .Input: return kAudioHardwarePropertyDefaultInputDevice;
        case .Output: return kAudioHardwarePropertyDefaultOutputDevice;
        case .System: return kAudioHardwarePropertyDefaultSystemOutputDevice;
    }
}

// FIXME: Make this proper with RawConvertible
func deviceTypeToScope(type: DeviceType) -> AudioObjectPropertyScope {
    switch(type){
        case .Input: return kAudioObjectPropertyScopeInput;
        case .Output: return kAudioObjectPropertyScopeOutput;
        case .System: return kAudioObjectPropertyScopeGlobal;
    }
}

func getDeviceName(device: AudioObjectID) -> String {
    var propertySize = UInt32(MemoryLayout<CFString>.size)
    
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyDeviceNameCFString,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    
    var result: CFString = "" as CFString
    
    AudioObjectGetPropertyData(device, &propertyAddress, 0, nil, &propertySize, &result)
    
    return result as String
}

func isMuted(device: AudioObjectID, type: DeviceType) -> Bool {
    var muted = UInt32(0);
    var propertySize = UInt32(MemoryLayout<UInt32>.size);
    
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyMute,
        mScope: deviceTypeToScope(type: type),
        mElement: kAudioObjectPropertyElementMain
    )
    
    AudioObjectGetPropertyData(device, &propertyAddress, 0, nil, &propertySize, &muted)
    
    print("Getting current mute: \(muted == 1)")
    return muted == 1
}

func setMute(device: AudioObjectID, type: DeviceType, mute: MuteMode) {
    var muted = UInt32(mute.rawValue)
    
    if mute == .Toggle {
        muted = 1
        if isMuted(device: device, type: type) {
            muted = 0
        }
    }
    
    let propertySize = UInt32(MemoryLayout<UInt32>.size);
    
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyMute,
        mScope: deviceTypeToScope(type: type),
        mElement: kAudioObjectPropertyElementMain
    )
    
    print("Setting mute on device \(device): \(muted == 1), \(muted)")
    let err = AudioObjectSetPropertyData(device, &propertyAddress, 0, nil, propertySize, &muted)
    if(err != noErr) {
        let error = NSError(domain: NSOSStatusErrorDomain, code: Int(err))
        print("err: \(err), error: \(error.localizedDescription)")
    }
}
