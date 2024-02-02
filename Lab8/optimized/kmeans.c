/**************************************************************

	The program reads an RGB bitmap image file and uses the K-Means algorithm
	algorithm to compress the image by clustering all pixels
        Author: Nikos Bellas, ECE Department, University of Thessaly, Volos, GR
**************************************************************/

#include "qdbmp.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>


/* Creates a negative image of the input bitmap file */
int main(int argc, char * argv[]) {
    BMP * bmp;
    UINT * cluster; /* For each pixel position, it shows the cluster that this pixel belongs */
    UCHAR r, g, b;
    UINT width, height, row, col;
    UINT i;
    MEANS * means; /* Holds the (R, G, B) means of each cluster  */
    MEANS mean; /* A single (R, G, B) mean */
    UINT noClusters; /* Number of of clusters. It is given by the user */
    UINT dist, minDist, minCluster, iter, maxIterations;
    UINT noOfMoves; /* Total number of inter-cluster moves between two succesive iterations */
    UINT * totrArr;
    UINT * totbArr;
    UINT * totgArr;
    UINT * sizeClusterArr;

    /* Check arguments */
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <input file> <output files> <Number of Clusters>\n", argv[0]);
        return 1;
    }

    /* Read the input (uncompressed) image file */
    bmp = BMP_ReadFile(argv[1]);
    BMP_CHECK_ERROR(stdout, -1);

    /* Get image's dimensions */
    width = BMP_GetWidth(bmp);
    height = BMP_GetHeight(bmp);

    noClusters = (UINT) atoi(argv[3]);
    means = (MEANS * ) calloc(noClusters, sizeof(MEANS));
    totrArr = (UINT * ) calloc(noClusters, sizeof(UINT));
    totbArr = (UINT * ) calloc(noClusters, sizeof(UINT));
    totgArr = (UINT * ) calloc(noClusters, sizeof(UINT));
    sizeClusterArr = (UINT * ) calloc(noClusters, sizeof(UINT));

    /* 1. Initialize cluster means with (R, G, B) values from random coordinates of the Input Image*/
    srand(time(NULL));
    for (i = 0; i < noClusters; ++i) {

        col = rand() % width;
        row = rand() % height;

        /* Get pixel's RGB values */
        BMP_GetPixelRGB(bmp, col, row, & r, & g, & b);

        means[i].r = r;
        means[i].g = g;
        means[i].b = b;
    }

    /* The cluster assignement for each pixel */
    cluster = (UINT * ) calloc(width * height, sizeof(UINT)); /* Important to also initialize all entries to 0 */
    if (cluster == NULL) {
        free(cluster);
        free(bmp);
        return 1;
    }

    maxIterations = 10;
    iter = 0;
    /* Main loop runs at least once */
    do {

        noOfMoves = 0;
        ++iter;
        printf("ITER %ld\n", iter);

        for (i = 0; i < noClusters; ++i) {
            totrArr[i] = 0;
            totbArr[i] = 0;
            totgArr[i] = 0;
            sizeClusterArr[i] = 0;
        }
        /* 2. Go through each pixel in the input image and calculate its nearest mean. 
              The output of phase 2 is the cluster* data structure.                    */

        for (row = 0; row < height; ++row) {
            for (col = 0; col < width; ++col) {

                /* Get pixel's RGB values */
                BMP_GetPixelRGB(bmp, col, row, & r, & g, & b);

                minDist = 10000; /* Larger than the lagest possible value */
                for (i = 0; i < noClusters; ++i) {

                    /* Distance metric. May replace with something cheaper */
                    dist = (UINT)(abs(r - means[i].r) + abs(g - means[i].g) + abs(b - means[i].b));
                    if (dist < minDist) {
                        minDist = dist;
                        minCluster = i;
                    }
                }

                if ( * (cluster + row * width + col) != minCluster) {
                    *(cluster + row * width + col) = minCluster;
                    ++noOfMoves;
                }
                totrArr[minCluster] += r;
                totgArr[minCluster] += g;
                totbArr[minCluster] += b;
                sizeClusterArr[minCluster]++;

            } /* for */
        } /* for */

        /* 3. Update the mean of each cluster based on the pixels assigned to them. */
        if (noOfMoves > 0) {
            for (i = 0; i < noClusters; ++i) {
                means[i].r = (UCHAR)(totrArr[i] / sizeClusterArr[i]);
                means[i].g = (UCHAR)(totgArr[i] / sizeClusterArr[i]);
                means[i].b = (UCHAR)(totbArr[i] / sizeClusterArr[i]);
            }

        }

        /* 4. Goto 2 if not convergence and less than a max number of iterations. Else goto 5 */
    } while ((iter < maxIterations) && (noOfMoves > 0));

    for (i = 0; i < noClusters; ++i) {
        printf("means[%ld] = (%d, %d, %d)\n", i, means[i].r, means[i].g, means[i].b);
    }

    /* 5. Replace the pixel of the original image with the mean of the corresponding cluster */

    for (row = 0; row < height; ++row) {
        for (col = 0; col < width; ++col) {

            i = * (cluster + row * width + col);
            mean = means[i];

            /* Note: colors are stored in BGR order */

            BMP_SetPixelRGB(bmp, col, row, mean.r, mean.g, mean.b);

        }

    }

    /* Write out the output image and finish */
    BMP_WriteFile(bmp, argv[2]);
    BMP_CHECK_ERROR(stdout, -2);

    /* Free all memory allocated for the image */
    BMP_Free(bmp);

    return 0;
}