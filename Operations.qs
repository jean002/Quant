namespace Quantum.Polynom
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

	//Last update: 1/27/19.

	//This program will answer the following question. Given polynomials 
	//a(x) := a_0 + a_1 x, e(x) := e_0 + e_1 x, and s(x) := s_0 + s_1 x
	//with their coefficients randomly picked from F_2 and given polynomial 
	//b(x) = (a_0 + a_1 x)(s_0 + s_1 x) + (e_0 + e_1 x), what are s_0 and s_1 
	//if both a(x) and b(x) are known?

	//To answer that question, we also impose that we can know e(x) through
	//entanglement, by using the CNOT gate. 

	//We model each coefficient with a qubit. Upon measurement, the state of each qubit
	//can be either Zero or One. Since each coefficient is randomly picked with
	//equal probability, this can be understood as the set {0,1}
	//having a probability distribution defined as P(0) = 1/2 = P(1). Applying
	//the Hadamard operator on each qubit models this probability distribution.


    //This operation is for a(x). With the Hadamard operator H applied to the
	//coefficients, they have an equal probability to be Zero or One, and the
	//the Measure operator M gives the result of the picking process.

    operation Polynom1 () : (Result,Result) 
	{
        mutable result1 = One;
		mutable result2 = One;

		using (polynom1 = Qubit[2])
		{
		   let a_0 = polynom1[0];
		   let a_1 = polynom1[1];

		   H(a_0);
		   H(a_1);

		   set result1 = M(a_0);
		   set result2 = M(a_1);

		   ResetAll(polynom1);
		}

		return (result1,result2);
    }

	//This operation is for e(x). Recall that we use entanglement to know the coeffi-
	//cient of e(x), by using the CNOT gate.

	operation Polynom2 () : (Result,Result)
	{
	   mutable result3 = Zero;
	   mutable result4 = Zero;

	   mutable testresult1 = One;
	   mutable testresult2 = One;

	   mutable finalresult1 = Zero;
	   mutable finalresult2 = Zero;

	   using (polynom2 = Qubit[2])
		{
			let e_0 = polynom2[0];
			let e_1 = polynom2[1];

			H(e_0);
			H(e_1);

			set result3 = M(e_0);
			set result4 = M(e_1);

			

			using (test = Qubit[2])
			{
				CNOT (e_0,test[0]);
				CNOT (e_1,test[1]);

				set testresult1 = M(test[0]); 
				set testresult2 = M(test[1]);

				//Recall that we do not know beforehand the coefficients of e(x), but we use entanglement. The CNOT
				//gate does not tell directly what the coefficients of e(x) are, but we can compute them if we know the states
				//of the qubits from the "test" register.

				if (testresult1 == Zero)
				{
					set finalresult1 = Zero;
				}
				if (testresult1 == One)
				{
					set finalresult1 = One;
				}

				if (testresult2 == Zero)
				{
					set finalresult2 = Zero;
				}
				if (testresult2 == One)
				{
					set finalresult2 = One;
				}
				ResetAll(test);
			}

			ResetAll(polynom2);
		}


		return (finalresult1,finalresult2);
	}

	//This operation is for s(x). Recall s(x) is the unknown. We do output the coefficients of s(x) to test
	//them against the output of the unknown coefficients. Recall the ultimate goal of this algorithm is
	//to compute the coefficients of s(x), which is done later.

	operation Polynom3 () : (Result,Result)
	{
	   mutable result5 = Zero;
	   mutable result6 = Zero;

	   using (polynom3 = Qubit[2])
		{
			let s_0 = polynom3[0];
			let s_1 = polynom3[1];

			H(s_0);
			H(s_1);

			set result5 = M(s_0);
			set result6 = M(s_1);

			ResetAll(polynom3);
		}

		return (result5,result6);
	}

	//This operation models the multiplication of any two elements in Z_2.

	operation Mult (m:Result,n:Result) : Result
	{
	
	    if (m == Zero)
		{
			return Zero;
		}

		else
		{
			return n;
		}

	}

	//This operation models addition on Z_2.

	operation Add (m:Result,n:Result) : Result
	{
		if (m == Zero)
		{
			return n;
		}

		else
		{
			if (n == Zero)
			{
				return One;
			}
			else
			{
				return Zero;
			}
		}
	}

	//pr0 and pr1 are projection functions on ordered pairs.

	operation pr0 (m:Result,n:Result) : (Result)
	{
		return m;
	}

	operation pr1(m:Result,n:Result) : (Result)
	{
		return n;
	}

	operation findPolynomialS () : (String,(Result,Result),String,(Result,Result),String,(Result,Result),String,Result,Result,Result,String,(Result,Result),String,Int)
	{
		let res1 = Polynom1();
		let res2 = Polynom2();
		let res3 = Polynom3();

		//Recall b(x) = a(x)s(x) + e(x). Note that b(x) can be a second-degree polynomial.
		//Upon expanding and simplifying b(x), we have the coefficients of b(x) as follows:
		//b_0 = a_0 s_0 + e_0 (constant term)
		//b_1 = a_0 s_1 + a_1s_0 + e_1 (coefficient of x)
		//b_2 = a_1 s_1 (coefficient of x^2)

		let b_0 = Add(Mult(pr0(res1),pr0(res3)),pr0(res2));
		let b_1 = Add(Add((Mult(pr0(res1),pr1(res3))),Mult(pr1(res1),pr0(res3))),pr1(res2));
		let b_2 = Mult(pr1(res1),pr1(res3));

		mutable unknownres = (Zero,Zero);
		mutable s_0 = Zero;
		mutable s_1 = Zero;

      //We perform case analysis on a_0 and a_1 since we know their values.

      if (pr0(res1) == Zero && pr1(res1) == One) 
	  { 	 
	      //a_0 = 0; a_1 = 1.

		if(b_2 == Zero)
		{
			set s_1 = Zero;
		}
		else
		{
			set s_1 = One;
		}

		if(b_1 == Zero)
		{
			if(pr1(res2) == Zero)
			{
				set s_0 = Zero;
			}
			else
			{
				set s_0 = One;
			}
		}
		else
		{
			if(pr1(res2) == Zero)
			{
				set s_0 = One;
			}
			else
			{
				set s_0 = Zero;
			}

		}

		set unknownres = (s_0,s_1);
      }

	  if (pr0(res1) == One && pr1(res1) == Zero)

	  {
		//If a_0 = 1; a_1 = 0, then b_0 = s_0 + e_0 and b_1 = s_1 + e_1.

		if(b_0 == Zero)
		{
			if(pr0(res2) == Zero)
			{
				set s_0 = Zero;
			}
			else
			{
				set s_0 = One;
			}
		}
		else
		{
			if(pr0(res2) == Zero)
			{
				set s_0 = One;
			}
			else
			{
				set s_0 = Zero;
			}
		}

		if (b_1 == Zero)
		{
			if (pr1(res2) == Zero)
			{
			    set s_1 = Zero;
			}
			else
			{
				set s_1 = One;
			}
		}
		else
		{
			if (pr1(res2) == Zero)
			{
				set s_1 = One;
			}
			else
			{
				set s_1 = Zero;
			}
		}

		set unknownres = (s_0,s_1);
      }
	  
	  if (pr0(res1) == One && pr1(res1) == One)
	  {
        //a_0 = 1; a_1 = 1.

		if (b_0 == Zero)
		{
			if (pr0(res2) == Zero)
			{
			    set s_0 = Zero;
			}
			else
			{
				set s_0 = One;
			}
		}
		else
		{
			if (pr0(res2) == Zero)
			{
				set s_0 = One;
			}
			else
			{
				set s_0 = Zero;
			}
		}

		if (b_2 == Zero)
		{
			set s_1 = Zero;
		}
		else
		{
			set s_1 = One;
		}
        
		set unknownres = (s_0,s_1);
	  }

	  mutable zerocase = "Solution cannot be found.";

	  //As of now, we do not know how to find s_0 and s_1 if a_0 = 0 = a_1. Thus, in this case, the outputs for s_0 and s_1
	  //and for the coefficients of the unknown polynomial should be ignored.

	  if (pr0(res1) == Zero && pr1(res1) == Zero)
	  {
	      set zerocase = "Solution cannot be found.";
	  }
	  else
	  {
	  	  set zerocase = " ";
	  }
	  
	  mutable acoeff = "Coefficients of a(x): ";
	  mutable ecoeff = "Coefficients of e(x): ";
	  mutable scoeff = "Coefficients of s(x): ";
	  mutable bcoeff = "Coefficients of b(x): ";
	  mutable unkwncoeff = "Coefficients of the unknown: ";

	 //The variable "match" will be used to know when the unknown coefficients are equal to the coefficients
	 //of s(x). Recall that we output the coefficients of s(x) to ensure the algorithm is correct.

	 //We will run the simulator in C# several times to see how many times there are matches.

	  mutable match = 0;

	  if (pr0(res3) == pr0(unknownres) && pr1(res3) == pr1(unknownres))
	  {
	  	  set match = 1;
	  }
	   else
	  {
	  	  set match = 2;
	  }
	  
	  if (pr0(res1) == Zero && pr1(res1) == Zero)
	  {
	  	  set match = 0;
	  }
	 
	  //The coefficients of s(x) are outputted to be checked with the result of the coefficients
	  //of the unknown polynomial, which was the ultimate goal.

	return (acoeff,res1,ecoeff,res2,scoeff,res3,bcoeff,b_0,b_1,b_2,unkwncoeff,unknownres,zerocase,match);
    
	}
}