// each function will be just considered as a primitive
//

// we will be using Yeppp inside the worker

//problem 1 : product
use "SciPony/Yeppp"
// define the worker

actor RowProductCalculator
    let _rowNumber : USize
    let _master : ProductMaster
    let _row : Real1D
    let _rownum : USize

    new create(master : ProductMaster,row : Real1D,  rownum : USize) =>
        _row = row
        _rownum = rownum
        _master = master

    be multiply(row : Real1D, vectorElement:F64 ) : =>
        let multipliedrow : Real1D = Yeppp.multiply_constant(row,vectorElement)
        // now this behavior should call collect behavior in master
        _master.collect(multipliedrow ,_rownum)
       

actor ProductDist
    //create farm in the master
    let matrix : Real2D
    let vector : Real1D
    var result : Real1D

    new create (matrix' : Real2D, vector' : Real1D) =>
        matrix = matrix'
        vector = vector'
        
    // first we need to init Yeppp
    // init Yeppp
    // Yeppp() // this will call the apply method and init Yeppp
    
    
    be distribute() =>
        """
        Round-robin work distribution.
        """
        for row in matrix.values() do
            for elem in vector.elements
                //TODO : complete implementation

    be collect(multipliedrow' : Real1D , rownum' : USize)  =>
        
        //primitive Product
   // fun apply(matrix:Real2D, vector:Real1D): Real2D =>

