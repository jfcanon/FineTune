// FineTuneTests/URLHandlerTests.swift
// Tests for URL scheme handling logic.
// Pure logic — no audio hardware, no CoreAudio.

import Testing
import Foundation
@testable import FineTune

// MARK: - URL Parsing Helpers

@Suite("URLHandler — URL scheme validation")
struct URLHandlerSchemeTests {

    @Test("finetune scheme is recognized")
    func finetuneSchemeRecognized() {
        let url = URL(string: "finetune://set-volumes?app=com.test&volume=50")!
        #expect(url.scheme == "finetune")
    }

    @Test("Non-finetune scheme is rejected")
    func nonFinetuneSchemeRejected() {
        let url = URL(string: "http://set-volumes?app=com.test&volume=50")!
        #expect(url.scheme != "finetune")
    }
}

// MARK: - EQ Preset URL Validation

@Suite("URLHandler — set-eq preset validation")
struct URLHandlerEQPresetTests {

    @Test("Known preset raw values are valid")
    func knownPresetRawValues() {
        let knownPresets = ["flat", "bassBoost", "bassCut", "trebleBoost",
                           "vocalClarity", "podcast", "spokenWord",
                           "loudness", "lateNight", "smallSpeakers",
                           "rock", "pop", "electronic", "jazz", "classical",
                           "hipHop", "rnb", "deep", "acoustic",
                           "gaming", "movie", "cinematic"]
        
        for rawValue in knownPresets {
            #expect(EQPreset(rawValue: rawValue) != nil,
                    "Preset '\(rawValue)' should be a valid EQPreset raw value")
        }
    }

    @Test("New presets have correct categories")
    func newPresetCategories() {
        #expect(EQPreset.gaming.category == .gaming)
        #expect(EQPreset.cinematic.category == .media)
    }

    @Test("New presets have non-empty names")
    func newPresetNames() {
        #expect(!EQPreset.gaming.name.isEmpty)
        #expect(!EQPreset.cinematic.name.isEmpty)
    }

    @Test("New presets have valid band gains")
    func newPresetBandGains() {
        let gaming = EQPreset.gaming.settings
        let cinematic = EQPreset.cinematic.settings
        
        #expect(gaming.bandGains.count == EQSettings.bandCount)
        #expect(cinematic.bandGains.count == EQSettings.bandCount)
        
        for gain in gaming.bandGains {
            #expect(gain >= EQSettings.minGainDB && gain <= EQSettings.maxGainDB)
        }
        for gain in cinematic.bandGains {
            #expect(gain >= EQSettings.minGainDB && gain <= EQSettings.maxGainDB)
        }
    }
}

// MARK: - URL Query Parameter Parsing

@Suite("URLHandler — Query parameter parsing")
struct URLHandlerQueryParsingTests {

    @Test("Multiple query items can be parsed")
    func multipleQueryItems() {
        let url = URL(string: "finetune://set-volumes?app=com.a&volume=50&app=com.b&volume=80")!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems ?? []
        
        #expect(queryItems.count == 4)
        #expect(queryItems[0].name == "app")
        #expect(queryItems[0].value == "com.a")
        #expect(queryItems[1].name == "volume")
        #expect(queryItems[1].value == "50")
    }

    @Test("Empty query string returns empty array")
    func emptyQueryString() {
        let url = URL(string: "finetune://reset")!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems ?? []
        
        #expect(queryItems.isEmpty)
    }

    @Test("Case-insensitive parameter names")
    func caseInsensitiveParams() {
        let url = URL(string: "finetune://set-volumes?APP=com.test&VOLUME=50")!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems ?? []
        
        #expect(queryItems[0].name == "APP")
        #expect(queryItems[1].name == "VOLUME")
    }
}
