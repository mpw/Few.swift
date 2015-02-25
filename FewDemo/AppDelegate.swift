//
//  AppDelegate.swift
//  Few
//
//  Created by Josh Abernathy on 7/22/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Cocoa
import Few
import SwiftBox

struct AppState {
	let username: String = ""
	let password: String = ""
}

func renderInput(component: Few.Component<AppState>, label: String, secure: Bool, fn: (AppState, String) -> AppState) -> Element {
	let action: String -> () = { str in
		component.updateState { fn($0, str) }
	}

	let input: Element
	if secure {
		input = Password(action: action)
	} else {
		input = Input(action: action)
	}

	return View()
		.direction(.Row)
		.padding(Edges(bottom: 4))
		.children([
			Label(text: label).size(75, 19),
			input.size(100, 23),
		])
}

struct ScrollViewState {
	let selectedRow: Int? = nil
	let items: [Int] = Array(1...10)
}

func renderScrollView() -> Element {
	return Few.Component(initialState: ScrollViewState()) { component, state in
		let items = (0...10).map { row in renderRow(row) }
		return TableView(items) { row in
			component.updateState { ScrollViewState(selectedRow: row, items: $0.items) }
		}
	}
}

func renderRow(row: Int) -> Element {
	return View()
		.children([
			Label(text: "Item \(row + 1)")
		])
}

func renderLogin() -> Element {
	return Component(initialState: AppState()) { component, state in
		let loginEnabled = !state.username.isEmpty && !state.password.isEmpty
		return Element()
			.direction(.Column)
			.children([
				renderThingy(count(state.username.utf16)),
				renderInput(component, "Username", false) {
					AppState(username: $1, password: $0.password)
				},
				renderInput(component, "Password", true) {
					AppState(username: $0.username, password: $1)
				},
				Button(title: "Login", enabled: loginEnabled) {}
					.selfAlignment(.FlexEnd)
					.margin(Edges(bottom: 4)),
			])
	}
}

func renderThingy(count: Int) -> Element {
	let even = count % 2 == 0
	return (even ? Empty() : View(backgroundColor: NSColor.blueColor())).size(100, 50)
}

func renderDemo(component: Few.Component<()>, state: ()) -> Element {
	return View()
		.justification(.Center)
		.childAlignment(.Center)
		.direction(.Column)
		.children([
			renderLogin(),
			renderScrollView().size(100, 100),
		])
}

struct ConverterState {
	static let defaultFahrenheit: CGFloat = 32

	let fahrenheit: CGFloat = defaultFahrenheit
	let celcius: CGFloat = f2c(defaultFahrenheit)
}

func c2f(c: CGFloat) -> CGFloat {
	return (c * 9/5) + 32
}

func f2c(f: CGFloat) -> CGFloat {
	return (f - 32) * 5/9
}

func renderLabeledInput(label: String, value: String, placeholder: String, autofocus: Bool, fn: String -> ()) -> Element {
	return View()
		.direction(.Row)
		.padding(Edges(bottom: 4))
		.children([
			Label(text: label).size(75, 19),
			Input(
				text: value,
				placeholder: placeholder,
				enabled: true,
				autofocus: autofocus,
				action: fn)
				.size(100, 23),
		])
}

func renderTemperatureConverter(component: Few.Component<ConverterState>, state: ConverterState) -> Element {
	let numberFormatter = NSNumberFormatter()
	let parseNumber: String -> CGFloat? = { str in
		return (numberFormatter.numberFromString(str)?.doubleValue).map { CGFloat($0) }
	}
	return View()
		.justification(.Center)
		.childAlignment(.Center)
		.direction(.Column)
		.children([
			renderLabeledInput("Fahrenheit", "\(state.fahrenheit)", "Fahrenheit", true) {
				if let f = parseNumber($0) {
					component.updateState { _ in ConverterState(fahrenheit: f, celcius: f2c(f)) }
				}
			},
			renderLabeledInput("Celcius", "\(state.celcius)", "Celcius", false) {
				if let c = parseNumber($0) {
					component.updateState { _ in ConverterState(fahrenheit: c2f(c), celcius: c) }
				}
			},
		])
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	private let demoComponent = Few.Component(initialState: (), render: renderDemo)
	private let converterComponent = Few.Component(initialState: ConverterState(), render: renderTemperatureConverter)

	func applicationDidFinishLaunching(notification: NSNotification) {
		let component = converterComponent

		let contentView = window.contentView as! NSView
		component.addToView(contentView)
	}
}
