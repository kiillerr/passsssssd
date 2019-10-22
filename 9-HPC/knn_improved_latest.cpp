/* 
C++ MPI Program to classify 20 examples from Iris Dataset in Parallel

Author : Anurag Katakkar
Date : 27th September, 2018


Flow of the Program :
0. Read the iris.csv dataset, declare K, examples[20] to be classified,
1. In master process (rank=0)  cast char values to float,
2. Send this data to 20 other slave processes, and process 0th example,
3. Each slave process calculates the euclidean() distance of a single example from every other example in dataset, sorts these distances in Ascending Order, then sends back to master,
4. Master process receives distances and uses these to classify() each example

*********************************************************************************************************************

Compile :
mpic++ -o knn_mpi knn_mpi.cpp

Run
mpirun -np 20 ./knn_mpi

*/

#include<iostream>
#include<math.h>
#include<string.h>
#include<fstream>
#include<stdlib.h>
#include<typeinfo>
#include<mpi.h>

using namespace std;

//function to cast char to float
double atof (const char* str);

//function to find Euclidean Distance
float euclidean(float ex1[1][4],float ex2[1][4]){
	
	float distance=0;
	
	for(int i=0;i<4;i++){
	
		//Sum of squares of distance
		distance += pow((ex1[0][i]-ex2[0][i]),2);
	}
	//Sqrt of the sum
	distance = sqrt(distance);
	return distance;
};

string classify(float dist[][2], int K, string iris_data_raw[][5]){

	//for(int i =0 ;i<150;i++)
		//cout<<"class : "<<iris_data_raw[i][3]<<endl;
	//Counter variables
	int classOneCount = 0 ;
	int classTwoCount =0 ;
	int classThreeCount = 0;

	//Variables to match class of examples
	string classOne = "Iris-setosa";
	string classTwo = "Iris-versicolor";
	string classThree = "Iris-virginica";
	
	string result = "";

	cout<<"Counting nearest classes"<<endl;
	
	for (int i=0;i<K;i++){
		if(iris_data_raw[(int)dist[i][0]][4]==classOne){
			classOneCount++;
		}
		else if(iris_data_raw[(int)dist[i][0]][4]==classTwo){
			classTwoCount++;
		}
		else
			classThreeCount++;
	}
	
	//Find Class with Max Count
	if(classOneCount>classTwoCount){
		if(classOneCount>classThreeCount)
			result = classOne;
		else
			result = classThree;
	}
	else
	{
		if(classTwoCount>classThreeCount)
			result = classTwo;
		else
			result = classThree;
	}
	return result;
}

void process(int my_id, int K, int examples[20], string iris_data_raw[][5], float iris_data[][4]){

	
	int example_number;			//example to be classified by each process
	
	example_number = examples[my_id];
	
	float distances[150][2]; 
	//column 1 stores index of example necessary to retrieve class-label in classify() function, column2 stores Euclidean Distance
	
	for(int i=0;i<150;i++){
		distances[i][0]=i;
		if(i==example_number){
			//Distance to self set to high number to avoid bias in output
		
			distances[i][1]=1000;
		}
		else
			distances[i][1]=euclidean(&iris_data[example_number],&iris_data[i]);
	}


	//Bubble sort Distances
	
	float swap_distance;	
	float swap_index;
	for (int i =0;i<150;i++){
		for (int j=0;j<150-i-1;j++){
			if(distances[j][1]>distances[j+1][1]){
				swap_distance = distances[j][1];
				swap_index = distances[j][0];
				distances[j][1] = distances[j+1][1];
				distances[j][0] = distances[j+1][0];
				distances[j+1][1] = swap_distance;
				distances[j+1][0] = swap_index;
			}
		}
	}
	cout<<"Thread : "<<my_id<<" | The example "<<examples[my_id]<<" belongs to the class : "<<classify(distances,K,iris_data_raw)<<endl;
	
}

int main(int argc, char **argv){	
	
	
	string iris_data_raw[150][5];		//stores char values read from csv
	float iris_data[150][4];		//char values cast to float
	
	ifstream iris_file;
		
	int K=13;				//K=sqrt(N), here N = 150
	int examples[20];			//20 random examples to be classified
	
	for(int i=0;i<20;i++){
		examples[i]=rand()%150;
	}
	
	iris_file.open("iris.csv");
		
	while(!iris_file.eof()){
		for(int i =0;i<150;i++){
			for(int j=0 ; j<5;j++){
				getline(iris_file,iris_data_raw[i][j],',');
			}
		}
	}
	
	//Add missing entry
	iris_data_raw[0][0] = "5.1";	
	
	int my_id,ierr,num_procs;
	
	const clock_t begin_time = clock();
	
	MPI_Status stat;
	ierr = MPI_Init(&argc, &argv);
           /* find out MY process ID, and how many processes were started. */
	ierr = MPI_Comm_rank(MPI_COMM_WORLD, &my_id);
	ierr = MPI_Comm_size(MPI_COMM_WORLD, &num_procs);
		
	
	if(my_id==0){
	//Master
		
		//convert to float
		
		char parse_to_float[3];
		
		for(int i =0;i<150;i++){
			for(int j=0 ; j<4;j++){
				strcpy(parse_to_float,iris_data_raw[i][j].c_str());
				iris_data[i][j] = atof(parse_to_float);		
			}
		}

	
		for(int i =1;i<num_procs;i++){
			cout<<"Sending data to "<<i<<endl;
			MPI_Send(iris_data,600,MPI_FLOAT,i, 0, MPI_COMM_WORLD);
		}
	process(my_id,K,examples,iris_data_raw,iris_data);
	
	}
	else {

	float iris_data_recvd[150][4];
	
	
	MPI_Recv(iris_data_recvd, 600, MPI_FLOAT, 0, 0, MPI_COMM_WORLD, &stat);
	
	cout<<"Recevied Data by "<<my_id<<endl;
	
	process(my_id,K,examples,iris_data_raw,iris_data_recvd);	
			
	}
	
	ierr=MPI_Finalize();	
	
	cout<<"Time Taken by "<<my_id<<" : "<<float( clock () - begin_time ) /  CLOCKS_PER_SEC<<endl;	
				
	return 0;
}
