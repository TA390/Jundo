//
//  Sound.swift
//  Jundo
//
//  Created by TA on 27/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import AudioToolbox


let Sound = _Sound()

class _Sound{
    
    func tap(){
        play(file: "Tap");
    }
    
    func pop(){
        play(file: "Pop");
    }
    
    func swoosh(){
        play(file: "Swoosh");
    }
    
    func notification(){
        play(file: "Notification");
    }
    
    private func play(file: String, ext: String = "wav") {
        
        if Setting.sound, let url = Bundle.main.url(forResource: file, withExtension: ext) {
            
            /* Create a SystemSoundID. */
            var id: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &id)
            
            /* Completion handler to dispose of the sound. */
            AudioServicesAddSystemSoundCompletion(id, nil, nil, {
                (id, data) -> Void in
                AudioServicesDisposeSystemSoundID(id)
            }, nil)
            
            /* Play sound. */
            AudioServicesPlaySystemSound(id)
        }
        
    }
    
}
