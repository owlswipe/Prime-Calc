//
//  ViewController7.swift
//  Is It Prime copy
//
//  Created by Henry Stern on 2/12/16.
//  Copyright © 2016 The Math Guys. All rights reserved.
//

// fraction calculator!


import UIKit

struct timers {
    
    var numbers = NSTimer()
    var sendto = "10005"
}
var v = timers()

class ViewController7: UIViewController, UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    func checkwidth() { // this function runs with the timer lp.widthtimer to check the width and make a couple of changes for split view
        
        
        let width = UIScreen.mainScreen().applicationFrame.size.width
        
        
        if width < 507 {
            
            num1.textAlignment = NSTextAlignment.Right
            num2.textAlignment = NSTextAlignment.Left
            den1.textAlignment = NSTextAlignment.Right
            den2.textAlignment = NSTextAlignment.Left
            fraction1.textAlignment = NSTextAlignment.Right
            fraction2.textAlignment = NSTextAlignment.Left
            
            
        } else {
            num1.textAlignment = NSTextAlignment.Center
            num2.textAlignment = NSTextAlignment.Center
            den1.textAlignment = NSTextAlignment.Center
            den2.textAlignment = NSTextAlignment.Center
            fraction1.textAlignment = NSTextAlignment.Center
            fraction2.textAlignment = NSTextAlignment.Center
            
        }
        
        // it also helps us manage the "plus" and change it to whatever operator is selected.
        
        if control1.selectedSegmentIndex == 0 {
            selectedoperator.text = "Plus"
        } else if control1.selectedSegmentIndex == 1 {
            selectedoperator.text = "Minus"
        } else if control1.selectedSegmentIndex == 2 {
            selectedoperator.text = "Times"
        } else {
            selectedoperator.text = "Divided by"
        }
    }

    @IBOutlet weak var selectedoperator: UILabel!
    
    func greatestCommonDenominator(a: Int, b: Int) -> Int {
        return b == 0 ? a : greatestCommonDenominator(b, b: a % b)
    }
    
    
    func leastCommonMultiple(a: Int, b: Int) -> Int {
        if lp.numbercopy != 0 && lp.numbercopy2 != 0 {
            return a * (b / greatestCommonDenominator(a, b: b))
        } else {
            return 0
        }
    }
    
    
    
    var time = 00
    
    func countdown() { // so we check every thousandth of a second if your text entry contains a line break, which means you pressed return, then we clear that line break and go on to the next text entry (or, if you're on the second denominator, we press go for you).
        time += 1
        if num1.isFirstResponder() {
            if num1.text.containsString("\n") {
                den1.becomeFirstResponder()
                num1.text = num1.text.stringByReplacingOccurrencesOfString("\n", withString: "")
            }
        }
        if num2.isFirstResponder() {
            if num2.text.containsString("\n") {
                num2.resignFirstResponder()
                den2.becomeFirstResponder()
                num2.text = num2.text.stringByReplacingOccurrencesOfString("\n", withString: "")
            }
        }
        
        if den1.isFirstResponder() {
            if den1.text.containsString("\n") {
                den1.resignFirstResponder()
                num2.becomeFirstResponder()
                den1.text = den1.text.stringByReplacingOccurrencesOfString("\n", withString: "")
            }
        }
        
        if den2.isFirstResponder() {
            if den2.text.containsString("\n") {
                den2.text = den2.text.stringByReplacingOccurrencesOfString("\n", withString: "")
                calculate(UIButton)
            }
        }



    }

    @IBOutlet weak var decresut: UILabel!
    @IBOutlet weak var numresult: UILabel!
    @IBOutlet weak var denresult: UILabel!
    @IBOutlet weak var operatingerror: UILabel!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var num1: UITextView!
    @IBOutlet weak var den1: UITextView!
    @IBOutlet weak var num2: UITextView!
    @IBOutlet weak var den2: UITextView!
    @IBOutlet weak var control1: UISegmentedControl!
    
    override func viewDidAppear(animated: Bool) {
        
        lp.widthtimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(ViewController7.checkwidth), userInfo: nil, repeats: true) // runs every hundredth of a second to check the width of the window in coordination with the checkwidth function
        
        
        if let isFirstRun = NSUserDefaults.standardUserDefaults().stringForKey("iSFirstRun") {
            print("found iSFirstRun string key.")
            
            if isFirstRun == "just fraction left" { // user hasn't been in fraction calculator before.
                print("is First Run is just fraction left!")
            
                
                let refreshAlert = UIAlertController(title: "Welcome to the fraction calculator", message: "Type in one fraction (under \"fraction 1\"), press +, -, x, or ÷, and then enter in the second fraction, under \"fraction 2\". We'll calculate the result instantly.", preferredStyle: UIAlertControllerStyle.Alert)
                
                refreshAlert.addAction(UIAlertAction(title: "OK, exit tutorial.", style: .Default, handler: { (action: UIAlertAction!) in
                    print("they got the fraction calculator tutorial alert.")
                    
                }))
                presentViewController(refreshAlert, animated: true, completion: nil)
                
                
                // then update userDefaults to make sure we never have this intro sequence again.
                NSUserDefaults.standardUserDefaults().setValue("yes", forKey: "iSFirstRun")
                
                
                
                
            } else { // user has already been to the fraction calcy
                let width = UIScreen.mainScreen().applicationFrame.size.width
                if width < 507 {
                    fraction1.hidden = true
                    fraction2.hidden = true
                    selectedoperator.hidden = true
                }
            }
            
        }

        
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        lp.widthtimer.invalidate()
    }

    
    @IBAction func calculate(sender: AnyObject) {
        
        if num2.text == "0" && control1.selectedSegmentIndex == 3 {
            
            error.text = "Zero can not be the second numerator while dividing."
            
        } else {
        error.text = ""
        if den1.text == "0" || den2.text == "0" {
            error.text = "Zero can not be a denominator."
        } else {
        
        operatingerror.hidden = true
        if var numA:Int = Int(num1.text) {
            if var numB:Int = Int(num2.text) {
                if var denA:Int = Int(den1.text) {
                    if var denB:Int = Int(den2.text) {
                        
                        den2.resignFirstResponder()
                        // do all the stuff here.
                        if control1.selectedSegmentIndex != 0 && control1.selectedSegmentIndex != 1 && control1.selectedSegmentIndex != 2 && control1.selectedSegmentIndex != 3 {
                            operatingerror.hidden = false
                        } else {
                            // do stuff here for if operator is selected.
                            
                            if control1.selectedSegmentIndex == 0 {
                                // adding
                                
                                if Double(numA) < 4.611686e+18 && Double(numB) < 4.611686e+18 && Double(denA) * Double(denB) < 9223372036854775808 {
                                    
                                    // to add...
                                    // finding decimal: we divide the first numerator by the first denominator, and the second numerator by the second denominator to find the fraction, then add those results together.
                                    // finding fraction: we find the lcm of the denominators, and give each fraction the same denominator (by multiplying the numerators of each fraction by the same amount we needed to multiply each denominator to get the lcm, then adding the numerators and putting it atop the shared denominator.
                                    
                                let frac1:Float = Float(numA) / Float(denA)
                                let frac2:Float = Float(numB) / Float(denB)
                                let finalfrac:Float = frac1 + frac2
                                decresut.text = String(finalfrac)
                                let range = decresut.text!.rangeOfString(".")!
                                
                                let firstPart = decresut.text![range.startIndex..<(decresut.text?.endIndex)!]
                                print(firstPart)
                                
                                if firstPart.characters.count > 3 {
                                    decresut.text = "about \(finalfrac)"
                                }
                                
                                let lcm = leastCommonMultiple(denA, b: denB)
                                
                                let numAmultiplier = lcm / denA
                                let numBmultiplier = lcm / denB
                                
                                numA = numA * numAmultiplier
                                numB = numB * numBmultiplier
                                denA = lcm
                                denB = lcm
                                
                                print("numAmultipler: \(numAmultiplier); numBmultiplier: \(numBmultiplier)")
                                print("numA: \(numA); numB: \(numB)")
                                
                                denresult.text = String(denA)
                                numresult.text = String(numA+numB)
                                
                                print("the fraction is \(numresult.text) over \(denresult.text); the decimal is \(decresut.text)")
                                } else {
                                    
                                    error.text = "Sorry. Some of the numbers may not work because they are too large."
                                }
                                
                                
                            }
                            if control1.selectedSegmentIndex == 1 {
                                // subtracting
                                
                                // to subtract...
                                // finding decimal: we divide the first numerator by the first denominator, and the second numerator by the second denominator to find the fraction, then subtract the first by the second.
                                // finding fraction: we find the lcm of the denominators, and give each fraction the same denominator (by multiplying the numerators of each fraction by the same amount we needed to multiply each denominator to get the lcm, then subtracting the first numerator by the second and putting it atop the shared denominator.
                                
                                if Double(numA) - Double(numB) < 9223372036854775808 && Double(numB) - Double(numA) < 9223372036854775808 && Double(denA) * Double(denB) < 9223372036854775808 {
                            
                                    let frac1:Float = Float(numA) / Float(denA)
                                    let frac2:Float = Float(numB) / Float(denB)
                                    let finalfrac:Float = frac1 - frac2
                                    decresut.text = String(finalfrac)
                                    let range = decresut.text!.rangeOfString(".")!
                                    
                                    let firstPart = decresut.text![range.startIndex..<(decresut.text?.endIndex)!]
                                    print(firstPart)
                                    
                                    if firstPart.characters.count > 3 {
                                        decresut.text = "about \(finalfrac)"
                                    }
                                    
                                    let lcm = leastCommonMultiple(denA, b: denB)
                                    
                                    let numAmultiplier = lcm / denA
                                    let numBmultiplier = lcm / denB
                                    
                                    numA = numA * numAmultiplier
                                    numB = numB * numBmultiplier
                                    denA = lcm
                                    denB = lcm
                                    
                                    print("numAmultipler: \(numAmultiplier); numBmultiplier: \(numBmultiplier)")
                                    print("numA: \(numA); numB: \(numB)")
                                    
                                    denresult.text = String(denA)
                                    numresult.text = String(numA-numB)
                                    
                                    print("the fraction is \(numresult.text) over \(denresult.text); the decimal is \(decresut.text)")
                                } else {
                                    
                                    error.text = "Sincerest apologies; the denominators are too large for us to reliably compute!"
                                }
                                
                            }
                            if control1.selectedSegmentIndex == 2 {
                                // multiplying
                                
                                // to multiply...
                                // finding decimal: we divide the first numerator by the first denominator, and the second numerator by the second denominator to find the fraction, then multiply them together.
                                // finding fraction: we multiply the numerators and the denominators, then we find the gcd and divide the numerator and denominator by that.
                                
                                if numA < 3037000499 && numB < 3037000499 && Double(denA) * Double(denB) < 9223372036854775808 {
                                
                                let frac1:Float = Float(numA) / Float(denA)
                                let frac2:Float = Float(numB) / Float(denB)
                                let finalfrac:Float = frac1 * frac2
                                decresut.text = String(finalfrac)
                                let range = decresut.text!.rangeOfString(".")!
                                
                                let firstPart = decresut.text![range.startIndex..<(decresut.text?.endIndex)!]
                                print(firstPart)
                                
                                if firstPart.characters.count > 3 {
                                    decresut.text = "about \(finalfrac)"
                                }

                                
                                var numerator = numA * numB
                                var denominator = denA * denB
                                
                                let gcd = greatestCommonDenominator(numerator, b: denominator)
                                
                                if gcd != 1 {
                                    
                                    numerator = numerator / gcd
                                    denominator = denominator / gcd
                                }
                                
                                numresult.text = String(numerator)
                                denresult.text = String(denominator)
                                    
                                } else {
                                    
                                    error.text = "Sorry, one numerator is too large (larger than 3037000499.98)."
                                }
                            
                                
                            }
                            if control1.selectedSegmentIndex == 3 {
                                
                                if numA * denB < 9223372036854775807 && numB * denA < 9223372036854775807 {
                                
                                // dividing
                                    
                                    // to divide...
                                    // finding decimal: we divide the first numerator by the first denominator, and the second numerator by the second denominator to find the fraction, then divide them.
                                    // finding fraction: we multiply the first numerator by the second denominator (to get the numerator), and the second numerator by the first denominator (to get the denominator). We find the gcd and divide the numerator and denominator by that.
                                
                                    
                                let frac1:Float = Float(numA) / Float(denA)
                                let frac2:Float = Float(numB) / Float(denB)
                                let finalfrac:Float = frac1 / frac2
                                decresut.text = String(finalfrac)
                                let range = decresut.text!.rangeOfString(".")!
                                
                                let firstPart = decresut.text![range.startIndex..<(decresut.text?.endIndex)!]
                                print(firstPart)
                                
                                if firstPart.characters.count > 3 {
                                    decresut.text = "about \(finalfrac)"
                                }

                                
                                var numerator = numA * denB
                                var denominator = numB * denA
                                
                                let gcd = greatestCommonDenominator(numerator, b: denominator)
                                if gcd != 1 {
                                    
                                    numerator = numerator / gcd
                                    denominator = denominator / gcd
                                }
                                
                                numresult.text = String(numerator)
                                denresult.text = String(denominator)
                                } else {
                                    
                                    error.text = "Some numbers too large to reliably compute."
                                }
                                
                            }
                            
                            
                         // final checks
                            if denresult.text!.containsString("-") {
                                
                                denresult.text = denresult.text!.stringByReplacingOccurrencesOfString("-", withString: "")
                                numresult.text = "-\(numresult.text!)"
                                
                            }
                            
                        }

                    } else {
                        error.text = "Second denominator is not an integer."
                    }
            } else {
                error.text = "First denominator is not an integer."
            }
            } else {
                error.text = "Second numerator is not an integer."
            }
        } else {
            error.text = "First numerator is not an integer."
            }
        }
            
        }
        
        if let _ = Int(numresult.text!) {
            if let _ = Int(denresult.text!) {
        
        
        let divider = greatestCommonDenominator(Int(numresult.text!)!, b: Int(denresult.text!)!)
        print("this is the divider: \(divider)")
        
        if divider != 1 {
            numresult.text = String(Int(numresult.text!)! / divider)
            denresult.text = String(Int(denresult.text!)! / divider)
        }

            }
        
            }
    }

    @IBAction func sendtodec(sender: AnyObject) { // enables the send to calcy function.
        
        if numresult.text != "" { // makes sure there is something to send to calcy.
            
            v.sendto = "\(numresult.text!)/\(denresult.text!)"
            performSegueWithIdentifier("fracsegue", sender: self)
            
        }
        
        
    }
        
    @IBAction func clear(sender: AnyObject) { // CLEAR EVERYTHING
        
        numresult.text = ""
        denresult.text = ""
        decresut.text = ""
        num1.text = ""
        num2.text = ""
        den1.text = ""
        den2.text = ""
        error.text = ""
        operatingerror.hidden = true
        num1.becomeFirstResponder()
        
    }

    
    @IBAction func numlongpress(sender: AnyObject) { // enables the long press gesture on top of the numerator.
        if sender.state == UIGestureRecognizerState.Began
        {
            if denresult.text != "" {
            den1.text = denresult.text
            num1.text = numresult.text
            den2.text = ""
            num2.text = ""
            num2.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func denlongpress(sender: AnyObject) { // and the long press gesture on top of the denominator.
        if sender.state == UIGestureRecognizerState.Began
        {
         
            if denresult.text != "" {
            den1.text = denresult.text
            num1.text = numresult.text
            den2.text = ""
            num2.text = ""
            num2.becomeFirstResponder()
            }
            
            
        }
    }
    @IBOutlet weak var fraction1: UILabel!
    
    @IBOutlet weak var fraction2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let isFirstRun = NSUserDefaults.standardUserDefaults().stringForKey("iSFirstRun") {
            
            if isFirstRun != "just fraction left" {
                let width = UIScreen.mainScreen().applicationFrame.size.width
                print("me, down here!")
                print(width)
                print(width)
                print(width)
                print(width)
                print(width)
                
                
                if width < 507 {
                    fraction1.hidden = true
                    fraction2.hidden = true
                    selectedoperator.hidden = true
                
            }
            }
        }
        
        let width = UIScreen.mainScreen().applicationFrame.size.width
        
        
        if width < 509 {
            
            num1.textAlignment = NSTextAlignment.Right
            num2.textAlignment = NSTextAlignment.Left
            den1.textAlignment = NSTextAlignment.Right
            den2.textAlignment = NSTextAlignment.Left
            fraction1.textAlignment = NSTextAlignment.Right
            fraction2.textAlignment = NSTextAlignment.Left
            
            
        } else {
            num1.textAlignment = NSTextAlignment.Center
            num2.textAlignment = NSTextAlignment.Center
            den1.textAlignment = NSTextAlignment.Center
            den2.textAlignment = NSTextAlignment.Center
            fraction1.textAlignment = NSTextAlignment.Center
            fraction2.textAlignment = NSTextAlignment.Center
            
        }
 
        
        let attr = NSDictionary(object: UIFont(name: "Avenir-Roman", size: 18.0)!, forKey: NSFontAttributeName)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as [NSObject : AnyObject] , forState: .Normal)
        
        lp.vccalc = false
        lp.vccompare = false
        lp.vcprime = false
        lp.vcfraccalc = true
        
        num1.clearsOnInsertion = true
        num2.clearsOnInsertion = true
        den1.clearsOnInsertion = true
        den2.clearsOnInsertion = true
        
        num1.delegate = self;
        num2.delegate = self;
        den1.delegate = self;
        den2.delegate = self;
        v.numbers = NSTimer.scheduledTimerWithTimeInterval(0.0001, target: self, selector: #selector(ViewController7.countdown), userInfo: nil, repeats: true) // checks every ten-thousandth of a second whether you've pressed the return key.
        
    }
    
    

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    let globalKeyCommands = [
        UIKeyCommand(input: "=", modifierFlags: .Shift, action: Selector("Add:")),
        UIKeyCommand(input: "-", modifierFlags: .Shift, action: Selector("selectTab2:")),
        UIKeyCommand(input: "x", modifierFlags: .Shift, action: Selector("selectTab3:")),
        UIKeyCommand(input: "/", modifierFlags: .Shift, action: Selector("selectTab4:")),
        UIKeyCommand(input: "S", modifierFlags: .Shift, action: Selector("selectTab2:"), discoverabilityTitle: "Subtract"),
        UIKeyCommand(input: "A", modifierFlags: .Shift, action: Selector("Add:"), discoverabilityTitle: "Add"),
        UIKeyCommand(input: "M", modifierFlags: .Shift, action: Selector("selectTab3:"), discoverabilityTitle: "Multiply"),
        UIKeyCommand(input: "D", modifierFlags: .Shift, action: Selector("selectTab4:"), discoverabilityTitle: "Divide"),
        UIKeyCommand(input: "E", modifierFlags: .Command, action: Selector("selectTab5:"), discoverabilityTitle: "Enter First Numerator Field"),
        UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .Command, action: Selector("back1:"), discoverabilityTitle: "Back one field"),
        UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .Command, action: Selector("forward1:"), discoverabilityTitle: "Forward one field"),
        
    ]
    
    override var keyCommands: [UIKeyCommand]? {
        if lp.vcfraccalc == true {
            return globalKeyCommands
        } else {
            return nil
        }
    }
    
    // ...
    
    
    func selectTab2(sender: UIKeyCommand) {
        print("command-s selected")
        control1.selectedSegmentIndex = 1
        
    }
    
    func back1(sender: UIKeyCommand) {
        print("back 1")
        if num1.isFirstResponder() {
            num1.resignFirstResponder()
        } else if num2.isFirstResponder() {
            den1.becomeFirstResponder()
        } else if den1.isFirstResponder() {
            num1.becomeFirstResponder()
        } else if den2.isFirstResponder() {
            num2.becomeFirstResponder()
        } else {
            den2.becomeFirstResponder()
        }
    }

    func forward1(sender: UIKeyCommand) {
        print("forward 1")
        if num1.isFirstResponder() {
            den1.becomeFirstResponder()
        } else if num2.isFirstResponder() {
            den2.becomeFirstResponder()
        } else if den1.isFirstResponder() {
            num2.becomeFirstResponder()
        } else if den2.isFirstResponder() {
            calculate(UIButton)
        } else {
            num1.becomeFirstResponder()
        }

        
    }

    
    
    func Add(sender: UIKeyCommand) {
        print("command-a selected")
        control1.selectedSegmentIndex = UISegmentedControlNoSegment
        control1.selectedSegmentIndex = 0
    }
    
    func selectTab3(sender: UIKeyCommand) {
        print("command-m selected")
        control1.selectedSegmentIndex = 2
    }
    
    func selectTab4(sender: UIKeyCommand) {
        print("command-d selected")
        control1.selectedSegmentIndex = 3
        
    }
    func selectTab5(sender: UIKeyCommand) {
        num1.becomeFirstResponder()
        
    }
    
    

    
    
}
