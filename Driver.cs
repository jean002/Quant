using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Quantum.Polynom
{
	class Driver
	{
		static void Main(string[] args)
		{
			int matchcount = 0;
			int zerocasecount = 0;
			int mismatch = 0;

			int n = 0;
			string userInput;

			Console.WriteLine("Enter the number of time(s) to run the simulator.");
			userInput = Console.ReadLine();

			n = Convert.ToInt32(userInput);

			//This loop can run the similator several times.

			for (int i = 1; i <= n; i++)
			{
				using (var sim = new QuantumSimulator())
				{
                                        var res = findPolynomialS.Run(sim).Result;
					Console.WriteLine(res);

					//The variable "matchcount" counts the number of times the unknown coefficients match the
					//coefficients of s(x).

					if (res.Item14 == 1)
						matchcount = matchcount + 1;

					//The variable "zerocasecount" counts the number of times a(x) is the zero polynomial.

					if (res.Item14 == 0)
						zerocasecount = zerocasecount + 1;

					//The variable "mismatch" counts the number of times there is a mismatch between the
					//the coefficients of s(x) and the unknown coefficients.

					if (res.Item14 == 2)
						mismatch = mismatch + 1;

				}
			}

			Console.WriteLine(matchcount);
			Console.WriteLine(zerocasecount);
			Console.WriteLine(mismatch);
			

			Console.WriteLine("Press any key to shut the screen.");
			Console.ReadKey();
		}
	}
}
