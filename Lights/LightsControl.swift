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
            LightsControl.Value(light: configuration.light, state: LightState.unknown)
        }

        func currentValue(configuration: LightConfiguration) async throws -> Value {
            var getRequest = URLRequest(url: URL(string: "https://lights.rayman.me/status?shelly=" + configuration.light.rawValue)!)
            getRequest.httpMethod = "GET"
            getRequest.setValue("key", forHTTPHeaderField: "authorization")
            if let (data, _) = try? await URLSession.shared.data(for: getRequest) {
                if let isOn = String(data: data, encoding: .utf8), !isOn.isEmpty {
                    return LightsControl.Value(light: configuration.light, state: isOn == "true" ? LightState.on : LightState.off)
                }
            }
            return LightsControl.Value(light: configuration.light, state: LightState.unknown)
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
        var putRequest = URLRequest(url: URL(string: "https://lights.rayman.me/status")!)
        putRequest.httpMethod = "PUT"
        putRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        putRequest.setValue("key", forHTTPHeaderField: "authorization")
        putRequest.httpBody = """
            {
                "shelly": "\(name)",
                "on": "\(value)"
            }
        """.data(using: .utf8)
        _ = try? await URLSession.shared.data(for: putRequest)
        if (LightType.kitchen.rawValue == name) {
            ControlCenter.shared.reloadControls(ofKind: "at.rayman.HomeTiles.Lights")
        }
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
