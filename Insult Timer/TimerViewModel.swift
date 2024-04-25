//
//  TimerViewModel.swift
//  Insult Timer
//
//  Created by Ian Searcy-Gardner on 3/12/24.
//

import Foundation
import AVFoundation
import Combine

class TimerViewModel: ObservableObject {
    @Published private var timerModel = TimerModel()
    @Published var timerActive = false
    @Published var progress: CGFloat = 1.0
    @Published var timerPaused = false
    
    @Published var countdownTime: Int = 0
    private var timer: Timer?
    
    var selectedHours: Int {
        get { timerModel.selectedHours }
        set { timerModel.selectedHours = newValue }
    }
    
    var selectedMinutes: Int {
        get { timerModel.selectedMinutes }
        set { timerModel.selectedMinutes = newValue }
    }
    
    var selectedSeconds: Int {
        get { timerModel.selectedSeconds }
        set { timerModel.selectedSeconds = newValue }
    }
    
    var totalSeconds: Int {
        return timerModel.totalSeconds
    }
    
    private let timeUpMessages = [
        "Thou sheep-biting miscreant!",
        "Thou currish pignut!",
        "Thou bootless coxcomb!",
        "Thou mewling canker-blossom!",
        "Thou babbling waxworm!",
        "Thou blockheaded scut!",
        "Thou landless giglet!",
        "Thou great lout!",
        "Thou craven kitten!",
        "Thou brackish scullion!",
        "Thou mammering dewberry!",
        "Thou gooey lewdster!"
    ]

    private let timeUpMessagesTwo = [
        "Thou lumpish blaggard!",
        "Thou surly wench!",
        "Thou malodorous puppy!",
        "Thou squireless milk-beast!",
        "Thou obsequious Dubliner!",
        "Thou impertinent toad!",
        "Thou paunchy foot-licker!",
        "Thou impish mealworm!",
        "Thou hatless misadventurer!",
        "Thou ferret-less catamount!",
        "Thou potato-less Dubliner!",
        "Thou warty reprobate!",
        "Thou dung-devouring cur!",
        "Thou whiskey-stained codpiece!"
    ]
    
    private let timeUpMessagesThree = [
        "Thou spongy ill-born harpy with a mind as sharp as ditch-water and a nose less shiny than thine average bulbous toad!",
        "Thou  plebeian wench with a soul as dank as Erebus and with elbows no more graceful than a gerbil with syphilis!",
        "Thou ruttish clay-brained pillock with a heart as foul as a slaughter-house and whose only pony is as foul smelling as a cantankerous old Dubliner bathing in a pot of hot dewberry stew!",
        "Thou mangled sheep-biting codpiece with a voice as grating as a rusty hinge and a family crest less pleasing to the eye than an angry little shrew whose own dear mother has but moments ago made a meal of its silly little tail!",
        "Thou lumpish tickle-brained puttock with a visage as ghastly as a ghost's whisper and an earlobe less charming than a constipated puffer fish with kidney stones!",
        "Thou fobbing beetle-headed pignut with thoughts as shallow as a puddle and with hedgerows as pleasing to the eye as a headless rooster bathing in bat guano!",
        "Thou craven cricket-pie with a temperament as sour as vinegar and in possession of no more sausage pies than a quivering pigeon!",
        "Thou ungrateful rooster with a spirit as meek as a snail and no likelier to win a foot race than a mangy kitten!",
        "Thou gnarly blister with a gaze as empty as a cave and with less lard in thy cellar than an flea-bitten Dubliner!",
        "Thou artless bat-fowling bum-bailey with toe nails as saucy as sea slugs and with scarcely more gentility than a garrulous hedgehog rubbing its arse against the leg of a mangy dog!",
        "Thou churlish flap-mouthed canker-blossom with an attitude as prickly as a thornbush and less sweetness than a bittercup thine own dear mother but moments ago sneezed upon.",
        "Thou dankish hell-hated foot-licker with a wit as dull as lead and in possession of hardly more perspicacity than a dead mole.",
        "Thou errant ill-nurtured lewdster with a temper as volatile as gunpowder and no more patience than a starving predator with syphilis.",
        "Thou gnarling moldwarp-kissing horn-beast with a mind as warped as a twisted oak and with no more perspicacity than a mud-splattered swine on holiday!",
        "Thou impertinent elf-skinned lout with aspirations as lofty as a molehill and with no more charisma than a bankrupt slug.",
        "Thou jarring ill-tempered strumpet with a presence as welcome as a wart and no more allure than a decaying carcass.",
        "Thou loggerheaded swag-bellied clack-dish with a brain as barren as a desert and no more inventiveness than a dullard.",
        "Thou mammering hedge-born scut with a spirit as weak as a wilted flower and no more strength than a dying ant with syphilis.",
        "Thou obsequious sheep-biting barnacle with a conscience as clear as mud and no more honor than a spitting cobra.",
        "Thou paunchy rump-fed whey-face with a demeanor as cheerful as a storm cloud and with no more tunefulness than a dying turtle cooing at an overflowing bucket of excrement!",
        "Thou sottish toad-spotted malt-horse with a sense of humor as dry as dust and no more mirth than a mourning owl.",
        "Thou tottering varlot with ankles rather resembling two freshly shaved rats whose tails were but moments ago devoured by a ravenous monkey named Carl (but who is known affectionately to his friends as von Clausewitz)!",
        "Thou unmuzzled bat-fowling vassal with loyalty as firm as a mangy shrew's promise and with scarcely more fidelity than a philandering bull off to Dublin for the weekend with his mates!",
        "Thou sphincter-faced wagtail with a festering pustule for a brain and no more charm than a bilge rat serenading a monkey's arse!"
    ]
    
    
    
    // Use timerModel's `timeString` method
    func timeString(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    
    func startTimer() {
        if timerActive {
            // Pause the timer
            timer?.invalidate()
            timer = nil
            timerActive = false
            timerPaused = true
        } else {
            if !timerPaused {
                let total = timerModel.selectedHours * 3600 + timerModel.selectedMinutes * 60 + timerModel.selectedSeconds
                countdownTime = total
            }
            progress = CGFloat(countdownTime) / CGFloat(timerModel.selectedHours * 3600 + timerModel.selectedMinutes * 60 + timerModel.selectedSeconds)
            
            timer?.invalidate()
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.countdownTime > 0 {
                    self.countdownTime -= 1
                    self.progress = CGFloat(self.countdownTime) / CGFloat(self.timerModel.totalSeconds)
                } else {
                    self.timerActive = false
                    self.timer?.invalidate()
                    self.progress = 0
                    self.announceTimeUp()
                }
                
            }
            timerActive = true
            timerPaused = false
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        timerActive = false
        timerPaused = false
        countdownTime = timerModel.selectedHours * 3600 + timerModel.selectedMinutes * 60 + timerModel.selectedSeconds
        progress = 1.0 // Reset progress
    }
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    init() {
        configureAudioSession()
    }
    
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    func announceTimeUp() {
        let randomMessage = timeUpMessages.randomElement() ?? "Time's up!"
        let utterance = AVSpeechUtterance(string: "Time's up. " + randomMessage)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        let randomMessageTwo = timeUpMessagesTwo.randomElement() ?? "Time's up!"
        let utteranceTwo = AVSpeechUtterance(string: randomMessageTwo)
        utteranceTwo.voice = AVSpeechSynthesisVoice(language: "en-GB")
        let randomMessageThree = timeUpMessagesThree.randomElement() ?? "Time's up!"
        let utteranceThree = AVSpeechUtterance(string: randomMessageThree)
        utteranceThree.voice = AVSpeechSynthesisVoice(language: "en-GB")
        //        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.Deranged")
        utterance.rate = 0.35
        speechSynthesizer.speak(utterance)
        utteranceTwo.rate = 0.35
        speechSynthesizer.speak(utteranceTwo)
        utteranceThree.rate = 0.35
        speechSynthesizer.speak(utteranceThree)
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            if voice.language == "en-US" {
                print("\(voice.name) - Identifier: \(voice.identifier)")
            }
        }
    }
    
    private var backgroundEntryTime: Date? // Store time when app goes to background
    
    func appMovedToBackground() {
        if timerActive {
            backgroundEntryTime = Date() // Record the time when the app goes to the background
        }
    }
    
    func appReturnedToForeground() {
        guard let backgroundEntryTime = backgroundEntryTime else { return }
        
        let timeInBackground = Date().timeIntervalSince(backgroundEntryTime) // Calculate elapsed time
        countdownTime -= Int(timeInBackground) // Adjust the countdown time
        
        if countdownTime < 0 {
            countdownTime = 0
        }
        
        progress = CGFloat(countdownTime) / CGFloat(totalSeconds)
        
        // Restart or adjust the timer if needed
        if countdownTime > 0 && !timerActive && !timerPaused {
            startTimer() // Consider adding logic to handle paused state if required
        }
        
        self.backgroundEntryTime = nil // Reset the background entry time
    }
}
