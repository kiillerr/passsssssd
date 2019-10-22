#include "cuda_runtime.h"
#include "cuda_runtime_api.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <numeric>
#include <math.h>

using namespace std;

#define BLOCK_SIZE 4;

__global__ void mean(float* input, int n)
{
	const int tid = threadIdx.x;
	int step_size = 1;
	int number_of_threads = blockDim.x;

	while (number_of_threads > 0)
	{
		if (tid < number_of_threads) 
		{
			const int fst = tid * step_size * 2;
			const int snd = fst + step_size;
			if(snd < n)
			{
				input[fst] += input[snd];// a = a+b
			}				
		}

		step_size <<= 1; 
		if(number_of_threads == 1)
			break;
		number_of_threads = (int)ceil((float)number_of_threads/2.0);      // divide number of threads by 2
		__syncthreads();
	}

	__syncthreads();
	input[0] /= n;
}

int main()
{
	int count=0;
	float result;
	float *d;

	cout<<"\nEnter the number of elements : ";
	cin>>count;
	const int size = count * sizeof(float);

	float *h;
	h = new float[count];

	cout<<"\nEnter the elements : \n";
	for(int i=0;i<count;i++)
		cin>>h[i];
	//h[i] = rand()%1000;
	
	cudaMalloc(&d, size);
	cudaMemcpy(d, h, size, cudaMemcpyHostToDevice);

	//cout<<ceil((float)count/2.0);
	mean <<<1, ceil((float)count/2.0) >>>(d,count);

	
	cudaMemcpy(&result, d, sizeof(float), cudaMemcpyDeviceToHost);

	cout << "Mean is " << result << endl;

	getchar();

	cudaFree(d);
	delete[] h;

	return 0;
}

/*
PS D:\MyFiles\Projects\LP1-LabAsg\2-HPC> nvcc ParRedMean.cu -o ParRedMean
ParRedMean.cu
   Creating library ParRedMean.lib and object ParRedMean.exp
PS D:\MyFiles\Projects\LP1-LabAsg\2-HPC> nvprof ./ParRedMean

Enter the number of elements : 4

Enter the elements :
2
3
6
1
==26012== NVPROF is profiling process 26012, command: ./ParRedMean
Mean is 3
==26012== Profiling application: ./ParRedMean
==26012== Profiling result:
            Type  Time(%)      Time     Calls       Avg       Min       Max  Name
 GPU activities:   63.04%  2.7840us         1  2.7840us  2.7840us  2.7840us  mean(float*, int)
                   23.91%  1.0560us         1  1.0560us  1.0560us  1.0560us  [CUDA memcpy HtoD]
                   13.04%     576ns         1     576ns     576ns     576ns  [CUDA memcpy DtoH]
      API calls:   78.89%  167.23ms         1  167.23ms  167.23ms  167.23ms  cudaMalloc
                   20.69%  43.855ms         1  43.855ms  43.855ms  43.855ms  cuDevicePrimaryCtxRelease
                    0.14%  293.70us        97  3.0270us     100ns  163.00us  cuDeviceGetAttribute
                    0.11%  226.30us         1  226.30us  226.30us  226.30us  cudaFree
                    0.08%  167.00us         1  167.00us  167.00us  167.00us  cuModuleUnload
                    0.05%  116.30us         2  58.150us  22.700us  93.600us  cudaMemcpy
                    0.03%  61.100us         1  61.100us  61.100us  61.100us  cuDeviceTotalMem
                    0.01%  28.300us         1  28.300us  28.300us  28.300us  cudaLaunchKernel
                    0.00%  10.000us         1  10.000us  10.000us  10.000us  cuDeviceGetPCIBusId
                    0.00%  1.5000us         3     500ns     300ns     900ns  cuDeviceGetCount
                    0.00%  1.2000us         2     600ns     100ns  1.1000us  cuDeviceGet
                    0.00%     700ns         1     700ns     700ns     700ns  cuDeviceGetName
                    0.00%     300ns         1     300ns     300ns     300ns  cuDeviceGetUuid
                    0.00%     300ns         1     300ns     300ns     300ns  cuDeviceGetLuid
*/