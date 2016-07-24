//
//  Calculator.swift
//  Prime Calc
//
//  Created by Henry Stern on 12/17/15.
//  Copyright © 2016 One Studio. All rights reserved.
//


import UIKit

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

struct controlbooleans {
    
    var calccontrol:Bool = false
}
var y = controlbooleans()

// setting up the functions.


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


class ViewController2: UIViewController, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var powerinsertview: powerinsert!
    var buttonrecall = "" // tracks all the button presses so that when the user presses backspace, we do all the button presses before the last one.
            let defaults = NSUserDefaults.standardUserDefaults()
    var inputting = false // if user is inputting a square root or power, this deactivates UIKeyCommand so they're no longer typing into the calculator.
    
    var keycommandstatus = "removed" // this lets us not add duplicate key commands later.
    
    var actionSheetController: alertcontrollerinterface = alertcontrollerinterface()
    
    var squareroot:Double = 0 // part of squaring numbers
    
    var powerArray: [Int] = []
    var fractioncheck = "0" // will allow us to check if the fraction conversion is exact or approximate.
    
    func zeroes (input: Int) -> Double {
        
        var multiplier:Double = 1
        
        for var put = 1; put <= input; put += 1 {
            
            multiplier = Double(multiplier) * 10
            
            // gotta get that tens place right!
        }
        
        return multiplier
    }
    
    func converttofraction() {
        
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
    
    
    var stack = "" // the stack is an un-garbled transcript of what the user has entered. It's what appears just below the calculator number display with a copy button next to it.
    
    var negative = false // enables negativeness via minus button.
    
    @IBOutlet var calculatortextfield: UITextField!
    
    @IBOutlet weak var fractionconversion: UILabel!
     var calc7 = ""
    
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
    
    
    @IBAction func clear(sender: AnyObject) { // from an old version of calcy, before it was called calcy, and had a text field that you could type into.
        calculatortextfield.text = ""
        
    }
    @IBOutlet var LongPressBackspace: UILongPressGestureRecognizer!
    
    @IBOutlet weak var sendoutlet: UIButton!
    @IBAction func SEND(sender: AnyObject) { // this button now controls special buttons
        
        if btnSqrt.hidden == true {
        btnSwipe(UIButton) // show the special functions
        } else {
        btnSwipeReset(UIButton) // hide the special functions
            
        }
    
    // setting up our calculator variables...
    
        var accumulator: Double = 0.0 // We store the calculated value here
        var userInput = "" // User-entered digits
        
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
    
        func handleInputWithoutAddingToStack(str: String) {
            fracview.text = ""
            
            if stack.characters.last != "π" {
                
                print(opStack)
                print(numStack)
                
                print(stack)
                print(str)
                
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
            }
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
                print("this is calc7: \(calc7)")
                
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
            
            copyoutlet.hidden = false
            
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
            
        }


        // UI Set-up

    @IBOutlet weak var btnSqrt: UIButton!
    
    @IBOutlet weak var btnPower: UIButton!
    
    @IBOutlet weak var btnPi: UIButton!
    
    @IBOutlet weak var btnOneOverX: UIButton!
    
        @IBOutlet var numField: UITextField!
        @IBOutlet var btnClear: UIButton!
        @IBOutlet var bntEquals: UIButton!
        @IBOutlet var btnAdd: UIButton!
        @IBOutlet var btnSubtract: UIButton!
        @IBOutlet var btnMultiply: UIButton!
        @IBOutlet var btnDivide: UIButton!
        @IBOutlet var btnDecimal: UIButton!
      @IBOutlet var btnSwipe: UISwipeGestureRecognizer! // swipe to reveal extra buttons, if desired.
        
        @IBOutlet var btn0: UIButton!
        @IBOutlet var btn1: UIButton!
        @IBOutlet var btn2: UIButton!
        @IBOutlet var btn3: UIButton!
        @IBOutlet var btn4: UIButton!
        @IBOutlet var btn5: UIButton!
        @IBOutlet var btn6: UIButton!
        @IBOutlet var btn7: UIButton!
        @IBOutlet var btn8: UIButton!
        @IBOutlet var btn9: UIButton!
    
    @IBOutlet weak var fracview: UILabel!
    
    @IBOutlet weak var stackview: UILabel!
    
    @IBOutlet weak var copyoutlet: UIButton!
        
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
            powerinsertview.hidden = true
            btnPowerInsertPress.hidden = true
            btnPower.setTitle("^", forState: .Normal)
            powerinsertview.resignFirstResponder()
            powerinsertview.text = ""
        }
    
    
    @IBOutlet var BackspaceTap: UITapGestureRecognizer!
    
    @IBOutlet var BtnSwipeReset: UISwipeGestureRecognizer!
    
    
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
        
        for b in 0 ..< SavedButtonsRecall.count { // deletes everything from the calculator, then repeats everything the user pressed except the very last push, to undo last.
    
            print("doing recall number \(b), which is the character \(SavedButtonsRecall[b])")
            
            if String(SavedButtonsRecall)[b] == "P" {
                btnPowerPress(UIButton)
                powerinsertview.text = String(powerArray[powerArray.count-1])
                powerArray.removeAtIndex(powerArray.count-1)
                btnPowerInsertPress(UIButton)
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
            
            stack = stack + "=\(calculatortextfield.text!) | "
                    
                    calc7 = calculatortextfield.text!
            print(stack)
            
            stackview.text = stack
            copyoutlet.hidden = false
            
                }
                }
            }
            
            converttofraction()
            
    }
    
    
    
    @IBAction func btnOneOverXPress(sender: AnyObject) {
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
                
                stack = stack + "=\(calculatortextfield.text!) | "
                
            }
            
            stackview.text = stack
            calc7 = calculatortextfield.text!
        
            
            
        }
        
        converttofraction()
    }
    
    
    @IBAction func btnSqrtPress(sender: AnyObject) {
    
        if stack == "" || stack.hasSuffix("+") || stack.hasSuffix("-") || stack.hasSuffix("/") || stack.hasSuffix("*") { // if we need a number to take the square root of
            
            //Create the AlertController that we will use to ask the user what number they'd like to find the square root of.
            actionSheetController = alertcontrollerinterface(title: "Enter number", message: "Enter a number to find its square root", preferredStyle: .Alert)
            for command in self.globalKeyCommands {
                self.removeKeyCommand(command)
            }
            
            
            inputting = true
            
            var inputTextField: UITextField?
            inputTextField?.keyboardType = .NumberPad
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                self.inputting = false
                for command in self.globalKeyCommands {
                    self.addKeyCommand(command)
                }
            }
            actionSheetController.addAction(cancelAction)
            //Create and add an option action
            let nextAction: UIAlertAction = UIAlertAction(title: "Submit", style: .Default) { action -> Void in
                for command in self.globalKeyCommands {
                    self.addKeyCommand(command)
                }
                self.inputting = false
                if Double(inputTextField!.text!) != nil {
                    self.stack = self.stack + "√(\(inputTextField!.text!))"
                    self.stackview.text = self.stack
                    self.squareroot = sqrt(Double(inputTextField!.text!)!)
                    var nowsquared = String(self.squareroot)
                    if nowsquared.hasSuffix(".0") {
                        nowsquared = nowsquared.stringByReplacingOccurrencesOfString(".0", withString: "")
                    }
                    self.handleInputWithoutAddingToStack(nowsquared)
                    self.converttofraction()
                    self.doEquals()
                }
                
            }
            actionSheetController.addAction(nextAction)
            //Add a text field
            actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
                // you can use this text field
                inputTextField = textField
                textField.keyboardType = UIKeyboardType.NumberPad
                inputTextField?.keyboardType = UIKeyboardType.NumberPad
            }
            
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
            
        } else { // if we should square root the whole thing
        
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
            
            stack = stack + "√\(saved)=\(calculatortextfield.text!) | "
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
    
        
        converttofraction()
        }
    }
    
    
    @IBOutlet weak var btnPowerInsertPress: UIButton!
    
    @IBOutlet weak var powersymbol: UILabel!
    
    @IBAction func btnPowerInsertPress(sender: AnyObject) {
        let saved = calculatortextfield.text!
        doEquals()
        

        if let tobepowered = Double(self.calculatortextfield.text!) {
            if let power = Int(powerinsertview.text!) {
                buttonrecall = buttonrecall + "P"
                powerArray.append(power)
                
                let powered = tobepowered ^^ Double(power)
                
                self.accumulator = powered
                self.calculatortextfield.text = String(powered)
                updateDisplay()
                
                powerinsertview.hidden = true
                btnPowerInsertPress.hidden = true
                btnPower.setTitle("^", forState: .Normal)
                powerinsertview.resignFirstResponder()
                if stack.hasSuffix(" | ") {
                    
                    stack = stack + "\(saved)^\(power)=\(calculatortextfield.text!) | "
                    calc7 = calculatortextfield.text!
                    
                } else {
                    
                    if stack.containsString("| ") {
                        let equalsrange = stack.rangeOfString("| ", options:NSStringCompareOptions.BackwardsSearch)
                        stack = stack.stringByReplacingCharactersInRange(equalsrange!, withString: "| (")
                        stack = stack + ")^\(power)"
                        stackview.text = stack
                    } else { // = hasn't been presssed on this calculating session yet
                        
                        stack = "(" + stack + ")^\(power)"
                        
                    }
                    
                    stack = stack + "=\(calculatortextfield.text!) | "
                    
                }
                
                stackview.text = stack
                calc7 = calculatortextfield.text!
            
                updateDisplay()
                
                
                
            }
            
        }

        powerinsertview.text = ""
        converttofraction()
        btnSwipeReset(UIButton)
    }
    
    
    @IBAction func btnPowerPress(sender: AnyObject) {
        

        if stack != "" {
        powerinsertview.hidden = false
        btnPowerInsertPress.hidden = false
        btnPower.setTitle("", forState: .Normal)
        powerinsertview.becomeFirstResponder()
        }
        
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
    @IBAction func btnSwipe(sender: AnyObject) { // Shows special functions
        sendoutlet.setTitle("Hide Special", forState: .Normal)
        btn0.hidden = true
        btn1.hidden = true
        btn2.hidden = true
        btn3.hidden = true
        btn4.hidden = true
        btn5.hidden = true
        btn6.hidden = true
        btn7.hidden = true
        btn8.hidden = true
        btn9.hidden = true
        btnSubtract.hidden = true
        btnMultiply.hidden = true
        btnAdd.hidden = true
        btnDivide.hidden = true
        btnDecimal.hidden = true
        bntEquals.hidden = true
        btnPower.hidden = false
        btnOneOverX.hidden = false
        btnSqrt.hidden = false
        btnPi.hidden = false
        
    }
    
    
    @IBAction func btnSwipeReset(sender: AnyObject) { // Hides special functions
        sendoutlet.setTitle("Show Special", forState: .Normal)
        btn0.hidden = false
        btn1.hidden = false
        btn2.hidden = false
        btn3.hidden = false
        btn4.hidden = false
        btn5.hidden = false
        btn6.hidden = false
        btn7.hidden = false
        btn8.hidden = false
        btn9.hidden = false
        btnSubtract.hidden = false
        btnMultiply.hidden = false
        btnAdd.hidden = false
        btnDivide.hidden = false
        btnDecimal.hidden = false
        bntEquals.hidden = false
        btnPower.hidden = true
        btnOneOverX.hidden = true
        btnSqrt.hidden = true
        btnPi.hidden = true
        powerinsertview.hidden = true
        btnPowerInsertPress.hidden = true
        btnPower.setTitle("^", forState: .Normal)
        powerinsertview.resignFirstResponder()
        if powerinsertview.text != "" {
        btnPowerInsertPress(UIButton)
        powerinsertview.text = ""
        }
    }

    
    
    @IBAction func copyBtnPress(sender: AnyObject) { // Copy entire equation.
        
        var tocopy = stackview.text
        if tocopy!.hasSuffix(" | ") {
            print("has suffix")
            
            let truncaterange = tocopy!.rangeOfString(" | ", options:NSStringCompareOptions.BackwardsSearch)!
            print("found range")
            tocopy = tocopy!.stringByReplacingCharactersInRange(truncaterange, withString: "")
            
        }
        
        
        let clipboardalert = UIAlertController(title: "Calculations", message: "\(tocopy!)", preferredStyle: UIAlertControllerStyle.Alert)
        clipboardalert.addAction(UIAlertAction(title: "Copy to Clipboard", style: .Default, handler: { (action: UIAlertAction!) in
            print("stack copied to clipboard.")
            UIPasteboard.generalPasteboard().string = tocopy
        }))
        clipboardalert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("viewed stack.")
        }))

        
        presentViewController(clipboardalert, animated: true, completion: nil)
    }
    
    let globalKeyCommands = [UIKeyCommand(input: "1234567890+-x/=.", modifierFlags: [], action: Selector("Demonstrate:"), discoverabilityTitle: "Type numbers and symbols"), UIKeyCommand(input: "1", modifierFlags: [], action: Selector("One:")), UIKeyCommand(input: "2", modifierFlags: [], action: Selector("Two:")), UIKeyCommand(input: "3", modifierFlags: [], action: "Three:"), UIKeyCommand(input: "4", modifierFlags: [], action: "Four:"), UIKeyCommand(input: "5", modifierFlags: [], action: "Five:"), UIKeyCommand(input: "6", modifierFlags: [], action: "Six:"), UIKeyCommand(input: "7", modifierFlags: [], action: "Seven:"), UIKeyCommand(input: "8", modifierFlags: [], action: "Eight:"), UIKeyCommand(input: "9", modifierFlags: [], action: "Nine:"), UIKeyCommand(input: "0", modifierFlags: [], action: "Zero:"), UIKeyCommand(input: "+", modifierFlags: [], action: "Plus:"), UIKeyCommand(input: "-", modifierFlags: [], action: "Minus:"), UIKeyCommand(input: "/", modifierFlags: [], action: "Divide:"), UIKeyCommand(input: "÷", modifierFlags: [], action: Selector("Divide:")), UIKeyCommand(input: "*", modifierFlags: [], action: "Times:"), UIKeyCommand(input: "x", modifierFlags: [], action: Selector("Times:")), UIKeyCommand(input: "=", modifierFlags: [], action: "Equals:"), UIKeyCommand(input: "^", modifierFlags: [], action: "Power:", discoverabilityTitle: "Raise to power"), UIKeyCommand(input: "p", modifierFlags: [], action: "Pi:", discoverabilityTitle: "Insert Pi"), UIKeyCommand(input: "r", modifierFlags: [], action: "Reciprocal:", discoverabilityTitle: "Find reciprocal (1/x)"), UIKeyCommand(input: "√", modifierFlags: [], action: "Sqrt:"), UIKeyCommand(input: "s", modifierFlags: [], action: "Sqrt:", discoverabilityTitle: "Square root"), UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: [], action: "Over:"), UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: "Back:"), UIKeyCommand(input: "\u{8}", modifierFlags: [], action: "Backspace:", discoverabilityTitle: "Backspace"), UIKeyCommand(input: "\u{8}", modifierFlags: .Command, action: "Clear:", discoverabilityTitle: "Clear"), UIKeyCommand(input: String(ENTER), modifierFlags: [], action: "Equals:"), UIKeyCommand(input: "\r", modifierFlags: [], action: Selector("Equals:")), UIKeyCommand(input: "R", modifierFlags: .Shift, action: "Reciprocal:"), UIKeyCommand(input: "P", modifierFlags: .Shift, action: "Pi:"), UIKeyCommand(input: "S", modifierFlags: .Shift, action: "Sqrt:"), UIKeyCommand(input: ".", modifierFlags: [], action: "Dec:"), UIKeyCommand(input: "0", modifierFlags: [], action: Selector("Zero:"))]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionSheetController.enableKeyCommands = { [weak self] enabled in
            if enabled {
                for command in self!.globalKeyCommands {
                    self?.addKeyCommand(command)
                    print(self!.keycommandstatus)
                    print("added a key command.")
                    self!.keycommandstatus = "added"
                    print(self!.keycommandstatus)
                }
            } else {
                for command in self!.globalKeyCommands {
                    self?.removeKeyCommand(command)
                    print("removed a key command.")
                    print(self!.keycommandstatus)
                    self!.keycommandstatus = "removed"
                    print(self!.keycommandstatus)
                }
            }
        }
        
        powerinsertview.resignFirstResponder()
        
        
        // ...
        
        
        // globalKeyCommands is a view controller property
        
        // Add key commands to be on by default
        for command in globalKeyCommands { self.addKeyCommand(command); print("added key command \(command)") }
        
        // Configure text field to callback when
        // it should enable key commands
        powerinsertview.enableKeyCommands = { [weak self] enabled in
            if enabled {
                if self!.keycommandstatus == "removed" {
                    self!.keycommandstatus = "added"
                print("adding commands.")
                for command in self!.globalKeyCommands {
                    self?.addKeyCommand(command)
                    print("adding the key command \(command) because of powerinsertview.")
                }
                }
            } else {
                self!.keycommandstatus = "removed"
                for command in self!.globalKeyCommands {
                    self?.removeKeyCommand(command)
                    print("removing the key command \(command) because of powerinsertview.")
                }
            }
        }

        
        let height = UIScreen.mainScreen().bounds.height
        
        // adjustment based on size of device.
        if height < 569 {
            btn9.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn8.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn7.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn6.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn5.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn4.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn3.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn2.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn1.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btn0.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnDecimal.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            bntEquals.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnDivide.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnMultiply.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnDecimal.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            bntEquals.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnAdd.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnSubtract.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnOneOverX.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnPi.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnPower.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            btnSqrt.titleLabel!.font =  UIFont(name: "Helvetica", size: 65)
            
        } else {
            btn9.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn8.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn7.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn6.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn5.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn4.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn3.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn2.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn1.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btn0.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnDecimal.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            bntEquals.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnDivide.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnMultiply.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnDecimal.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            bntEquals.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnAdd.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnSubtract.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnOneOverX.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnPi.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnPower.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)
            btnSqrt.titleLabel!.font =  UIFont(name: "Helvetica", size: 81)

        }
        
        calculatortextfield.layer.borderColor = UIColor.clearColor().CGColor
        
        if calculatortextfield.text == "" {
            buttonrecall = ""
        }
        
        
        
        lp.vccalc = true
        lp.vccompare = false
        lp.vcprime = false
        lp.vcfraccalc = false
        
        copyoutlet.hidden = true // make that copy button next to the stack view hide when there's nothin' in the stack (that the user has done)
        
    // MARK: UITextFieldDelegate
        
        powerinsertview.delegate = self
        
        
    }
    
    

    
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            btnPowerInsertPress(UIButton)
            return false
        } else {
            let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars < 4;

        return true
    }
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("viewwilldisappear")
                        for command in self.globalKeyCommands {
                            
                    self.removeKeyCommand(command)
                            print("removing command since we're leaving calc view.")
                            self.keycommandstatus = "removed"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
     

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */

}

    func One(sender: UIKeyCommand) {
        print("One pressed")
        btn1Press(UIButton)
    }
    
    func Two(sender: UIKeyCommand) {
        print("Two pressed")
        btn2Press(UIButton)
    }
    
    func Three(sender: UIKeyCommand) {
        print("Three pressed")
        btn3Press(UIButton)
    }
    
    func Four(sender: UIKeyCommand) {
        print("Four pressed")
        btn4Press(UIButton)
    }
    func Five(sender: UIKeyCommand) {
        print("Five pressed")
        btn5Press(UIButton)
        
    }
    
    func Six(sender: UIKeyCommand) {
        print("Six pressed")
        btn6Press(UIButton)
        
    }
    func Seven(sender: UIKeyCommand) {
        print("Seven pressed")
        btn7Press(UIButton)
        
    }
    
    func Eight(sender: UIKeyCommand) {
        print("Eight pressed")
        btn8Press(UIButton)
        
    }
    func Nine(sender: UIKeyCommand) {
        print("Nine pressed")
        
        btn9Press(UIButton)
    }
    
    func Zero(sender: UIKeyCommand) {
        print("Zero pressed")
        btn0Press(UIButton)
    }
    func Plus(sender: UIKeyCommand) {
        print("Plus pressed")
        btnPlusPress(UIButton)
        
    }
    
    func Minus(sender: UIKeyCommand) {
        print("Minus pressed")
        btnMinusPress(UIButton)
        
    }
    func Times(sender: UIKeyCommand) {
        print("Times pressed")
        btnMultiplyPress(UIButton)
    }
    
    func Divide(sender: UIKeyCommand) {
        print("Divide pressed")
        btnDividePress(UIButton)
    }
    
    func Equals(sender: UIKeyCommand) {
        print("Equals pressed")
        btnEqualsPress(UIButton)
    }
    
    func Over(sender: UIKeyCommand) {
        print("Over pressed")
        btnSwipe(UIButton)
        
    }
    func Back(sender: UIKeyCommand) {
        print("Back pressed")
        btnSwipeReset(UIButton)
    }
    func Pi(sender: UIKeyCommand) {
        print("Pi pressed")
        btnPiPress(UIButton)
        
    }
    func Sqrt(sender: UIKeyCommand) {
        print("Sqrt pressed")
        btnSqrtPress(UIButton)
        
    }
    func Reciprocal(sender: UIKeyCommand) {
        print("Reciprocal pressed")
        btnOneOverXPress(UIButton)
        
    }
    func Power(sender: UIKeyCommand) {
        print("Power pressed")
        btnSwipe(UIButton)
        btnPowerPress(UIButton)
    }
    func Backspace(sender: UIKeyCommand) {
        print("Backspace pressed")
        BackSpaceTap(UIButton)
    }
    func Clear(sender: UIKeyCommand) {
        print("Clear pressed")
        btnACPress(UIButton)
    }
    func Demonstrate(sender: UIKeyCommand) {
        print("Demonstrate pressed")
        clearbutton(UIButton)
    }
    
    func Dec(sender: UIKeyCommand) {
        print("decimal pressed")
        btnDecPress(UIButton)
    }


}

