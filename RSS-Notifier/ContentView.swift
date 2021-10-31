//
//  ContentView.swift
//  RSS-Notifier
//
//  Created by Daniel Kastberg on 2021-10-28.
//

import SwiftUI

struct ContentView: View {
    let rss = RSSReader()
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


