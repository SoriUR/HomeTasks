import UIKit

final class CalculatorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonsToArray(for: view)
        roundUpTheButtons()
        updateUI()
    }

    @IBOutlet weak var display: UILabel! {
        didSet {
            displayText = display.text ?? ""
        }
    }
    @IBOutlet weak var radiansStateLabel: UILabel!

    var inTheMiddleOftyping = true
    var buttonsArray: [UIButton] = []
    lazy var model = Model()

    var displayText = "0" {
        didSet {
            display.text = displayText
        }
    }

    var symbol: Double {
        get {
            return Double(displayText) ?? 0.0
        }
        set {
            let doubleValue = converDoubleToString(newValue)
            display.text = doubleValue
        }
    }

    let titlesForButtonsWithTwoStates: [(firstState: String, secondState: String)] = [
        ("log₁₀", "log₂"),
        ("ln", "logᵧ"),
        ("10ˣ", "2ˣ"),
        ("eˣ", "yˣ"),
        ("cos", "cos⁻¹"),
        ("sin", "sin⁻¹"),
        ("tan", "tan⁻¹"),
        ("cosh", "cosh⁻¹"),
        ("sinh", "sinh⁻¹"),
        ("tanh", "tanh⁻¹")
    ]

    func addButtonsToArray (for view: UIView) {
        for subview in view.subviews {
            if let stack = subview as? UIStackView {
                addButtonsToArray(for: stack)
            } else if let button = subview as? UIButton {
                buttonsArray.append(button)
            }
        }
    }

    func resetSelectionForAllButtons() {
        for button in buttonsArray {
            if button.currentTitle != "2ⁿᵈ", button.currentTitle != radiansStateLabel.text {
                button.isSelected = false
            }
        }
    }

    func roundUpTheButtons() {
        let multiplayer: CGFloat = traitCollection.horizontalSizeClass == .compact ? 0.7 : 0.9
        for button in buttonsArray {
            button.layer.cornerRadius = min(button.bounds.size.height, button.bounds.size.width) * multiplayer
            button.layer.masksToBounds = true
        }
    }

    private func changeTitlesForButtonsWithTwoStates(for view: UIView) {
        for button in buttonsArray {
            for (firstStateTitle, secondStateTitle) in titlesForButtonsWithTwoStates {
                if button.currentTitle==firstStateTitle {
                    button.setTitle(secondStateTitle, for: .normal)
                } else if button.currentTitle==secondStateTitle {
                    button.setTitle(firstStateTitle, for: .normal)
                }
            }
        }
    }

    func selectOperationButton(with title: String, in view: UIView) {
        for button in buttonsArray {
            if button.currentTitle == title {
                button.isSelected = true
            }
        }
    }

    @IBAction func changeTitlesTo2ndState(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        changeTitlesForButtonsWithTwoStates(for: view)
    }

    @IBAction func switchRadianMode(_ sender: UIButton) {
        model.degreesMode = !model.degreesMode
        sender.setTitle(model.degreesMode ? "Rad" : "Deg", for: .normal)
        radiansStateLabel.text = model.degreesMode ? "" : "Rad"
    }

    func performClickAnimation(for title: String) {
        if let button = buttonsArray.first(where: { $0.currentTitle==title }) {
            UIView.transition(with: button,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: { button.isHighlighted = true },
                              completion: { if $0 { button.isHighlighted = false } })
        }
    }

    @IBAction func undo(_ sender: UIButton) {
        model.undo()
        updateUI()
    }

    @IBAction func redo(_ sender: UIButton) {
        model.redo()
        updateUI()
    }

    @IBAction func clear (_ sender: UIButton) {
        resetSelectionForAllButtons()
        if model.pendingFunction != nil {
            model.resetPendingOperation()
        } else {
            let oldDegreeMode = model.degreesMode
            model = Model()
            model.degreesMode = oldDegreeMode
            inTheMiddleOftyping = true
            displayText = "0"
        }
    }

    @IBAction func pressDigit(_ sender: UIButton) {
        if let digit = sender.currentTitle {
            if inTheMiddleOftyping {
                displayText += digit
                if displayText[displayText.startIndex] == "0" &&
                    displayText[displayText.index(after: displayText.startIndex)] != "." {
                    displayText.remove(at: displayText.startIndex)
                }
            } else {
                displayText = digit == "." ? "0." : digit
            }
            inTheMiddleOftyping = true
        }
    }

    @IBAction func performOperation (_ sender: UIButton) {
        let operationTitle = sender.currentTitle!

        if inTheMiddleOftyping {
            model.setOperand(symbol)
            inTheMiddleOftyping = false
        }

        model.doOperation(operationTitle)

        updateUI()
    }

    func updateUI() {
        if let res = model.result {
            symbol = res
        }

        resetSelectionForAllButtons()
        if let pendingFunction = model.pendingFunction {
            selectOperationButton(with: pendingFunction, in: view)
        }
    }
}
