// Instantly determine if any number is prime or not.
// Note: If you are also using code from FindFactors.swift, you can use that function (instead of this one) to determine if a number is prime: it's prime if the number has exactly two factors.

func checkprime (let fromNumber: Int) -> Bool {
    
    print("now checking primality...")
    
    var prime = true
    
    for var i:Float = 2; Double(i) <= ceil(sqrt(Double(fromNumber))); i += 1 {
        
        if Double(fromNumber) % Double(i) == 0 {
            i = Float(ceil(sqrt(Double(fromNumber)))) + 7900000000000000000
            prime = false
        }
}
return prime
}
