use "collections"
use "random"
use "gsl"

// first to define a matrix class we need to define its primitives
struct GslMatrix
    var size1: USize = 0
    var size2: USize = 0
    var tda: USize = 0
    var data: F64 = 0
    var block: GslBlock = (0,Pointer[F64])
    var owner: I32 = 0

type PtrGslMatrix is MaybePointer[GslMatrix]
// we would like to abstract the use of Gsl matrices
// by creating a safe object encapsulation and a better Interface
class Matrix
    let _pm: PtrGslMatrix
    var m : USize // number of lines
    var n : USize // number of culumns

    new create(m': USize, n': USize, init: Bool = false) =>
        m = m'
        n = n'
        if init then
            // initialize buffer to zeros it might take some time
            _pm = @gsl_matrix_calloc[PtrGslMatrix](m, n)
        else
            // allocate without initializing buffer, leave the memory as is
            // you can find random values in your matrix
            _pm = Gsl.matrix_alloc(m, n)
        end

    fun _final() => @gsl_matrix_free[None](_pm)

    fun setAll(x: F64) => Gsl.matrix_set_all(_pm, x)
    fun setZero() => @gsl_matrix_set_zero[None](_pm)
    fun set_identity() => @gsl_matrix_set_identity[None](_pm)
    fun get(i: USize, j: USize) : F64 =>@gsl_matrix_get[F64](_pm, i, j)
    fun set(i: USize, j: USize, x: F64) => @gsl_matrix_set[None](_pm, i, j, x)
    fun _in_bounds(i: USize, j: USize) : Bool => (i<m) and (j<n)
    fun ref update(i: USize, j: USize, x: F64) : F64 =>
      // the receiver must be ref
      let old = this.get(i,j)
      if _in_bounds(i,j) then this.set(i,j,x) else @printf[I32](("Matrix Write Error: Out of bounds\n").cstring()) end
      old
    fun apply(i: USize, j: USize) : F64? =>
      if _in_bounds(i,j) then this.get(i,j) else @printf[I32](("Matrix Read Error: Out of bounds\n").cstring()) end


    /*
    fun getcol(i:USize) : Array[F64] iso^ =>
      // return an ephemeral so that we can assign it to an iso reference
        var res = recover iso Array[F64](nc) end
        for j in Range(0,nr) do
            try res.push(data(i+(nc *j))) end
        end
        consume res

    fun getrow(i:USize) : Array[F64] iso^ =>
       var res = recover iso Array[F64](nc) end
        for j in Range(0,nc) do
            try res.push(data((i*nc) +j)) end
        end
        consume res
*/
    fun getRow(i:USize) : Array[F64] =>
        // TODO : come back here after implementing the vector object


    fun ref randomize () : Matrix=>
      // just fill the matrix with random elements
        let mt = MT()
        for i in Range(0, m) do
          for j in Range(0,n) do
           this(i,j) = mt.next().f64() / U64.max_value().f64()
          end
        end
        this


  fun pprint(out : OutStream) =>
        try
        for (i,_) in data.pairs() do
            out.write(data(i).string())
            var j = i+1
            if ((j % nc) == 0)   then out.print(" ") else out.write(" | ")end
        end
        end
