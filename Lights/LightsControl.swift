//
//  LightsControl.swift
//  Lights
//
//  Created by Rayman on 22.07.24.
//

import AppIntents
import SwiftUI
import WidgetKit

struct LightsControl: ControlWidget {
    static let kind: String = "at.rayman.HomeTiles.Lights"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                value.light.rawValue,
                isOn: LightState.on == value.state,
                action: ToggleLightIntent(value.light.rawValue),
                valueLabel: { _ in
                    Label(value.state.label, systemImage: value.state.image)
                }
            )
            .tint(.yellow)
        }
        .displayName("Lights")
        .description("Choose Light.")
    }
}

extension LightsControl {
    struct Value {
        var light: LightType
        var state: LightState
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: LightConfiguration) -> Value {
            LightsControl.Value(light: configuration.light, state: LightState.on)
        }

        func currentValue(configuration: LightConfiguration) async throws -> Value {
            //check backend if light is on
            let state = getRandomState()
            print("Getting new state")
            print(state)
            return LightsControl.Value(light: configuration.light, state: state)
        }
        
        func getRandomState() -> LightState {
            let state = Int.random(in: 0..<3)
            switch state {
            case 0: return LightState.off
            case 1: return LightState.on
            default: return LightState.unknown
            }
        }
    }
}

struct LightConfiguration: ControlConfigurationIntent {
    static var title: LocalizedStringResource { "Choose Light" }

    @Parameter(title: "Light", default: LightType.hall)
    var light: LightType
}

struct ToggleLightIntent: SetValueIntent {
    static var title: LocalizedStringResource { "Toggle Light" }
    
    @Parameter(title: "On")
    var value: Bool

    @Parameter(title: "Light")
    var name: String

    init() {}

    init(_ name: String) {
        self.name = name
    }

    func perform() async throws -> some IntentResult {
        //toggle light here?
        return .result()
    }
}

enum LightState: String, AppEnum {
    case on, off, unknown
    
    var label: String {
        switch self {
        case .on: return "On"
        case .off: return "Off"
        case .unknown: return "Unknown"
        }
    }
    
    var image: String {
        switch self {
        case .on: return "warninglight.fill"
        case .off: return "warninglight"
        case .unknown: return "exclamationmark.warninglight"
        }
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "LightState"
    }
    
    static var caseDisplayRepresentations: [LightState : DisplayRepresentation] {
        [
            .on: DisplayRepresentation(title: "On"),
            .off: DisplayRepresentation(title: "Off"),
            .unknown: DisplayRepresentation(title: "Unknown"),
        ]
    }
}

enum LightType: String, AppEnum {
    
    case hall = "Hall"
    case office = "Office"
    case kitchen = "Kitchen"
    case led = "Led"
    case room = "Room"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "LightType"
    }
    
    static var caseDisplayRepresentations: [LightType : DisplayRepresentation] {
        [
            .hall: DisplayRepresentation(title: "Hall"),
            .office: DisplayRepresentation(title: "Office"),
            .kitchen: DisplayRepresentation(title: "Kitchen"),
            .led: DisplayRepresentation(title: "Led"),
            .room: DisplayRepresentation(title: "Room")
        ]
    }
}
