use "collections"
// apprently use path only works for dynamic
//use "path:~/SciPony"
//use "lib:gsl"
//use "lib:cblas"
use "random"
use "gsl"
// this will be a serial implementation of the cowichan problems
type Real2D is Array[Array[F64] ]
type Int2D is Array[Array[I64]]
type Bool2D is Array[Array[Bool]]
/*first index is for rows, second index for columns*/
type Real1D is Array[F64]
type Complex is (F64,F64)
type Point is (F64,F64) // same type as Complex but keep semantics separate



primitive Utils
    // PPrint stand for pretty print as in jupyter notebooks
    // we can't do function overload that's why we need to give pprint diffrent names and append each type to the name
    // keep it that way untill we learn Generics

    fun transpose (matrix : Real2D ref) : Real2D ref =>
      var aux = F64(0.0)
      // inplace transpose
      try
      for (i,_) in matrix.pairs() do
          for (j,value) in matrix(i).pairs() do
              if (i>=j ) then continue end
              matrix(i)(j) = matrix(j)(i) = matrix(i)(j)
          end
      end
      end
      matrix

    fun random_points(n:USize ,range :(F64,F64) = (0.0,1.0) ) : Array[Point] =>
        """
        This will return a list of random points default ranging  is (0,1)
        """
        // TODO : make range flexible

        // different ways to do this
        // we will just use a Mersenne Twister
        let origin : Point = (0.0 , 0.0)
        var result :Array[Point] = Array[Point].init(origin, n)
        let mt = MT()
        for i in Range(0,n) do
            try
                result(i) = (mt.next().f64() / U64.max_value().f64(), mt.next().f64() / U64.max_value().f64())
            end
        end
        result
    fun ran_matrix (nr: USize = 2, nc : USize = 2) : Real2D =>
        // gnerate matrix of real value in range (0,1)
        //var matrix : Real2D =  Real2D.init(Real1D.init(0,nc),nr)
        var matrix : Real2D =  Real2D.create(nr) ; for i in Range(0, nr) do matrix.push(Real1D.init(0,nc)) end // create and init matrix

        let mt = MT()
        try
        for  (i,_) in matrix.pairs() do
            for (j,_) in matrix(i).pairs() do
                matrix(i)(j) = mt.next().f64() / U64.max_value().f64()
            end
        end
        end
        matrix

    fun pprint_points(a : Array[Point],out : OutStream) =>
        """
        print the list of Points 
        """
        out.print("size :" + a.size().string())
        for pt in a.values() do
            out.write(" ("+pt._1.string()+ ","+ pt._2.string() + ")")
        end
        out.print(" ")
    fun pprint_real(mat : Real2D, out : OutStream) =>
        """
        This will print the size of the matrix first between ()
        and then print the elements of the matrix
        """
        try out.print("[("+mat.size().string()  +","+ mat(0).size().string()+")")
        for (i,_) in mat.pairs() do
           out.write("[ | ")
           for (j,_) in mat(i).pairs() do
               out.write(mat(i)(j).string()+" | ")
           end
           out.print("]")
        end
        out.print("]")
        end
    fun pprint_int(mat : Int2D, out : OutStream) =>
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

    fun ran_matrix_gsl(nr:USize = 2,nc:USize=2 ):Real2D=>
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
        
        /*var matrix : Real2D = Real2D.init(Array[F64].init(0.0, nr), nc)*/
        // Initialising matrix this way will result in
        // rows having all the same reference to one Real1D so the proper way to do it is the following
        var matrix : Real2D =  Real2D.create(nr)
        for i in Range(0, nr) do matrix.push(Real1D.init(0,nc)) end // so it is necessary to have a loop

        
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
       // TODO : debug why all rows are similar
       let rand_m : F64 = 56197.0 // just a prime number for mudulus
       let rand_a : F64 = 1291.0
       let rand_c :F64 = 917.0
       var v : F64 = seed % rand_m
       var result : Real2D = Real2D.init(Real1D.init(0, c),r )
       try
       for (i, _) in result.pairs() do
           
           for (j, _) in result(i).pairs() do
               result(i)(j) = v
               v = ((rand_a * v) + rand_c) % rand_m
           end
           end
       end
       result


    fun randmat_I64 (r:USize=2, c:USize = 2, seed : F64 = 0.0): Int2D =>
       let rand_m : F64 = 56197.0 // just a prime number for mudulus
       let rand_a : F64 = 1291.0
       let rand_c :F64 = 917.0
       var v : F64 = seed % rand_m
       var result : Int2D = Int2D.init(Array[I64].init(0, c),r )
       
       for (i, _) in result.pairs() do
           try
           for (j, _) in result(i).pairs() do
               result(i)(j) = v.i64()
               v = ((rand_a * v) + rand_c) % rand_m
           end
           end
       end
       result

      // Problem 5
   fun histhresh (mat : Int2D, fraction : F64) : Int2D =>
       // so I should be returning a boolean vector but we will only use Int2D
       let nr : USize = mat.size()
       let nc : USize = try mat(0).size() else USize(0) end
       var mask : Int2D = Int2D.init(Array[I64].init(0,nc),nr)
       var vmax = I64(0)
       // find max value in matrix
       for row in mat.values() do
           for value in row.values() do
               if value > vmax then vmax = value end
           end
       end

       //create and initialize histogram with zeros
       var hist = Real1D.init(0,(vmax+1).usize())
       // counting
       for row in mat.values() do
           for value in row.values() do
              try hist(value.usize()) = hist(value.usize()) + 1 end
           end
       end

       // include
       var retain = fraction * nc.f64() * nr.f64()
       
       var index = vmax.usize()
       try
       while (index >= 0)  and (retain >0) do
           retain = retain - hist(index)
       index = index - 1
       end
       end
       retain = index.f64()
       // thresholding
       try
       for (i,_) in mat.pairs() do
           for (j,_) in mat(i).pairs() do
           mask(i)(j) = if mat(i)(j).f64() > retain then I64(1) else I64(0) end
           
           end
       end
       end
       mask

// problem 6
    fun distance (a : Point, b : Point) : F64 =>
        (((a._1 - b._1)*(a._1 - b._1)) + ( (a._2 - b._2)*(a._2 - b._2))).sqrt()

    fun outer(pts : Array[Point]) : (Real2D,Real1D) =>
        let origin : Point = (0.0,0.0)
        var vector : Real1D = Real1D.init(0.0,pts.size())
        //var matrix : Real2D = Real2D.init(Real1D.init(0, pts.size()), pts.size())
        let size = pts.size()
        var matrix : Real2D =  Real2D.create(size) ; for i in Range(0, size) do matrix.push(Real1D.init(0,size)) end
        var dmax = F64(-1.0)
        var d = F64(0.0)

        // all elements except matrix diagonal
        for (i,_) in matrix.pairs() do
            try vector(i) = distance (pts(i),origin)
            for (j,_) in matrix(i).pairs() do
                if i >= j then continue end
                d = distance (pts(i),pts(j))
                matrix(i)(j) = d
                matrix(j)(i) = d
                if (d>dmax) then dmax = d end
            end
            end
        end
        // matrix diagonal
        dmax = dmax * size.f64()
        
        for (i,_) in matrix.pairs() do try matrix(i)(i) = dmax end end
        // returning results
        (matrix,vector)

                        



        
