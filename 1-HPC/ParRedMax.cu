#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <numeric>
#include <math.h>

using namespace std;

__global__ void max(int* input, int n)
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
				if(input[snd] > input[fst])
					input[fst] = input[snd];
			}
		}

		step_size *= 2; 
		if(number_of_threads == 1)
			break;
		number_of_threads = (int)ceil((float)number_of_threads/2.0);      // divide number of threads by 2
		__syncthreads();
	}
}

int main()
{
	int count;
	int result;
	int* d;

	cout<<"\nEnter the number of elements : ";
	cin>>count;
	const int size = count * sizeof(int);

	int *h;
	h = new int[count];

	cout<<"\nEnter the elements : \n";
	for(int i=0;i<count;i++)
		cin>>h[i];
	//h[i] = rand()%1000
	
	cudaMalloc(&d, size);
	cudaMemcpy(d, h, size, cudaMemcpyHostToDevice);

	max <<<1, ceil((float)count/2.0) >>>(d , count);

	
	cudaMemcpy(&result, d, sizeof(int), cudaMemcpyDeviceToHost);

	cout << "Max is " << result << endl;

	getchar();

	cudaFree(d);
	delete[] h;

	return 0;
}

/*
PS D:\MyFiles\Projects\LP1-LabAsg\1-HPC> nvcc ParRedMax.cu -o ParRedMax
ParRedMax.cu
   Creating library ParRedMax.lib and object ParRedMax.exp
PS D:\MyFiles\Projects\LP1-LabAsg\1-HPC> nvprof ./ParRedMax

Enter the number of elements : 4

Enter the elements :
67
3
78
32
==10688== NVPROF is profiling process 10688, command: ./ParRedMax
Max is 78
==10688== Profiling application: ./ParRedMax
==10688== Profiling result:
            Type  Time(%)      Time     Calls       Avg       Min       Max  Name
 GPU activities:   60.33%  2.4330us         1  2.4330us  2.4330us  2.4330us  max(int*, int)
                   25.39%  1.0240us         1  1.0240us  1.0240us  1.0240us  [CUDA memcpy HtoD]
                   14.28%     576ns         1     576ns     576ns     576ns  [CUDA memcpy DtoH]
      API calls:   74.44%  154.08ms         1  154.08ms  154.08ms  154.08ms  cudaMalloc
                   25.25%  52.275ms         1  52.275ms  52.275ms  52.275ms  cuDevicePrimaryCtxRelease
                    0.13%  277.30us        97  2.8580us     100ns  178.30us  cuDeviceGetAttribute
                    0.06%  130.30us         1  130.30us  130.30us  130.30us  cudaFree
                    0.04%  82.600us         2  41.300us  24.900us  57.700us  cudaMemcpy
                    0.04%  80.300us         1  80.300us  80.300us  80.300us  cuModuleUnload
                    0.01%  28.900us         1  28.900us  28.900us  28.900us  cudaLaunchKernel
                    0.01%  27.100us         1  27.100us  27.100us  27.100us  cuDeviceTotalMem
                    0.00%  9.5000us         1  9.5000us  9.5000us  9.5000us  cuDeviceGetPCIBusId
                    0.00%  2.3000us         2  1.1500us     200ns  2.1000us  cuDeviceGet
                    0.00%  2.0000us         3     666ns     300ns     900ns  cuDeviceGetCount
                    0.00%     800ns         1     800ns     800ns     800ns  cuDeviceGetName
                    0.00%     400ns         1     400ns     400ns     400ns  cuDeviceGetLuid
                    0.00%     300ns         1     300ns     300ns     300ns  cuDeviceGetUuid

*/