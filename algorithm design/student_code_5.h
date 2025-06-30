#include <vector>
#include <algorithm>

using std::min;
using std::max;
using std::vector;

//return an array
    //array[i] =  1 if gift[i] use boundle[i]
    //array[i] = -1 if gift[i] use boudle[i-1]
    //array[i] =  0 if gift[i] use cost[i]
    //array index from 0 to n-1
//subproblem: dp[i] = min(dp[i+1] + cost[i], dp[i+2] + boudle[i])
//store dpi
//basecase: dp[n] = 0;
//boundle index[0,...,n-2],cost index[0,...,n-1]
//dp[n-1] = min(dp[n] + cost[n-1], dp[n+1] + boudle[n-1])
vector<int> Purchases(const vector<int>& cost, const vector<int>& bundle) {
    // create a vector of dp to store return value
    int n = static_cast<int>(cost.size());
    // initialise dp[n+1] to store intermediat value 
    vector<long long> dp(n+2, 0);
    // create a vector of result
    vector<int> result(n, 0);
    vector<int> path(n, 0);
    const long long INF = 1e18;
    
    for (int i = n -1; i >= 0; --i) {
        long long group = (i+1<n)?dp[i+2] + bundle[i]:INF;
        long long solo = dp[i+1] + cost[i];
        if (solo <= group) {
            dp[i] = solo;
            path[i] = 0;}
        else {
            dp[i] = group;   
            path[i] = 1;}
    }

    for (int i = 0; i < n; ) {
        if ( path[i] ==1) {
            result[i] = 1;
            result[i+1] = -1;  
            i += 2;
    }   else {
            result[i] = 0;
            i += 1;}
    }  
    return result;

}
