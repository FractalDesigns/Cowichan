use "collections"
// apprently use path only works for dynamic
//use "path:~/SciPony"
//use "lib:gsl"
//use "lib:cblas"
use "gsl"
// this will be a serial implementation of the cowichan problems
type Real2D is Array[Array[F64]]
type Bool2D is Array[Array[Bool]]
/*first index is for rows, second index for columns*/
type Real1D is Array[F64]
type Complex is (F64,F64)
type Point is (F64,F64) // same type as Complex but keep semantics separate



primitive Utils
    fun pprint(mat : Real2D , out : OutStream) =>
        """
        This will print the size of the matrix first between ()
        and then print the elements of the matrix
        """
        try out.print("[("+mat.size().string()  +","+ mat(0).size().string()+")") end
        for row in mat.values() do
           out.write("[ | ")
           for element in row.values() do
               out.write(element.string()+" | ")
           end
           out.print("]")
        end
        out.print("]")


    fun ran_matrix(nr:USize = 2,nc:USize=2 ):Real2D=>
        var matrix : Real2D= Real2D.init(Real1D.init(0,nc),nr)
        let rnd=Rnd()
        var aux = rnd.ran_vector(nc)
        for i in Range(0, nr) do
            try matrix(i) = aux end
            aux = rnd.ran_vector(nc)
        end
        matrix


primitive SerialCow
    //problem 1
    //This module performs the product of a realvector, returning a real vector. The
    //parallel version in mind distributes the rows to each actor and within a single
    //actor we use yeppp for SIMD

    fun product(matrix : Real2D,vector: Real1D, nr:USize, nc:USize , out : OutStream):  Real1D?=>
        // we can remove the nr and the nc parameters in case
        // overloading the * operator just implement mul() method
        // in the class matrix
        var result = Real1D.init(0, nr)
        // check dementionality
        let v_size = vector.size()
        for line in matrix.values() do
            if line.size() != v_size then
                out.print("dimentions not compatible")
                error
            end
        end
        // calculating product
        var r : USize = 0 // index in the result vector
        var j : USize = 0
        // TODO : this is a stupid way to iterate replace with matrix.pairs() in the loop
        for row in matrix.values() do
            for element in row.values() do
                try result(j) = result(j) + (row(r)*vector(r)) end
                r = r + 1
            end
        j = j + 1
        r=0
        end
        //printing debug informations
        out.write("result : ")
        for v in result.values() do
            out.write(v.string())
        end
        out.print(" ")
        
        //still be returning result
        result
    
// Problem 2
// for this problem we will set a maximum number of iterations to 150 otherwise some
// points would take foreever to converge
// Mandel_infinity is set to 2, the following routine will return a boolean that will alow
// us to know either the points is in the set or not

    fun mandelConvergence( x : F64, y : F64):F64 =>
        """
        return true if point is in the mandelbrot set, false otherwise
        """
        // x & y are the coordinates
        
        let mandelInfinity : F64 = 2.0
        // should be I32 or I64 but heck I am too lazy
        let maxIterations :F64 = 1500

        var r : F64 = 0.0 // real part
        var im : F64 = 0.0 // imaginary part
        var rs :F64 =0.0 // real squared
        var ims : F64 = 0.0 // imaginary squared
        var iter : F64 = 0.0 // number of iterations

        repeat
              im = (2.0 * r * im ) + x
              r = (rs-ims)+y
              iter = iter + 1
              //recalculate ims and rs
              rs = r * r
              ims = im * im
        until (iter > maxIterations) or ((rs + ims) >= mandelInfinity) end
        
        // then we need to decide either the point is in the set or not
        // in case of iter == 150 then we will just say that the serie didn't diverge
        // (stayed within a radius of 2) considered then in the set
        // otherwise if iter < 150 then the loop only broke because the distance rs + ims
        // exeeded 2 then the point is defenetely not in the set, so we might as well just
        // return iter == maxIterations
        iter
        
    fun mandel(base : Complex, ext: Complex,nr : USize = 100, nc : USize = 100): Real2D=>
        // so by choosing nr and nc is like you've chosen the resolution of the calculated
        // fractal
        var matrix : Real2D = Real2D.init(Array[F64].init(0.0, nr), nc)
        let dx = ext._1/(nr.f64()-1) // step along x
        let dy = ext._2/(nc.f64()-1) // step along y

        
        // now calculate convergence of each of the points
        for r in Range(0,nr) do
            for c in Range(0,nc) do
                try matrix(r)(c) =  mandelConvergence(base._1 + (r.f64()*dx), base._2 + (r.f64()*dy))
                end
            end
        end
        matrix
    //
    //Problem 3 : vector normalisation
    // the problem is to normalise a vector of point coordinates to lie in the unit
    // square.
      fun findMinMax(data : Array[Point]): (Point,Point) =>
        var min : Point = (0.0,0.0)
        var max : Point = (0.0,0.0)
        for (i,_) in data.pairs() do
            try
            if data(i)._1 < min._1 then min = (data(i)._1, 0.0) end
            if data(i)._1 > max._1 then max = (data(i)._1, 0.0) end
            if data(i)._2 < min._2 then min = (data(i)._1, data(i)._2) end
            if data(i)._2 > max._2 then max = (data(i)._1, data(i)._2) end
            end
        end
        (min,max)

    fun normalize(data : Array[Point]) : Array[Point] =>
        let result : (Point, Point) = findMinMax(data)
        let min : Point = result._1
        let max : Point = result._2
        var xscale : F64 = if (max._1 == min._1) then 0.0 else 1/(max._1 + min._1) end
        var yscale : F64 = if (max._2 == min._2) then 0.0 else 1/(max._2 + min._2) end
        // now normalizing data
        for (i, _) in data.pairs() do
            try
                data(i) = (xscale * (data(i)._1 - min._1), yscale * (data(i)._2 - min._2))
            end
        end
        data
  

        // problem 4
        // This module generates a matrix of pseudo random integers, with a given random
        // number seed. the aspect of this problem zhich complecates the parallel
        // implementation is that each successive point in the matrix is computes from the
        // previous one according to a recursive formula
        //

    fun randmat (r:USize=2, c:USize = 2, seed : F64 = 0.0): Real2D =>
       let rand_m : F64 = 56197.0 // just a prime number for mudulus
       let rand_a : F64 = 1291.0
       let rand_c :F64 = 917.0
       var v : F64 = seed % rand_m
       var result : Real2D = Real2D.init(Real1D.init(0, c),r )
       
       for (i, _) in result.pairs() do
           try
           for (j, _) in result(i).pairs() do
               result(i)(j) = v
               v = ((rand_a * v) + rand_c) % rand_m
           end
           end
       end
       result



