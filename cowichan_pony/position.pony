class Pos is (Equatable[Pos] & Stringable)
  let x: I32
  let y: I32

  new val create(x': I32, y': I32) =>
    x = x'
    y = y'

  fun add(p: Pos val): Pos val =>
    Pos(x + p.x, y + p.y)

  fun sub(p: Pos val): Pos val =>
    Pos(x - p.x, y - p.y)

  fun mul(scalar: I32): Pos val =>
    Pos(scalar * x, scalar * y)

  fun eq(that: box->Pos): Bool =>
    (x == that.x) and (y == that.y)

  fun gt(that: box->Pos): Bool =>
    ((x >= that.x) and (y > that.y))
      or ((x > that.x) and (y >= that.y))

  fun lt(that: box->Pos): Bool =>
    ((x <= that.x) and (y < that.y))
      or ((x < that.x) and (y <= that.y))

  fun ge(that: box->Pos): Bool =>
    gt(that) or eq(that)

  fun le(that: box->Pos): Bool =>
    lt(that) or eq(that)

  fun string(): String iso^ =>
    let x_str: String iso = x.string().clone()
    let y_str: String iso = y.string().clone()
    recover String().>append("Pos(" + consume x_str + ", " + consume y_str + ")") end
    
    