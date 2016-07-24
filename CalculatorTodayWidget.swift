//
//  CalculatorTodayWidget.swift
//  Prime Calc
//
//  Created by Henry Stern on 3/9/16.
//  Copyright © 2016 One Studio. All rights reserved.
//

import UIKit
import NotificationCenter


typealias Rational = (num : Int, den : Int)

func rationalApproximationOf(x0 : Double, withPrecision eps : Double = 1.0E-6) -> Rational {
    var x = x0
    var a = floor(x)
    var (h1, k1, h, k) = (1, 0, Int(a), 1)
    
    while x - a > eps * Double(k) * Double(k) {
        x = 1.0/(x - a)
        a = floor(x)
        (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
    }
    return (h, k)
}



infix operator ^^ { }
func ^^ (radix: Double, power: Double) -> Double {
    return pow(Double(radix), Double(power))
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start: start, end: end)]
    }
}


func sub(a: Double, b: Double) -> Double {
    let result = a - b
    return result
}

func add(a: Double, b: Double) -> Double {
    let result = a + b
    return result
}

func mul(a: Double, b: Double) -> Double {
    let result = a * b
    return result
}
func div(a: Double, b: Double) -> Double {
    let result = a / b
    return result
}


typealias Binop = (Double, Double) -> Double
let ops: [String: Binop] = [ "+" : add, "-" : sub, "*" : mul, "/" : div ] // connecting symbols to word-based functions.






class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var hider: UIButton!
    var calc7 =""
    
    func fractionconversiongo() {
        
        if calculatortextfield.text!.containsString("e") == false {
            
            // below, making the decimal to fraction conversion that occasionally shows up (try it with 5*3/120=)
            var count = calculatortextfield.text?.characters.count
            let string = calculatortextfield.text!
            let needle: Character = "."
            if let idx = string.characters.indexOf(needle) {
                let pos = string.startIndex.distanceTo(idx)
                print("Found \(needle) at position \(pos)")
                
                
                count = count! - pos
                
                print("there are \(count) digits after the decimal.")
                
                let multiplier = zeroes(count!)
                
                let numerator = Double(multiplier) * Double(calculatortextfield.text!)!
                var gcd:Int = 0
                
                if accumulator < 9223372036854775808 && accumulator > -9223372036854775808 { // we only want to check this stuff if it's an integer.
                    
                    if numerator * multiplier < 9223372036854775808 {
                        if let numeratorint:Int = Int(numerator) { gcd = greatestCommonDenominator(numeratorint, b: Int(multiplier))
                        } else {
                            print("technical errors; numerator given was not convertible to an integer.")
                        }
                        
                        
                        let newnumerator = numerator / Double(gcd)
                        
                        let finalnumerator:String = String(newnumerator).stringByReplacingOccurrencesOfString(".0", withString: "")
                        
                        let newdenominator = Int(multiplier) / gcd
                        
                        let tofrac = "\(finalnumerator)/\(newdenominator)"
                        
                        print("the converted fraction has been determined to be \(tofrac)")
                        
                        fracview.text = tofrac
                        
                        fractioncheck = tofrac
                        
                    }
                    
                    if fracview.text?.characters.count > 15 {
                        
                        fracview.text = ""
                    }
                    
                } else {
                    print("so large calculating equiv. fraction could cause a crash, so just no.")
                }
                
                /*
                 
                 so basically, above, we are making the decimal to fraction conversion work (it still only works with terminating decimals, grr). Here's how:
                 
                 
                 1. Find digits in calculatorresult.text after the decimal (if there isn't one, just cancel this).
                 2. Multiply it times "1(followed by a bunch of zeroes, determined by number of digits in decimal, to make the decimal point go away)", zeroes being found in a loop (i.e. for i in digitsafterdecimal; i = 1; i++ {
                 add a zero }).
                 3. Set the denominator to "1\(zeroes)"
                 4. Find the greatest common denominator of the results of steps 2 and 3.
                 5. Divide both the numerator and denominator by said gcd, and display this to the user.
                 
                 */
                
                
                
                
                
                if let tofrac = Double(calculatortextfield.text!) {
                    var equals = "="
                    let fraction = rationalApproximationOf(tofrac)
                    let num = fraction.num
                    let den = fraction.den
                    var realfraction = String(fraction)
                    realfraction = realfraction.stringByReplacingOccurrencesOfString("(", withString: "")
                    realfraction = realfraction.stringByReplacingOccurrencesOfString(")", withString: "")
                    realfraction = realfraction.stringByReplacingOccurrencesOfString(", ", withString: "/")
                    
                    if realfraction == fractioncheck {
                        equals = "="
                    } else {
                        equals = "≈"
                    }
                    
                    let wholenumbervalue = num/den
                    let newnum = num - (wholenumbervalue * den)
                    if tofrac > 2 {
                        fracview.text = "\(equals) \(wholenumbervalue) + \(newnum)/\(den)"
                    } else if tofrac < 2 {
                        fracview.text = "\(equals) \(realfraction)"
                    }
                }
                
            }
            else {
                print("Not found")
            }
            updateDisplay()
            
            
            if fracview.text != "" { // after all the conversion, we determine if we made an exact calculation or an inexact one.
                
                print("fracview is \(fracview.text!) so we're testing whether it's equals exact or equals approx.")
                
                var frac = fracview.text
                
                frac = frac?.stringByReplacingOccurrencesOfString("≈", withString: "")
                frac = frac?.stringByReplacingOccurrencesOfString("=", withString: "")
                var savedfrac = frac
                frac = frac! + ".0"
                frac = frac?.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                guard let mathExpression:NSExpression = NSExpression(format: frac!) else {
                    let mathExpression = "error"
                }
                if mathExpression != "error" {
                    let result:Float = try Float((mathExpression.expressionValueWithObject(nil, context: nil) as? Float)!)
                    
                    if let realresult: Float = Float(calculatortextfield.text!) {
                        
                        let realresult2 = realresult // Double(round(10*realresult)/10)
                        let result2 = result // Double(round(10*result)/10)
                        print(realresult2)
                        print(result2)
                        
                        if result2 == realresult2 {
                            fracview.text = "=\(savedfrac!)"
                        } else {
                            fracview.text = "≈\(savedfrac!)"
                        }
                        
                    }
                    
                    
                    
                    
                }
                
                
                
                
                
            }
            
            
        }
    }
    
    var buttonrecall = "" // tracks all the button presses so that when the user presses backspace, we do all the button presses before the last one.
    
    var powerArray: [Int] = []
    
    func zeroes (input: Int) -> Double {
        
        var multiplier:Double = 1
        
        for var put = 1; put <= input; put += 1 {
            
            multiplier = Double(multiplier) * 10
            
            // gotta get that tens place right!
            
        }
        
        return multiplier
    }
    
    var stack = "" // the stack is an un-garbled transcript of what the user has entered. It's what appears just below the calculator number display with a copy button next to it.
    
    var negative = false // enables negativeness via minus button.
    
    
    // add calculator text field here
    
    
    func greatestCommonDenominator(a: Int, b: Int) -> Int { // this function takes in two numbers and puts out their gcd. Found on GitHub.
        return b == 0 ? a : greatestCommonDenominator(b, b: a % b)
    }
    
    func simplify(top:Float, bottom:Float) -> (newTop:Float, newBottom:Float) {
        
        var x = top
        var y = bottom
        while (y != 0) {
            let buffer = y
            y = x % y
            x = buffer
        }
        let hcfVal = x
        let newTopVal = top/hcfVal
        let newBottomVal = bottom/hcfVal
        return(newTopVal, newBottomVal)
    }

    
    // setting up our calculator variables...
    
    var accumulator: Double = 0.0 // We store the calculated value here
    var userInput = "" // User-entered digits
    
    var fractioncheck = "0"
    
    
    // UI Setup.
    
    
    @IBOutlet weak var btnPower: UIButton!
    
    @IBOutlet weak var btnSqrt: UIButton!
    
    @IBOutlet weak var btnPi: UIButton!
    
    @IBOutlet weak var btnOneOverX: UIButton!
    
    @IBOutlet weak var btnPlus: UIButton!
    
    @IBOutlet weak var btnMinus: UIButton!
    
    @IBOutlet weak var btnMultiply: UIButton!
    
    @IBOutlet weak var btnDivide: UIButton!
    
    @IBOutlet weak var btn7: UIButton!
    
    @IBOutlet weak var bnt8: UIButton!
    
    @IBOutlet weak var btn9: UIButton!
    
    @IBOutlet weak var btn4: UIButton!
    
    @IBOutlet weak var btn5: UIButton!

    @IBOutlet weak var btn6: UIButton!
    
    @IBOutlet weak var btn1: UIButton!
    
    @IBOutlet weak var btn2: UIButton!
    
    @IBOutlet weak var btn3: UIButton!
    
    @IBOutlet weak var btnEquals: UIButton!
    
    @IBOutlet weak var btnDec: UIButton!
    
    @IBOutlet weak var btn0: UIButton!
    
    @IBOutlet weak var stackview: UILabel!
    
    @IBOutlet weak var btnClear: UIButton!
    
    @IBOutlet weak var fracview: UILabel!

    @IBOutlet weak var copyoutlet: UIButton!
    
    @IBOutlet weak var calculatortextfield: UILabel!
    
    @IBOutlet weak var numField: UILabel!
    
    @IBOutlet weak var powerinsert: UITextField!
    
    @IBOutlet weak var fractionconversion: UILabel!
    
    @IBOutlet weak var btnPowerInsertPress: UIButton!


    var numStack: [Double] = [] // Number stack
    var opStack: [String] = [] // Operator stack

    // Looks for a single character in a string.
    func hasIndex(stringToSearch str: String, characterToFind chr: Character) -> Bool {
        for c in str.characters {
            if c == chr {
                return true
            }
        }
        return false
    }
    
    func handleInput(str: String) { // makes it so something appears in the result field of the calculator.
        
        fracview.text = ""
        
        if stack.characters.last != "π" {
            
            print(opStack)
            print(numStack)
            
            print(stack)
            print(str)
            
            if stack.hasSuffix("--") == false && stack.hasSuffix("*-") == false && stack.hasSuffix("+-") == false && stack.hasSuffix("/-") == false { // avoids the errant triple-operator in stack.
                stack = stack + "\(str)"
            } else { // if there otherwise would be a triple operator (i.e. "*--" instead of "*-"...
                var strcopy = str
                strcopy = strcopy.stringByReplacingOccurrencesOfString("-", withString: "") // get rid of that last minus.
                stack = stack + "\(strcopy)"
            }
            
            print(stack)
            
            if str == "-" {
                if userInput.hasPrefix(str) {
                    // Strip off the first character (a dash)
                    userInput = userInput.substringFromIndex(userInput.startIndex.successor())
                } else {
                    userInput = str + userInput
                }
            } else {
                userInput += str
            }
            accumulator = Double((userInput as NSString).doubleValue)
            updateDisplay()
            stackview.text = stack
        }
    }
    
    func updateDisplay() {
        // If the value is an integer, don't show a decimal point
        
        print("accumulator position one")
        print(accumulator)
        
        if accumulator < 9223372036854775808 && accumulator > -9223372036854775808 { // if it can be an integer (9223372036854775808 is the max. integer that fits in the 64 bits allotted to an int.).
            
            if let iAcc:Int = Int(accumulator)  {
                
                if accumulator - Double(iAcc) == 0 {
                    numField.text = "\(iAcc)"
                } else {
                    numField.text = "\(accumulator)"
                }
            }
        } else {
            numField.text = "\(accumulator)"
        }
        
        if String(accumulator).containsString("e+") {
            
            numField.text = "\(accumulator)"
        }
        
        print("numfield position one")
        print(numField.text)
        
    }

    func doMath(newOp: String) {
        
        if newOp == "-" {
            
            if stack == "" {
                // press 0
                if stack.characters.last != "/" && stack.hasSuffix("/.") == false { // this prevents dividing by zero or dividing by point zero!!
                    handleInput("0")
                    stackview.text = stack // this, here and below, makes the place it shows the list of things you tapped (the label) equal to the variable that has all the text.
                    
                }
            }
        }
        
        if stack.hasSuffix(" | ") {
            
            stack = stack + calc7
            print("this is calc7: \(x.calc7)")
            
            // this code above makes it so that after the user clicks equal (which generates " | " at the end of the code to split up expressions), if the user clicks divide, it shows the expression it equals in the stack, then it shows the divide.
            
            // Without this, if you pressed 6, *, 2, =, /, and 2: the stack would show up as "6*2=12 | /2 = 6". Thanks to this, it says "6*2=12 | 12/2=6". And it doesn't even get confused by typing a new number after =. Woot!
            
        }
        
        
        if stack != "" {
            
            if stack.characters.last! != "*" && stack.characters.last! != "/" && stack.characters.last! != "+" && stack.characters.last! != "-" && stack.characters.last! != "-" && stack.characters.last! != "." { // making sure we're not typing in multiple operators!!
                stack = stack + "\(newOp)"
                
                if userInput != "" && !numStack.isEmpty {
                    let stackOp = opStack.last
                    if !((stackOp == "+" || stackOp == "-") && (newOp == "*" || newOp == "/")) {
                        let oper = ops[opStack.removeLast()]
                        accumulator = oper!(numStack.removeLast(), accumulator)
                        doEquals()
                    }
                }
                opStack.append(newOp)
                numStack.append(accumulator)
                userInput = ""
                updateDisplay()
            }
            
        }
    }
    func doEquals() {
            fractionconversiongo()
        copyoutlet.setTitle("copy", forState: .Normal)
    
        if userInput == "" {
            return
        }
        if !numStack.isEmpty {
            let oper = ops[opStack.removeLast()]
            accumulator = oper!(numStack.removeLast(), accumulator)
            if !opStack.isEmpty {
                doEquals()
            }
        }
        updateDisplay()
        userInput = ""
        fractionconversiongo()
        }



    @IBAction func btn0Press(sender: AnyObject) {
        
        buttonrecall = buttonrecall + "0"
        
        if stack.characters.last != "/" && stack.hasSuffix("/.") == false { // this prevents dividing by zero or dividing by point zero!!
            if negative == false {
                handleInput("0")
            } else {
                handleInput("-0")
                negative = false
            }
            
            stackview.text = stack // this, here and below, makes the place it shows the list of things you tapped (the label) equal to the variable that has all the text.
        }
    }
    @IBAction func btn1Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "1"
        if negative == false {
            handleInput("1")
        } else {
            handleInput("-1")
            negative = false
        }
        stackview.text = stack
    }
    @IBAction func btn2Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "2"
        if negative == false {
            handleInput("2")
        } else {
            handleInput("-2")
            negative = false
        }
        
        stackview.text = stack
    }
    @IBAction func btn3Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "3"
        if negative == false {
            handleInput("3")
        } else {
            handleInput("-3")
            negative = false
        }
        
        stackview.text = stack
    }
    @IBAction func btn4Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "4"
        if negative == false {
            handleInput("4")
        } else {
            handleInput("-4")
            negative = false
        }
        
        stackview.text = stack
    }
    @IBAction func btn5Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "5"
        if negative == false {
            handleInput("5")
        } else {
            handleInput("-5")
            negative = false
        }
        
        stackview.text = stack
    }
    @IBAction func btn6Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "6"
        if negative == false {
            handleInput("6")
        } else {
            handleInput("-6")
            negative = false
        }
        
        stackview.text = stack
    }
    @IBAction func btn7Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "7"
        if negative == false {
            handleInput("7")
        } else {
            handleInput("-7")
            negative = false
        }
        
        stackview.text = stack
    }
    @IBAction func btn8Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "8"
        if negative == false {
            handleInput("8")
        } else {
            handleInput("-8")
            negative = false
        }
        
        stackview.text = stack
    }
    @IBAction func btn9Press(sender: AnyObject) {
        buttonrecall = buttonrecall + "9"
        if negative == false {
            handleInput("9")
        } else {
            handleInput("-9")
            negative = false
        }
        
        stackview.text = stack
    }
    
    @IBAction func btnDecPress(sender: AnyObject) {
        if hasIndex(stringToSearch: userInput, characterToFind: ".") == false {
            if negative == false {
                handleInput(".")
            } else {
                handleInput("-.")
                negative = false
            }
            
            buttonrecall = buttonrecall + "."
            stackview.text = stack
        }
    }
    
    @IBAction func btnACPress(sender: AnyObject) { // clear button (CLEAR EVERYTHING).
        print("tapped field/pressed button to clear")
        userInput = ""
        accumulator = 0
        updateDisplay()
        numStack.removeAll()
        opStack.removeAll()
        stack = ""
        fractionconversion.text = ""
        stackview.text = ""
        copyoutlet.hidden = true
        buttonrecall = ""
        calculatortextfield.text = ""
    }

    @IBAction func BackSpaceTap(sender: AnyObject) {
        btnBackSpacePress(UIButton)
        print("tapped field to backspace")
        
    }

    
    @IBAction func btnBackSpacePress(sender: AnyObject) {
        
        if stack != "" {
            
            userInput = ""
            accumulator = 0
            updateDisplay()
            numStack.removeAll()
            opStack.removeAll()
            stack = ""
            fractionconversion.text = ""
            stackview.text = ""
            copyoutlet.hidden = true
            
            if stack.characters.count == 1 {
                btnACPress(UIButton)
            }
            
            print("this is button recall \(buttonrecall)")
            let truncated = String(buttonrecall.characters.last!)
            
            print("this is truncated \(truncated)")
            
            let truncaterange = buttonrecall.rangeOfString(truncated, options:NSStringCompareOptions.BackwardsSearch)!
            
            print("this is truncate range \(truncaterange)")
            
            buttonrecall = buttonrecall.stringByReplacingCharactersInRange(truncaterange, withString: "")
            
            // above, deletes the very last button push
            
            print("Now this is the updated button recall  \(buttonrecall)")
            
            var SavedButtonsRecall = Array(buttonrecall.characters)
            
            buttonrecall = ""
            
            for b in 0 ..< SavedButtonsRecall.count {
                
                print("doing recall number \(b), which is the character \(SavedButtonsRecall[b])")
                
                if String(SavedButtonsRecall)[b] == "P" {
                    btnPowerPress(UIButton)
                    } else if String(SavedButtonsRecall)[b] == "1" {
                    btn1Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "0" {
                    btn0Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "2" {
                    btn2Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "3" {
                    btn3Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "4" {
                    btn4Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "5" {
                    btn5Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "6" {
                    btn6Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "7" {
                    btn7Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "8" {
                    btn8Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "9" {
                    btn9Press(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "." {
                    btnDecPress(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "+" {
                    btnPlusPress(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "-" {
                    btnMinusPress(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "*" {
                    btnMultiplyPress(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "/" {
                    btnDividePress(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "=" {
                    btnEqualsPress(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "S" { // square root
                    btnSqrtPress(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "R" { // reciprocal
                    btnOneOverXPress(UIButton)
                    
                } else if String(SavedButtonsRecall)[b] == "N" { // pi
                    btnPiPress(UIButton)
                    
                }
                
            }
            print("this is the final button recall: \(buttonrecall).")
            
        } else { // if stack is blank.
            calculatortextfield.text = ""
        }
    }

    
    @IBAction func btnPlusPress(sender: AnyObject) {
        buttonrecall = buttonrecall + "+"
        doMath("+")
        stackview.text = stack
    }
    
    @IBAction func btnMinusPress(sender: AnyObject) {
        // saved stack lets us check if there was any change; if there wasn't, then we'll switch mode to negative number.
        let savedstack = stack
        buttonrecall = buttonrecall + "-"
        doMath("-")
        stackview.text = stack
        if stack == savedstack {
            if stack.hasSuffix("--") == false && stack.hasSuffix("*-") == false && stack.hasSuffix("+-") == false && stack.hasSuffix("/-") == false { // we haven't already negative-ized the next number...
                negative = true
                stack = stack + "-"
                print("added -")
                stackview.text = stack
            }
        }
        
    }
    
    @IBAction func btnMultiplyPress(sender: AnyObject) {
        buttonrecall = buttonrecall + "*"
        doMath("*")
        stackview.text = stack
    }
    
    @IBAction func btnDividePress(sender: AnyObject) {
        buttonrecall = buttonrecall + "/"
        doMath("/")
        stackview.text = stack
    }
    
    @IBAction func btnEqualsPress(sender: AnyObject) {
        
        
        
        if stack.hasSuffix(" | ") == false { // making sure we're not equaling twice.
            
            if stack != "" {
                
                if stack.characters.last! != "*" && stack.characters.last! != "/" && stack.characters.last! != "-" && stack.characters.last! != "+" && stack.characters.last! != "." { // and we can't divide-point-equal!
                    
                    
                    buttonrecall = buttonrecall + "="
                    doEquals()
                    
                    updateDisplay()
                    
                    if calculatortextfield.text!.containsString(".") {
                    
                    let z = Double(calculatortextfield.text!)
                    
                    let y = Double(floor(10000*z!)/10000)
                    
                    let checky = String(y).stringByReplacingOccurrencesOfString("...", withString: "")
                        
                        if checky == calculatortextfield.text! {
                            stack = stack + "=\(calculatortextfield.text!) | "
                        } else {
                        stack = stack + "=\(y)... | "
                        }
                    } else {
                        stack = stack + "=\(calculatortextfield.text!) | "
                    }
                    
                    
                    calc7 = calculatortextfield.text!
                    print(stack)
                    
                    stackview.text = stack
                    copyoutlet.hidden = false
                    
                }
            }
        }
        
        
        fractionconversiongo()
        
        fractionconversiongo()
    }
    
    
    
    @IBAction func btnOneOverXPress(sender: AnyObject) {
        fracview.text = ""
        doEquals()
        if let original = Double(calculatortextfield.text!) {
            buttonrecall = buttonrecall + "R"
            let reciprocalled = 1/original
            accumulator = reciprocalled
            calculatortextfield.text = String(reciprocalled)
            updateDisplay()
            
            if stack.hasSuffix(" | ") {
                
                stack = stack + "1/\(original)=\(calculatortextfield.text!) | "
                calc7 = calculatortextfield.text!
                
            } else {
                
                if stack.containsString("| ") {
                    let equalsrange = stack.rangeOfString("| ", options:NSStringCompareOptions.BackwardsSearch)
                    stack = stack.stringByReplacingCharactersInRange(equalsrange!, withString: "| 1/(")
                    stack = stack + ")"
                    stackview.text = stack
                } else { // = hasn't been presssed on this calculating session yet
                    
                    stack = "1/(" + stack + ")"
                    
                }
                
                if calculatortextfield.text!.containsString(".") {
                
                let z = Double(calculatortextfield.text!)
                
                let y = Double(floor(10000*z!)/10000)
                
                stack = stack + "=\(y)... | "
                } else {
                    stack = stack + "=\(calculatortextfield.text!) | "
                }
                
            }
            
            stackview.text = stack
            calc7 = calculatortextfield.text!
            
            
            
        }
        
        fractionconversiongo()
    }
    
    
    @IBAction func backspaceTap(sender: AnyObject) {
        
        btnBackSpacePress(UIButton)
    }
    
    
    @IBAction func btnSqrtPress(sender: AnyObject) {
        
        if stack != "" {
            
            let saved = calculatortextfield.text!
            
            doEquals()
            
            buttonrecall = buttonrecall + "S"
            
            let sqrted = sqrt(Double(calculatortextfield.text!)!)
            calculatortextfield.text = String(sqrted)
            accumulator = sqrted
            updateDisplay()
            print(accumulator)
            print(numStack)
            print(opStack)
            
            
            
            if stack.hasSuffix(" | ") {
                
                if calculatortextfield.text!.containsString(".") {
                    
                
                
                let z = Double(calculatortextfield.text!)
                
                let y = Double(floor(10000*z!)/10000)
                stack = stack + "√\(saved)=\(y)... | "
                } else {
                    stack = stack + "√\(saved)=\(calculatortextfield.text!) | "

                }
                
                calc7 = calculatortextfield.text!
                
            } else {
                
                if stack.containsString("| ") {
                    let equalsrange = stack.rangeOfString("| ", options:NSStringCompareOptions.BackwardsSearch)
                    stack = stack.stringByReplacingCharactersInRange(equalsrange!, withString: "| √(")
                    stack = stack + ")"
                    stackview.text = stack
                } else { // = hasn't been presssed on this calculating session yet
                    
                    stack = "√(" + stack + ")"
                    
                }
                
                stack = stack + "=\(calculatortextfield.text!) | "
                
            }
            
            stackview.text = stack
            calc7 = calculatortextfield.text!
        }
        
        doEquals()
    }

    @IBAction func btnPowerInsertPress(sender: AnyObject) {
        let saved = calculatortextfield.text!
        doEquals()
        
        if let tobepowered = Double(self.calculatortextfield.text!) {
            
                buttonrecall = buttonrecall + "P"
                
                let powered = tobepowered ^^ 2
                
                self.accumulator = powered
                self.calculatortextfield.text = String(powered)
                updateDisplay()
                
                if stack.hasSuffix(" | ") {
                    
                    stack = stack + "\(saved)^2=\(calculatortextfield.text!) | "
                    calc7 = calculatortextfield.text!
                    
                } else {
                    
                    if stack.containsString("| ") {
                        let equalsrange = stack.rangeOfString("| ", options:NSStringCompareOptions.BackwardsSearch)
                        stack = stack.stringByReplacingCharactersInRange(equalsrange!, withString: "| (")
                        stack = stack + ")^2"
                        stackview.text = stack
                    } else { // = hasn't been presssed on this calculating session yet
                        
                        stack = "(" + stack + ")^2"
                        
                    }
                    
                    stack = stack + "=\(calculatortextfield.text!) | "
                    
                }
                
                stackview.text = stack
                calc7 = calculatortextfield.text!
                
                updateDisplay()
            
        }
        
        fractionconversiongo()
    }
    
    
    @IBAction func btnPowerPress(sender: AnyObject) {
        
        btnPowerInsertPress(UIButton)
        
    }
    
    @IBAction func btnPiPress(sender: AnyObject) {
        
        buttonrecall = buttonrecall + "N"
        
        if stack.characters.last != "π" {
            
            
            if negative == false {
                handleInput("3.14159265358979323846264338327950288419716939937510582")
            } else {
                handleInput("-3.14159265358979323846264338327950288419716939937510582")
                negative = false
            }
            
            
            stack = stack.stringByReplacingOccurrencesOfString("3.14159265358979323846264338327950288419716939937510582", withString: "π")
            stackview.text = stack
        }
        
    }

    @IBAction func copyBtnPress(sender: AnyObject) { // Copy stuff! It works now.
        
            UIPasteboard.generalPasteboard().string = self.stackview.text
        
        copyoutlet.setTitle("done", forState: .Normal)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      // these two button presses let us load the UI more reliably.        
        btn6Press(UIButton)
        BackSpaceTap(UIButton)
        // Do any additional setup after loading the view from its nib.
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
