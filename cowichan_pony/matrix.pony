use "collections"
use "random"




class Matrix
    var data : Real2D
    var nr : USize
    var nc : USize
    new create (nr':USize  ,nc': USize) =>
        nr = nr'
        nc = nc'
        data  =  Real2D.create(nr) ; for i in Range(0, nr) do data.push(Real1D.init(0,nc)) end
    
    fun apply(i:USize,j:USize) : F64=> // we don need a ref here, box is just enough because not changing anything in the message receiver (object)
        try data(i)(j) else F64(0) end
    
    fun ref update(i:USize,j:USize,value : F64): F64^ =>
        try data(i)(j) = value else F64(-1) end
    
    fun ref t() : Matrix =>
        try
          for (i,_) in data.pairs() do
              for (j,value) in data(i).pairs() do
                  if (i>=j ) then continue end
                  this(i,j) = this(j,i) = this(i,j)
              end
          end
          end
          this
          
    fun ref randomize () : Matrix=>
        let mt = MT()
        try
        for  (i,_) in data.pairs() do
            for (j,_) in data(i).pairs() do
                this(i,j) = mt.next().f64() / U64.max_value().f64()
            end
        end
        end
        this
    
    fun pprint(out : OutStream) =>
        try out.print("[("+data.size().string()  +","+ data(0).size().string()+")")
        for (i,_) in data.pairs() do
           out.write("[ | ")
           for (j,_) in data(i).pairs() do
               out.write(this(i,j).string()+" | ")
           end
           out.print("]")
        end
        out.print("]")
        end


        
