// each function will be just considered as a primitive
//

// we will be using Yeppp inside the worker

//problem 1 : product
use "SciPony/yeppp"
use "collections"
// define the worker

actor ColProductCalculator
    let _master : ProductDist
    let _column : Real1D val
    let _colnum : USize

    new create(master : ProductDist,column : Real1D val ,  colnum : USize) =>
        _column = column
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
    var matrix : Matrix
    var collectedcolumns : Matrix

    let vector : Real1D val
    var res : Real1D
    let nr : USize
    let nc : USize
    let env : Env
    // only receive iso to deny other actors
    new create (matrix' : Matrix iso , vector' : Real1D val , env' : Env) =>
        matrix = consume matrix'
        vector = vector'
        nr = matrix.nr
        nc = matrix.nc
        collectedcolumns = Matrix(nr,nc)
        res = Real1D.init(0.0,nr)
        env = env'

    // first we need to init Yeppp
    // init Yeppp
    // Yeppp() // this will call the apply method and init Yeppp
    

    be distribute() =>
        """
        Round-robin work distribution.
        """
        for i in Range(0,matrix.nc) do
           let col = matrix.getcol(i)
           ColProductCalculator(this, consume col , i).multiply(vector(i))
        end
               
    be collectcolumn(multipliedcol : Real1D val , colnum : USize)  =>
        // whenever this behavior is called then update the position
        // collect them as rows then transpose

        collectedcolumns.setrow(colnum, multipliedcol.clone())

    be result() =>
       // do yeppp sum here
       // using Yeppp.sum
       // given the garantie that behavior call is causal then result will suppose collected columns is already filled
       collectedcolumns.t() // because we are summing on the rows
       for (i,row) in collectedcolumns.data.pairs() do
            try res(i) = Yeppp.sum(row) end
       end
       res

    be print() =>
        env.out.write("[")
        for (i,value) in res.pairs() do
            env.out.write(i.string())
            if (i != res.size()) then env.out.write(", ") else env.out.print("]") end
        end
