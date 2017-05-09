use "ponytest"

use "timing"

actor Main is TestList
    new create(env :Env ) => PonyTest(env,this)
        fun tag tests(test: PonyTest) =>
            test(_SerialProduct)
class iso _SerialProduct is UnitTest
    fun name() : String => "Serial product"
    fun apply(h:TestHelper)  =>
    let timer = TicToc(h.env.out)
    var nr = USize(10000)
    var nc = USize(10000)
    let matrix = Utils.ran_matrix(nr,nc)
    var result =  Real1D
    let rnd = Rnd()
    var vector : Real1D = rnd.ran_vector(nc)
    try
        result = SerialCow.product(matrix, vector,nr,nc,env.out)
    else
        env.out.print("serial product raised an error")
    end
