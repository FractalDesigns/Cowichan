use "collections"
use "gsl"

actor Main
    new create(env:Env)=>

        //var nr = USize(10000)
        //var nc = USize(10000)
        
        let origin : Complex = (F64(0),F64(0))
        let extent :Complex = (F64(1.0),F64(1.0))

        // FIXME : inside the function we get correct results
        // but when assigned to fractal, all values are false
        let fractal :Real2D=  SerialCow.mandel(origin,extent, 500,500)
        // DEBUG :
    //     for row in fractal.values() do
    //         for value in row.values() do
    //             env.out.write(value.string()+"|")
    //         end
    //     env.out.print("")
    // end



        /* TESTED : serial product


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
            // OutSt:ream method write lets you write  the output buffer without newline
        end
        // just to get a new line
        env.out.print(" ")
*/



       */
    // testing rand mat
    let mat : Real2D = SerialCow.randmat(5,6 )
    Utils.pprint(mat,env.out)
    


