/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: computePathFamily_C.cpp
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%		C++ implementation of matlab function computePathFamily.m
%
%
%       
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reference:
%   If you use the 'SM toobox' please refer to:
%   [MJG13] Meinard Müller, Nanzhu Jiang, Harald Grohganz
%   SM Toolbox: MATLAB Implementations for Computing and Enhancing Similarity Matrices
%   Proceedings of the 53rd Audio Engineering Society Conference on Semantic Audio, London, 2014.
%
% License:
%     This file is part of 'SM Toolbox'.
%
%     'SM Toolbox' is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 2 of the License, or
%     (at your option) any later version.
%
%     'SM Toolbox' is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with 'SM Toolbox'. If not, see
%     <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/


#include "mex.h"
#include <algorithm>
// #include "th_vec_tools.h"
#include <cmath>

#include <limits>
#include <math.h>

#define INF std::numeric_limits<double>::infinity()
#define Inf std::numeric_limits<double>::infinity()
#define NaN std::numeric_limits<double>::signaling_NaN()


#ifdef PCWIN //this compiler flag has to be set manually in windows os.
	#define ISNAN_FUNC _isnan
#else
	#define ISNAN_FUNC isnan
#endif


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    //_asm int 3
    
    if (nrhs < 2)
        mexErrMsgTxt("You must at least provide a segment and a self similarity matrix.");
    
    const mxArray* mx_SSM_full = prhs[1];
    const mxArray* mx_segment = prhs[0];
    
    if (!mxIsDouble(mx_SSM_full) || mxIsComplex(mx_SSM_full))
        mexErrMsgTxt("The self similarity matrix must be numeric but not complex");
    
    
    int32_T* dn = 0;
    int32_T* dm = 0;
    real_T*  dw = 0;
    size_t    S = 0;
    
    if (nrhs > 2 && mxIsStruct(prhs[2])) {
        // get dn parameter
        mxArray* mx_field = mxGetField(prhs[2], 0, "dn");
        if (mx_field) {
            if (mxIsInt32(mx_field) && mxGetM(mx_field) == 1) {
                dn = reinterpret_cast<int*>(mxGetPr(mx_field));
                S = mxGetN(mx_field);
            }
            else
                mexErrMsgTxt("The provided dn parameter is not a 1xS matrix of type int32");
        }
        else {
            dn = reinterpret_cast<int32_T*>(mxCalloc(3, sizeof(int32_T)));
            dn[0] = 1;
            dn[1] = 1;
            dn[2] = 0;
            S = 3;
        }
        
        // get dm parameter
        mx_field = mxGetField(prhs[2], 0, "dm");
        if (mx_field) {
            if (mxIsInt32(mx_field) && mxGetM(mx_field) == 1) {
                dm = reinterpret_cast<int*>(mxGetPr(mx_field));
                if (mxGetN(mx_field) != S)
                    mexErrMsgTxt("The size of parameter dn and dm does not match");
                
            }
            else
                mexErrMsgTxt("The provided dm parameter is not a 1xS matrix of type int32");
        }
        else {
            dm = reinterpret_cast<int32_T*>(mxCalloc(3, sizeof(int32_T)));
            dm[0] = 1;
            dm[1] = 0;
            dm[2] = 1;
            if (S != 3)
                mexErrMsgTxt("The size of parameter dn and dm does not match");
        }
        
        // get dw parameter
        mx_field = mxGetField(prhs[2], 0, "dw");
        if (mx_field) {
            if (mxIsDouble(mx_field) && mxGetM(mx_field) == 1) {
                dw = mxGetPr(mx_field);
                if (mxGetN(mx_field) != S)
                    mexErrMsgTxt("The size of parameter dn and dw does not match");
                
            }
            else
                mexErrMsgTxt("The provided dw parameter is not a 1xS matrix of type double");
        }
        else {
            dw = reinterpret_cast<real_T*>(mxCalloc(3, sizeof(real_T)));
            dw[0] = 1.;
            dw[1] = 1.;
            dw[2] = 1.;
            if (S != 3)
                mexErrMsgTxt("The size of parameter dn and dw does not match");
        }
    }
    else {
        S = 3;
        dn = reinterpret_cast<int32_T*>(mxCalloc(S, sizeof(int32_T)));
        dn[0] = 1;
        dn[1] = 1;
        dn[2] = 0;
        
        dm = reinterpret_cast<int32_T*>(mxCalloc(S, sizeof(int32_T)));
        dm[0] = 1;
        dm[1] = 0;
        dm[2] = 1;
        
        dw = reinterpret_cast<real_T*>(mxCalloc(S, sizeof(real_T)));
        dw[0] = 1.;
        dw[1] = 1.;
        dw[2] = 1.;
    }
    
    
    if (mxIsInt32(mx_segment)==0)
        mexErrMsgTxt("The provided segment is not of type int32");
    const int32_T* segment = (int32_T*)(mxGetPr(mx_segment));
    if (segment[0]<1 || segment[1]<1 || segment[1]<segment[0])
        mexErrMsgTxt("Segment is invalid");
    
    
    const size_t N = mxGetM(mx_SSM_full)+1;
    const uint32_T M = (int)(segment[1]- segment[0]+1 +1);
    
//     mexPrintf("twob\n%d %d\n",N,M);
    
    
    const real_T* SSM_full = mxGetPr(mx_SSM_full);
    mxArray* mx_SSM = mxCreateDoubleMatrix(N, M, mxREAL );
    real_T* SSM = mxGetPr(mx_SSM);
    
    
    // initialize SSM
    for (size_t n = 0; n < N; n++) {
        for(size_t m = 0; m < M; m++) {
            SSM[m*N+n] = 0;
        }
    }
    
    // cut SSM
    for (size_t n = 0; n < N-1; n++) {
        for(size_t m = 0; m < M-1; m++) {
            SSM[(m+1)*(N)+n] = SSM_full[(m+segment[0]-1)*(N-1)+n];
        }
    }
    
    // calc bounding box size of steps
    size_t sbbn = 0;
    size_t sbbm = 0;
    
    for (size_t s = 0; s < S; s++) {
        sbbn = std::max<int32_T>(sbbn, dn[s]);
        sbbm = std::max<int32_T>(sbbm, dm[s]);
    }
    
    
    
    mxArray* mx_E = mxCreateNumericMatrix(N, M, mxINT32_CLASS, mxREAL);
    int32_T* E = reinterpret_cast<int32_T*>(mxGetPr(mx_E));
    
    //initialize extended D matrix
    const size_t eN = N+sbbn;
    const size_t eM = M+sbbm;
    
    real_T* ED = reinterpret_cast<real_T*>(mxCalloc(eN * eM, sizeof(real_T)));
    
    for (size_t i = 0; i < eN * eM; i++) {
        ED[i] = -Inf;
    }
    
    ED[(sbbm)*eN+sbbn-1] = 0;
    
    
    //accumulate
    for (size_t n = sbbn; n < eN; n++) {
        // special column, m=0
        size_t m = sbbm;
        if ( ED[m*eN+(n-1)] >= ED[(eM-1)*eN+(n-1)] ) {
            E[(n-sbbn)+(m-sbbm)*N] = 0;
            ED[(n)+m*eN] = ED[(m)*eN+(n-1)];
        }
        else {
            E[(n-sbbn)+(m-sbbm)*N] = -1;
            ED[(n)+(m)*eN] = ED[(eM-1)*eN+(n-1)];
        }
        // special column, m=1
        m = sbbm+1;
        ED[(n)+(m)*eN] = ED[(n)+(m-1)*eN] + SSM[(n-sbbn)+(m-sbbm)*N];
        E[(n-sbbn)+(m-sbbm)*N] = -2;
        
        //  ordinary DTW with given stepsizes
        for(m = sbbm+1; m < eM; m++) {
            
            for (size_t s = 0; s < S; s++) {
                size_t step_n = n-dn[s];
                size_t step_m = m-dm[s];
                
                if (step_m>sbbm) {
                    real_T score  = ED[(step_n)+(step_m)*eN]+SSM[(n-sbbn)+(m-sbbm)*N]*dw[s];
                    
                    if (score > ED[(n)+(m)*eN]) {
                        ED[(n)+(m)*eN] = score;
                        E[(n-sbbn)+(m-sbbm)*N] = static_cast<int32_T>(s+1);
                    }
                }
            }
        }
    }
    
    //create D matrix and copy ED to D
    mxArray* mx_D = mxCreateDoubleMatrix(N, M, mxREAL );
    real_T*  D    = mxGetPr(mx_D);
    
    for (size_t n = sbbn; n < eN; n++) {
        for(size_t m = sbbm; m < eM; m++) {
            D[(m-sbbm)*N+(n-sbbn)] = ED[m*eN+n];
        }
    }
    
    
    
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//% Backtracking of score maximizing path
//% until n = m = 1
//% this code is related to TH_DTW_E_to_Warpingpath.m
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    size_t n = N-1;
    size_t m = 0;
    
    mxArray* mx_score = mxCreateDoubleMatrix(1, 1, mxREAL );
    real_T*  score    = mxGetPr(mx_score);
    *score= D[(m)*N+n];
    
//     mexPrintf("%d %d %f\n", m, n, score);
    
    unsigned int numPath = 0;
    
    mxArray* pathFamily = mxCreateCellMatrix(N, 1);
    
    size_t len = 0;
    int32_T StepIndex = 0;
    
    real_T* path = reinterpret_cast<real_T* >(mxCalloc(2*(N+M), sizeof(real_T)));
    
    while ((m >0 || n >0)) {
        
        StepIndex = E[(m)*N+(n)];
//         mexPrintf("step %d\n", StepIndex);
        
        if (StepIndex == 0){ // up
            n--;
//             mexPrintf("step 0, m,n, %d,%d\n", m, n);
        }
        else if (StepIndex == -1) { // jump
            
            n--;
            m = M-1;
//             mexPrintf("step -1, m,n,len,num %d,%d,%d,%d\n", m, n, len, numPath);
            len = 0;
            numPath++;
        }
        else if (StepIndex == -2) { // we left the special column
            path[len*2+0] = n;
            path[len*2+1] = m;
            ++len;
            
//             mexPrintf("step -2, m,n,len,num %d,%d,%d,%d\n", m, n, len, numPath);
            
            //
            
            mxArray* mx_result = mxCreateDoubleMatrix(2, len, mxREAL);
            real_T* result = mxGetPr(mx_result);
            
            
            for (size_t i = 0; i<len; i++) {
                result[i*2+0] = path[(len-(i+1))*2+0]+1; // matlab style indices
                result[i*2+1] = path[(len-(i+1))*2+1]-1+1; // compensate for special column and matlab indices
                result[i*2+1] = result[i*2+1] + segment[0]-1; // compensate for segment start
            }
            
            mxSetCell(pathFamily, numPath-1, mxDuplicateArray(mx_result));
            
            //
            
            m--;
//             mexPrintf("step -2, m,n, %d,%d\n", m, n);
        }
        else {
            path[len*2+0] = n;
            path[len*2+1] = m;
            m -= dm[StepIndex-1];
            n -= dn[StepIndex-1];
            ++len;
//             mexPrintf("step %d, m,n, %d,%d\n", StepIndex, m, n);
        }
        
    }
    
    
    
//     mexPrintf("len %d\n", len);
//     mexPrintf("numPath %d\n", numPath);
    mxSetM(pathFamily, numPath);
    plhs[0] = pathFamily;
    plhs[1] = mx_score;
    
    
    
//     plhs[4] = mxCreateDoubleMatrix(2, len, mxREAL);
//     real_T* Result = mxGetPr(plhs[4]);
//
//
//     for (size_t i = 0; i<len; i++) {
//         Result[i*2+0] = path[(len-(i+1))*2+0]+1; // matlab style indices
//         Result[i*2+1] = path[(len-(i+1))*2+1]-1+1; // compensate for special column and matlab indices
//         Result[i*2+1] = Result[i*2+1] + segment[0]-1; // compensate for segment start
//     }
    
    mxFree(path);
    
    
//     plhs[0] = mx_D;
//     plhs[1] = mx_SSM;
//     plhs[2] = mxCreateDoubleMatrix(eN, eM, mxREAL );
//     real_T*  pED    = mxGetPr(plhs[2]);
    
//     for (size_t n = 0; n < eN; n++) {
//         for(size_t m = 0; m < eM; m++) {
//             pED[m*eN+n] = ED[m*eN+n];
//         }
//     }
    mxFree(ED);
    
//     plhs[2] = mx_E;
    
}