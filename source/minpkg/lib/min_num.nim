import 
  random
import 
  ../core/parser, 
  ../core/value, 
  ../core/interpreter, 
  ../core/utils

proc num_module*(i: In)=

  let def = i.define()

  def.symbol("nan") do (i: In):
    i.push newVal(NaN)
  
  def.symbol("inf") do (i: In):
    i.push newVal(Inf)
  
  def.symbol("-inf") do (i: In):
    i.push newVal(NegInf)
  
  def.symbol("+") do (i: In):
    let vals = i.expect("num", "num")
    let a = vals[0]
    let b = vals[1]
    if a.isInt:
      if b.isInt:
        i.push newVal(a.intVal + b.intVal)
      else:
        i.push newVal(a.intVal.float + b.floatVal)
    else:
      if b.isFloat:
        i.push newVal(a.floatVal + b.floatVal)
      else:
        i.push newVal(a.floatVal + b.intVal.float)
  
  def.symbol("-") do (i: In):
    let vals = i.expect("num", "num")
    let a = vals[0]
    let b = vals[1]
    if a.isInt:
      if b.isInt:
        i.push newVal(b.intVal - a.intVal)
      else:
        i.push newVal(b.floatVal - a.intVal.float)
    else:
      if b.isFloat:
        i.push newVal(b.floatVal - a.floatVal)
      else:
        i.push newVal(b.intVal.float - a.floatVal) 
  
  def.symbol("*") do (i: In):
    let vals = i.expect("num", "num")
    let a = vals[0]
    let b = vals[1]
    if a.isInt:
      if b.isInt:
        i.push newVal(a.intVal * b.intVal)
      else:
        i.push newVal(a.intVal.float * b.floatVal)
    else:
      if b.isFloat:
        i.push newVal(a.floatVal * b.floatVal)
      else:
        i.push newVal(a.floatVal * b.intVal.float)
  
  def.symbol("/") do (i: In):
    let vals = i.expect("num", "num")
    let a = vals[0]
    let b = vals[1]
    if a.isInt:
      if b.isInt:
        i.push newVal(b.intVal.int / a.intVal.int)
      else:
        i.push newVal(b.floatVal / a.intVal.float)
    else:
      if b.isFloat:
        i.push newVal(b.floatVal / a.floatVal)
      else:
        i.push newVal(b.intVal.float / a.floatVal) 
  
  def.symbol("randomize") do (i: In):
    randomize()

  def.symbol("random") do (i: In):
    let vals = i.expect("int")
    let n = vals[0]
    i.push n.intVal.int.rand.newVal

  def.symbol("div") do (i: In):
    let vals = i.expect("int", "int")
    let b = vals[0]
    let a = vals[1]
    i.push(newVal(a.intVal div b.intVal))
  
  def.symbol("mod") do (i: In):
    let vals = i.expect("int", "int")
    let b = vals[0]
    let a = vals[1]
    i.push(newVal(a.intVal mod b.intVal))

  def.symbol("succ") do (i: In):
    let vals = i.expect("int")
    let n = vals[0]
    i.push newVal(n.intVal + 1)

  def.symbol("pred") do (i: In):
    let vals = i.expect("int")
    let n = vals[0]
    i.push newVal(n.intVal - 1)
  
  def.symbol("even?") do (i: In):
    let vals = i.expect("int")
    let n = vals[0]
    i.push newVal(n.intVal mod 2 == 0)

  def.symbol("odd?") do (i: In):
    let vals = i.expect("int")
    let n = vals[0]
    i.push newVal(n.intVal mod 2 != 0)
    
  def.symbol("bitand") do (i: In):
    let vals = i.expect("int","int")
    let b = vals[0]
    let a = vals[1]
    i.push newVal(a.intVal and b.intVal)

  def.symbol("bitnot") do (i: In):
    let vals = i.expect("int")
    let a = vals[0]
    i.push newVal(not a.intVal)

  def.symbol("bitor") do (i: In):
    let vals = i.expect("int","int")
    let b = vals[0]
    let a = vals[1]
    i.push newVal(a.intVal or b.intVal)

  def.symbol("bitxor") do (i: In):
    let vals = i.expect("int","int")
    let b = vals[0]
    let a = vals[1]
    i.push newVal(a.intVal xor b.intVal)

  def.symbol("shl") do (i: In):
    let vals = i.expect("int","int")
    let b = vals[0]
    let a = vals[1]
    i.push newVal(a.intVal shl b.intVal)

  def.symbol("shr") do (i: In):
    let vals = i.expect("int","int")
    let b = vals[0]
    let a = vals[1]
    i.push newVal(a.intVal shr b.intVal)

  def.symbol("sum") do (i: In):
    var s: MinValue
    i.reqQuotationOfNumbers s
    var c = 0.float
    var isInt = true
    for n in s.qVal:
      if n.isFloat:
        isInt = false
        c = + n.floatVal
      else:
        c = c + n.intVal.float
    if isInt:
      i.push c.int.newVal
    else:
      i.push c.newVal

  def.symbol("product") do (i: In):
    var s: MinValue
    i.reqQuotationOfNumbers s
    var c = 1.float
    var isInt = true
    for n in s.qVal:
      if n.isFloat:
        isInt = false
        c = c * n.floatVal
      else:
        c = c * n.intVal.float
    if isInt:
      i.push c.int.newVal
    else:
      i.push c.newVal

  def.symbol("avg") do (i: In):
    var s: MinValue
    i.reqQuotationOfNumbers s
    var c = 0.float
    for n in s.qVal:
      if n.isFloat:
        c = + n.floatVal
      else:
        c = c + n.intVal.float
    c = c / len(s.qVal).float
    i.push c.newVal
 
  def.symbol("med") do (i: In):
    var s: MinValue
    i.reqQuotationOfNumbers s
    let first = s.qVal[(s.qVal.len-1) div 2]
    let second = s.qVal[((s.qVal.len-1) div 2)+1]
    if s.qVal.len mod 2 == 1:
      i.push first
    else:
      if first.isFloat:
        if second.isFloat:
          i.push ((first.floatVal+second.floatVal)/2).newVal
        else:
          i.push ((first.floatVal+second.intVal.float)/2).newVal
      else:
        if second.isFloat:
          i.push ((first.intVal.float+second.floatVal)/2).newVal
        else:
          i.push ((first.intVal+second.intVal).float/2).newVal
    
  def.symbol("range") do (i: In):
    var s: MinValue
    i.reqQuotationOfIntegers s
    var a = s.qVal[0]
    var b = s.qVal[1]
    var step = 1.newVal
    var res = newSeq[MinValue](0)
    if len(s.qVal)==3:
      a = s.qVal[0]
      b = s.qVal[1]
      step = s.qVal[2]
    var j = a
    if a.intVal < b.intVal:
      while j.intVal <= b.intVal:
        res.add j
        j = (j.intVal + step.intVal).newVal
    else:
      while j.intVal >= b.intVal:
        res.add j
        j = (j.intVal - step.intVal).newVal
    i.push res.newVal

  def.finalize("num")
