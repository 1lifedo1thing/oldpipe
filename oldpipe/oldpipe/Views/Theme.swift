import UIKit

// App-wide palette. Previously every view controller carried its own private copy of the
// accent constant, so a tweak meant finding eleven literals spread over ten files.
enum Theme {
    // YouTube red — tab underlines, progress fills, switches, primary buttons.
    static let accent = UIColor(red: 0.98, green: 0.27, blue: 0.27, alpha: 1)
}
