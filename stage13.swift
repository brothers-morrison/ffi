
import Foundation
//import SwiftShims

func blep(foo: UnsafePointer<CChar>) -> UnsafePointer<CChar> {
    let sfoo = String(foo)
    print("Stage 13: \(sfoo)")
    let bar = "[Stage13: \(sfoo)]"
    print("Return value[13]: \(bar)")
    return (bar as CFStringRef).UTF8String
}

