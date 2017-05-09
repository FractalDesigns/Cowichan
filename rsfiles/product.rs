#![doc(html_logo_url = "http://web.hpu4science.org/_/rsrc/1322786212575/config/customLogo.gif?revision=4",html_playground_url = "http://play.rust-lang.org/")]
//!   /**
//!    * Performs matrix-vector multiplication on the given row range.
//!    */
//!   void operator()(const Range& rows) const {
//!
//! <<TBB_Step_5>>
//!     // step 6: for every row assigned to this thread calculate
//!     //         the product
//!
//!     for (size_t row = rows.begin(); row != rows.end(); ++row) {
//!       VECTOR(result, row) = 0.0;
//!       for (int col = 0; col < Cowichan::NELTS; ++col) {
//!         VECTOR(result, row) += MATRIX(matrix, row,col) * VECTOR(vector, col);
//!       }
//!     }
//!   }
//! };
//!
//! // step 7: create an instance of Product.
//!
//! Product product(matrix, vector, result);
//!
//! // step 8: execute parallelly by splitting the matrix along its rows.
//!
//! parallel_for(blocked_range<size_t>(0, Cowichan::NELTS), product, auto_partitioner());
//! ```
//!
//! Step 5 : Bring parameters to local scope
//!
//!
//! Product using Boost Message Passing Interface:
//!
//! // step 1: make the mpi communicator visible
//!
//!
//!
fn main(){}
