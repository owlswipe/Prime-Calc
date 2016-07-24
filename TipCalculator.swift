// The tip calculator.

    var billamount = 0.0
    var tipamount = 0.0
    var splittingpeople = 1
    
    // You must obtain the user's desired values for those variables above before proceeding.

                let formatter = NSNumberFormatter()
                formatter.numberStyle = .CurrencyStyle
                formatter.locale = NSLocale(localeIdentifier: "en_US") // This is the default
                let tip1value = self.tipamount/Double(self.splittingpeople)
                let tip1string = formatter.stringFromNumber(tip1value) // returns the amount formatted to US currency style.
                let total1value = (self.tipamount + self.billamount)/Double(self.splittingpeople)
                let total1string = formatter.stringFromNumber(total1value)
                let tip2value = self.tipamount
                let tip2string = formatter.stringFromNumber(tip2value)
                let total2value = self.tipamount + self.billamount
                let total2string = formatter.stringFromNumber(total2value)
                
                let PerPersonTip = tip1string
                let PerPersonTotal = total1string
                let TotalTip = tip2string
                let TotalTotal = total2string
                print(PerPersonTip)
                print(PerPersonTotal)
                print(TotalTip)
                print(TotalTotal)
