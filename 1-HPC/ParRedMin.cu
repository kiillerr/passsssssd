#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <numeric>
#include <math.h>

using namespace std;

__global__ void min(int* input, int n)
{
	const int tid = threadIdx.x; //Index of the thread within the block

	int step_size = 1;
	int number_of_threads = blockDim.x; //Number of threads in thread block

	while (number_of_threads > 0)
	{
		if (tid < number_of_threads) 
		{
			const int fst = tid * step_size * 2;
			const int snd = fst + step_size;
			if(snd < n)
			{
				if(input[snd] < input[fst])
					input[fst] = input[snd];
			}
		}

		step_size <<= 1; //1 -> 2, 2 -> 4, 3->6; shift operator
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
	//when sizeof() is used with data types it simply returns the
	// the amount of memory allocated to that data types
	int *h;
	h = new int[count];

	cout<<"\nEnter the elements : \n";
	for(int i=0;i<count;i++)
		cin>>h[i];
	

	cudaMalloc(&d, size);
	cudaMemcpy(d, h, size, cudaMemcpyHostToDevice);

	min <<<1, ceil((float)count/2.0) >>>(d , count);

	
	cudaMemcpy(&result, d, sizeof(int), cudaMemcpyDeviceToHost);

	cout << "Min is " << result << endl;

	getchar();

	cudaFree(d);
	delete[] h;

	return 0;
}

/* 
PS D:\MyFiles\Projects\LP1-LabAsg\1-HPC> nvcc ParRedMin.cu -o ParRedMin
ParRedMin.cu
   Creating library ParRedMin.lib and object ParRedMin.exp
PS D:\MyFiles\Projects\LP1-LabAsg\1-HPC> nvprof ./ParRedMin

Enter the number of elements : 4

Enter the elements :
1
2
3
67
==1876== NVPROF is profiling process 1876, command: ./ParRedMin
Min is 1
==1876== Profiling application: ./ParRedMin
==1876== Profiling result:
            Type  Time(%)      Time     Calls       Avg       Min       Max  Name
 GPU activities:   59.68%  2.3680us         1  2.3680us  2.3680us  2.3680us  min(int*, int)
                   25.81%  1.0240us         1  1.0240us  1.0240us  1.0240us  [CUDA memcpy HtoD]
                   14.52%     576ns         1     576ns     576ns     576ns  [CUDA memcpy DtoH]
      API calls:   79.80%  172.77ms         1  172.77ms  172.77ms  172.77ms  cudaMalloc
                   19.78%  42.826ms         1  42.826ms  42.826ms  42.826ms  cuDevicePrimaryCtxRelease
                    0.13%  271.80us        97  2.8020us     100ns  172.50us  cuDeviceGetAttribute
                    0.11%  245.30us         1  245.30us  245.30us  245.30us  cudaLaunchKernel
                    0.07%  144.50us         1  144.50us  144.50us  144.50us  cudaFree
                    0.05%  106.90us         2  53.450us  25.500us  81.400us  cudaMemcpy
                    0.04%  89.600us         1  89.600us  89.600us  89.600us  cuModuleUnload
                    0.01%  21.400us         1  21.400us  21.400us  21.400us  cuDeviceTotalMem
                    0.00%  9.7000us         1  9.7000us  9.7000us  9.7000us  cuDeviceGetPCIBusId
                    0.00%  1.9000us         3     633ns     200ns     900ns  cuDeviceGetCount
                    0.00%  1.7000us         2     850ns     300ns  1.4000us  cuDeviceGet
                    0.00%     900ns         1     900ns     900ns     900ns  cuDeviceGetName
                    0.00%     300ns         1     300ns     300ns     300ns  cuDeviceGetUuid
                    0.00%     300ns         1     300ns     300ns     300ns  cuDeviceGetLuid

*/