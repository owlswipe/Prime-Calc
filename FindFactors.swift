// This algorithm powers Prime Calc's superfast offline factor-finding tool. 
// You can find all of the factors for numbers into the quadrillions almost instantly.

func factors(n: Int) -> [Int] {
    print("now finding factors...")
    
    var result = [Int]()
    
    for factor in (1...sqrt(n)).filter ({ n % $0 == 0 }) {
        
        result.append(factor)
        
        if n/factor != factor { result.append(n/factor) }
    }
    
    return result.sort()
    
}
