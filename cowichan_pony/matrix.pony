use "collections"
use "random"

class Matrix 
    var data : Array[F64]
    var nr : USize
    var nc : USize
    
    new create (nr':USize, nc': USize) =>
        nr = nr'
        nc = nc'
        let cell_count = nr * nc
        data = Array[F64](cell_count)

    fun _to_cell(pos: Pos val): USize =>
        ((nc * pos.y.usize()) + pos.x.usize()).usize()

    fun _in_bounds(pos: Pos val): Bool =>
      (pos.y.usize() >= 0) and (pos.y.usize() < nr) and
        (pos.x.usize() >= 0) and (pos.x.usize() < nc)

    fun apply(pos : Pos val) : F64 =>
        try
        data(_to_cell(pos))
      else
        @printf[I32](("Matrix Read Error\n").cstring())       

        F64(-1)
      end
     

    fun ref update(pos: Pos val, value: F64) ? =>
      if _in_bounds(pos) then
         data(_to_cell(pos)) = value
      else
        @printf[I32](("Matrix Write Error: Out of bounds\n").cstring())
        error
      end


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
    
   
    fun ref randomize () : Matrix=>
        let mt = MT()
        let cell_count = nr * nc
        if data.size() ==  cell_count then 
        for i in Range(0, cell_count) do
        try
           data (i)= mt.next().f64() / U64.max_value().f64()
        end
        end
        else
        for i in Range(0, cell_count) do
           data.push(mt.next().f64() / U64.max_value().f64())
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