//
//  LightsBundle.swift
//  Lights
//
//  Created by Rayman on 22.07.24.
//

import WidgetKit
import SwiftUI

@main
struct LightsBundle: WidgetBundle {
    var body: some Widget {
        Lights()
        LightsControl()
    }
}
