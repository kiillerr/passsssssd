#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <numeric>
#include <math.h>

using namespace std;

#define BLOCK_SIZE 4;

__global__ void sum(int* input, int n)                                      // global call to cuda function (host to device)
{
	const int tid = threadIdx.x;                                            // get thread ID
	int step_size = 1;
	int number_of_threads = blockDim.x;                                     // initiate step size and number of threads 

	while (number_of_threads > 0)                                          
	{
		if (tid < number_of_threads) 
		{
			const int fst = tid * step_size * 2;                           
			const int snd = fst + step_size;                                // calculate indices of first and second element to be added
			if(snd < n)
			{
				input[fst] += input[snd];                                   // add elements
			}
		}

		step_size <<= 1;                                                   // multiply step size by 2                                  
		if(number_of_threads == 1)
			break;
		number_of_threads = (int)ceil((float)number_of_threads/2.0);      // divide number of threads by 2
		__syncthreads();
	}
}

int main()
{
	int count=0;
	int result;
	int *d;

	cout<<"\nEnter the number of elements : ";
	cin>>count;
	const int size = count * sizeof(int);

	int *h;
	h = new int[count];

	cout<<"\nEnter the elements : \n";
	for(int i=0;i<count;i++)
		cin>>h[i];
	
	cudaMalloc(&d, size);                                                  // allocate device variable memory
	cudaMemcpy(d, h, size, cudaMemcpyHostToDevice);                        // copy array from host to device

	//cout<<ceil((float)count/2.0);
	sum <<<1, ceil((float)count/2.0) >>>(d,count);                         // function call  func_name<<<no_of_blocks,no_of_threads>>>(args)

	
	cudaMemcpy(&result, d, sizeof(int), cudaMemcpyDeviceToHost);           // copy result back from device to host

	cout << "Sum is " << result << endl;

	getchar();

	cudaFree(d);                                                           // free device memory
	delete[] h;

	return 0;
}

/*
PS D:\MyFiles\Projects\LP1-LabAsg\2-HPC> nvcc ParRedSum.cu -o ParRedSum
ParRedSum.cu
   Creating library ParRedSum.lib and object ParRedSum.exp
PS D:\MyFiles\Projects\LP1-LabAsg\2-HPC> nvprof ./ParRedSum

Enter the number of elements : 4

Enter the elements :
2
49
12
54
==4900== NVPROF is profiling process 4900, command: ./ParRedSum
Sum is 117
==4900== Profiling application: ./ParRedSum
==4900== Profiling result:
            Type  Time(%)      Time     Calls       Avg       Min       Max  Name
 GPU activities:   60.16%  2.4640us         1  2.4640us  2.4640us  2.4640us  sum(int*, int)
                   25.00%  1.0240us         1  1.0240us  1.0240us  1.0240us  [CUDA memcpy HtoD]
                   14.84%     608ns         1     608ns     608ns     608ns  [CUDA memcpy DtoH]
      API calls:   82.75%  203.24ms         1  203.24ms  203.24ms  203.24ms  cudaMalloc
                   16.83%  41.338ms         1  41.338ms  41.338ms  41.338ms  cuDevicePrimaryCtxRelease
                    0.16%  392.40us        97  4.0450us     100ns  220.50us  cuDeviceGetAttribute
                    0.10%  243.20us         1  243.20us  243.20us  243.20us  cudaFree
                    0.07%  170.80us         2  85.400us  62.900us  107.90us  cudaMemcpy
                    0.06%  151.20us         1  151.20us  151.20us  151.20us  cuModuleUnload
                    0.01%  29.200us         1  29.200us  29.200us  29.200us  cudaLaunchKernel
                    0.01%  18.800us         1  18.800us  18.800us  18.800us  cuDeviceTotalMem
                    0.00%  9.8000us         1  9.8000us  9.8000us  9.8000us  cuDeviceGetPCIBusId
                    0.00%  1.3000us         3     433ns     200ns     800ns  cuDeviceGetCount
                    0.00%     900ns         1     900ns     900ns     900ns  cuDeviceGetName
                    0.00%     700ns         2     350ns     100ns     600ns  cuDeviceGet
                    0.00%     400ns         1     400ns     400ns     400ns  cuDeviceGetLuid
                    0.00%     200ns         1     200ns     200ns     200ns  cuDeviceGetUuid
*/