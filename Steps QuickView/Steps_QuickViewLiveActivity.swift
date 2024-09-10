//
//  Steps_QuickViewLiveActivity.swift
//  Steps QuickView
//
//  Created by Jacob Landry on 9/9/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Steps_QuickViewAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Steps_QuickViewLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Steps_QuickViewAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Steps_QuickViewAttributes {
    fileprivate static var preview: Steps_QuickViewAttributes {
        Steps_QuickViewAttributes(name: "World")
    }
}

extension Steps_QuickViewAttributes.ContentState {
    fileprivate static var smiley: Steps_QuickViewAttributes.ContentState {
        Steps_QuickViewAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Steps_QuickViewAttributes.ContentState {
         Steps_QuickViewAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Steps_QuickViewAttributes.preview) {
   Steps_QuickViewLiveActivity()
} contentStates: {
    Steps_QuickViewAttributes.ContentState.smiley
    Steps_QuickViewAttributes.ContentState.starEyes
}
