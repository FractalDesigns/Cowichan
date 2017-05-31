use "path:./"
use "lib:test"

struct Structure
  var x : I64 = 0
  var y : F64 = 0.0
  new create() =>  x = 5 ; y = 2.1

type Ptrstructure is MaybePointer[Structure]
actor Main
    new create(env: Env)=>
      //var s : Structure= Structure 
      //s.x = 5
       //@setEvent[None](Ptrstructure(s)) 

      var s = Structure
      var ptr : Ptrstructure= @returnstruct[Ptrstructure] (s)
      env.out.print(s.x.string())
      env.out.print(s.y.string())
