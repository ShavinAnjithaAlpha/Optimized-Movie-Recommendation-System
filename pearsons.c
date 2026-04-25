//Centered cosine similarity
#include<stdio.h>
#include<stdlib.h>
#include<math.h>

double pearson_correlation(const double *A, const double *B, size_t size){
    double dot_p=0.0;
    double mag_a=0.0;
    double mag_b=0.0;
    int i;
    for(i=0; i<size; i++){
		double a = A[i];
		double b = B[i];

        dot_p += a*b;
        mag_a += a*a;
        mag_b += b*b;
    }
    return dot_p/(sqrt(mag_a * mag_b));
}

void calc_similarity(double *normalizeduser, const double *normalized_matrix, double *similarity, int No_of_users, int No_of_movies){
	int i=0;
	for(i=0;i<No_of_users;i++){ //traverse through each user
		// find similarity between new user and ith user (avoid per-user malloc/copy)
		similarity[i] = pearson_correlation(normalizeduser, &normalized_matrix[i*No_of_movies], No_of_movies);
	}
}
