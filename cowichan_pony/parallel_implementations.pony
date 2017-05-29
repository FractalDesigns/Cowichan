// each function will be just considered as a primitive
//

// we will be using Yeppp inside the worker

//problem 1 : product
use "SciPony/yeppp"
use "collections"
// define the worker

actor ColProductCalculator
    let _master : ProductDist
    let _column : Real1D
    let _colnum : USize

    new create(master : ProductDist,column : Real1D iso ,  colnum : USize) =>
        _column = consume column
        _colnum = colnum
        _master = master

    be multiply(vectorElement:F64 ) =>
        //let mulcol : Real1D = recover iso multipliedcolumn end
        // now this behavior should call collect behavior in master

        _master.collectcolumn(Yeppp.multiply_constant(_column,vectorElement) ,_colnum)
    

/*
 *
 *
 *
 *  Master
 *
 */



actor ProductDist

    //create farm in the master
    var matrix : Real2D
    // matrix has to be iso no doubt because we don't to make a copy when transposing it will create a lot of memory overhead

    let vector : Real1D val
    var collectedcolumns : Real2D
    var res : Real1D
    let nr : USize
    let nc : USize
    let env : Env
    // only receive iso to deny other actors
    new create (matrix' : Real2D iso , vector' : Real1D val , env' : Env) =>
        matrix = consume matrix'
        vector = vector'
        nr = matrix.size()

        nc = try
            matrix(0).size() else USize(0) end
        collectedcolumns = Real2D.create(nr); for i in Range(0, nr) do collectedcolumns.push(Real1D.init(0,nc)) end
        res = Real1D.init(0.0,matrix.size())
        env = env'

    // first we need to init Yeppp
    // init Yeppp
    // Yeppp() // this will call the apply method and init Yeppp
    

    be distribute() =>
        """
        Round-robin work distribution.
        """
        for (i,_) in Utils.transpose(matrix).pairs() do
            // apparently column in this loop is a ref and it is not sendable
            // that is why we need to recovere to a sendable alias
            // we can recover iso column end or not specify iso because it is
            // by  default
            // it is importatnt to create an iso alias
            try
              let col = recover iso matrix(i) end
            ColProductCalculator(this, consume col , i).multiply(vector(i))
            end
        end
        // after finishing re-transpose the matrix
        Utils.transpose(matrix)
               
    be collectcolumn(multipliedcol : Real1D val , colnum : USize)  =>
        // whenever this behavior is called then update the position
        collectedcolumns(colnum) = multipliedcol

    be result() =>
       // do yeppp sum here
       // using Yeppp.sum
       // given the garantie that behavior call is causal then result will suppose collected columns is already filled
       Utils.transpose(collectedcolumns) // because we are summing on the rows
       for (i,row) in collectedcolumns.pairs() do
            try res(i) = Yeppp.sum(row) end
       end
       res

    be print() =>
        env.out.write("[")
        for (i,value) in res.pairs() do
            env.out.write(i.string())
            if (i != res.size()) then env.out.write(", ") else env.out.print("]") end
        end
