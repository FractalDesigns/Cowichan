&{cowichan}

Matrix-Vector Product:

A simple serial C++ function that implements this:

```pony expand weave tangle
// (/bin/bash: gist: command not found)
void
product(
  real2D*	matrix,			/* to multiply by */
  real1D*	vector,			/* to be multiplied */
  real1D*	result,			/* result of multiply */
  int		nr,			/* row size */
  int		nc			/* column size */
){
  int		r, c;			/* row/column indices */

  for (r=0; r<nr; r++){
    result[r] = matrix[r][0] * vector[0];
    for (c=1; c<nc; c++){
      result[r] += matrix[r][c] * vector[c];
    }
  }

  /* return */
}
```

Product using Thread Building Blocks:

```pony <<ProductTBB>>
<<TBB_step_1>>
<<TBB_step_2>>

<<TBB_step_3>>
<<TBB_step_4>>
<<TBB_Step_5>>
<<TBB_step_6>>
<<TBB_step_7>>
<<TBB_step_8>>
```

step 1 : define a class for every type of operation.


```pony <<TBB_step_1>>

// (/bin/bash: gist: command not found)
class Product {

```

step 2: declare all data structures required for the operation.

```pony <<TBB_step_2>>

  Matrix _matrix;
  Vector _vector, _result;

public:
```

```pony <<TBB_step_3>>

  Product(Matrix matrix, Vector vector, Vector result):
          _matrix(matrix), _vector(vector), _result(result) { }

```



step 4: override the function call operator ().
tbb library will call this to perform the work.
Performs matrix-vector multiplication on the given row range.
  
```pony <<TBB_step_4>>
  void operator()(const Range& rows) const {

```

step 6: for every row assigned to this thread calculate the product

```pony <<TBB_step_6>>
    for (size_t row = rows.begin(); row != rows.end(); ++row) {
      VECTOR(result, row) = 0.0;
      for (int col = 0; col < Cowichan::NELTS; ++col) {
        VECTOR(result, row) += MATRIX(matrix, row,col) * VECTOR(vector, col);
      }
    }
  }
};

```

Step 5 : Bring parameters to local scope

```pony <<TBB_Step_5>>
    Matrix matrix = _matrix;
    Vector vector = _vector;
    Vector result = _result;
```

step 7: create an instance of Product.

```pony <<TBB_step_7>>
Product product(matrix, vector, result);

```

step 8: execute parallelly by splitting the matrix along its rows.

```pony <<TBB_step_8>>
parallel_for(blocked_range<size_t>(0, Cowichan::NELTS), product, auto_partitioner());
```

#Product using Boost Message Passing Interface:

```pony weave
<<MPI_step_1>>
<<MPI_step_2>>
<<MPI_step_3>>
<<MPI_step_4>>
<<MPI_step_5>>
<<MPI_step_6>>
```

step 1: make the mpi communicator visible

```pony <<MPI_step_1>>

void product_mpi (mpi::communicator world,
                  real2D* matrix,           /* to multiply by */
                  real1D* vector,          /* to be multiplied */
                  real1D* result,          /* result of multiply */
                  int   nr,                /* row size */
                  int           nc)                /* column size */
{
```

step 2: declare variables needed to split work

```pony <<MPI_step_2>>
  int           lo, hi;         /* work controls */
  int           r, c;                   /* loop indices */
  int rank;

```

step 3: call a function that retreives rows for this process

```pony <<MPI_step_3>>

  if (get_block_rows_mpi (world, 0, nr, &lo, &hi)) {

```

step 4: for every row assigned to this process calculate the product
```pony <<MPI_step_4>>

    for (r = lo; r < hi; r ++) {
      result[r] = matrix[r][0] * vector[0];
      for (c = 1; c < nc; c++) {
        result[r] += matrix[r][c] * vector[c];
      }
    }

  }

```

step 5: broadcast the result vector to every process since we are dealing with distributed memory here. broadcast is your BIGGEST enemy! (when it comes to performance)

```pony <<MPI_step_5>>

  for (rank = 0; rank < world.size (); rank++) {
    if (get_block_rows_mpi (world, 0, nr, &lo, &hi, rank)) {
      broadcast (world, &result[lo], hi - lo, rank);
    }
  }

}

```

step 6: write a function that gives each process a range of elements to work on

```pony <<MPI_step_6>>
bool get_block_rows_mpi (mpi::communicator world, int lo, int hi,
    int* start, int* end)
{
  int size = world.size ();
  int rank = world.rank ();
  
  int nl;    /* number of elements */
  int num;   /* number to do */
  int extra; /* spillage */

  nl    = hi - lo;
  num   = nl / size;
  extra = nl % size;

  if ((nl <= 0) || (rank >= nl)) {
    /* do nothing */
    *start = 0;
    *end = -1;
  }
  else {
    /* do share of work */
    if (rank < extra){
      num += 1;
      *start = lo + rank * num;
    } else {
      *start = lo + (extra * (num + 1)) + ((rank - extra) * num);
    }
    *end = *start + num;
  }

  return (*end != -1);
}
```

