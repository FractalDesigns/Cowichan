use "collections"
// apprently use path only works for dynamic
//use "path:~/SciPony"
//use "lib:gsl"
//use "lib:cblas"
use "gsl"
// this will be a serial implementation of the cowichan problems
type Real2D is Array[Array[F64]]
/*first index is for rows, second index for columns*/
type Real1D is Array[F64]


primitive Utils
    fun ran_matrix(nr:USize = 2,nc:USize=2 ):Real2D=>
        var matrix = Real2D.>reserve(nr)
        let rnd=Rnd()
        var aux = rnd.ran_vector(nc)
        for i in Range(0, nr) do
            matrix.push (aux)
            aux = rnd.ran_vector(nc)
        end
        matrix


primitive SerialCow
    //problem 1
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
    fun mandelConvergence(x : I64, y : I64):Bool =>
        """
        return true if point is in the mandelbrot set, false otherwise
        """
        // x & y are the coordinates
        
        let mandelInfinity = 2
        let maxIterations = 150

        var r : F64 = 0.0 // real part
        var im : F64 = 0.0 // imaginary part
        var rs :F64 =0.0 // real squared
        var ims : F64 = 0.0 // imaginary squared
        var iter : I32 = 0 // number of iterations

        repeat
              im = (2.0 * r * im ) + x
              r = (rs-ims)+y
              iter = iter + 1
              //recalculate ims and rs
              rs = r * r
              ims = im * im
        until iter > maxIterations or (rs + ims) >= mandelInfinity end
        
        // then we need to decide either the point is in the set or not
        // in case of iter == 150 then we will just say that the serie didn't diverge
        // (stayed within a radius of 2) considered then in the set
        // otherwise if iter < 150 then the loop only broke because the distance rs + ims
        // exeeded 2 then the point is defenetely not in the set, so we might as well just
        // return iter == maxIterations
        iter == maxiterations
    fun mandel(matrix : Real2D, )
actor Main
    new create(env:Env)=>
        var nr = USize(10000)
        var nc = USize(10000)
        //get random matrix
        let matrix = Utils.ran_matrix(nr,nc)
        var result =  Real1D
               // lets generate random vectors
        // create the generator from gsl.pony
        let rnd = Rnd()
        var vector : Real1D = rnd.ran_vector(nc)
        // initialising matrix
        // as still undecided yet wether to make a matrix actor or class actor
        // we will just fill the matrix the old fashion way
        /*
        var aux = rnd.ran_vector(nc)
        for i in Range(0, nr) do
            matrix.push ( aux )
            aux = rnd.ran_vector(nc)
        end

        env.out.print("test matrix :")
        for row in matrix.values() do
           for number in row.values() do
                env.out.write(number.string() + " ")
           end
        env.out.print(" ")
        end
*/
        // testing serial product
        try
            result = SerialCow.product(matrix, vector,nr,nc,env.out)
        else
            env.out.print("serial product raised an error")
        end
        // so if everything went just fine
        // printing some debug informations
        //try env.out.print(matrix(0)(1).string() ) end
  /*
        env.out.print("printing the vector values")
        
        for value in vector.values() do
            env.out.print(value.string()+" ")
            // OutStream method write lets you write  the output buffer without newline
        end
        // just to get a new line
        env.out.print(" ")
*/
