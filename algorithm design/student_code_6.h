#include <vector>
#include <algorithm>
#include <cmath>
#include<cstdlib>


using std::vector;

// assume we always watch i
// dpi = min(dpj + P(i-1)- Pj+  |ei - ej| ))
// final = min(Pn, min(dpi + Pn-Pi)
vector<int> Episodes(const vector<int>& excitement, const vector<int>& penalty) {
    // create a int of size n
    int n = static_cast<int>(penalty.size());
    const long long INF = 2*1e13 + 1;
    // i = 2 for watched episode 2, i = 0 for not
    vector<int> path(n + 1, 0);
    vector<int> return_path;
    // store dpi
    vector<long long> dp(n+1, INF);
    // Pi = p1 + ... + pi, P0 = 0
    vector<long long> P(n+1,0);
    for (int i = 1; i <= n; ++ i)   P[i] = penalty[i-1] + P[i-1];
    // store j
    vector<int> pre(n + 1, -1);
    dp[0] = 0;
    pre[0] = 0;

    // dpi = min(dpj + P(i-1)- Pj+ |ei - ej|))
    for (int i = 1; i <= n; ++i) {
        pre[i] = -1;

        for (int j = 0; j < i; ++j) {
        long long mood = (j==0 ? 0 :
                      std::llabs(excitement[i-1] -
                                 excitement[j-1]));

        long long watch = dp[j] + P[i-1] -P[j] + mood;
            if (watch < dp[i]) {
                dp[i] = watch;
                pre[i]  = j;   
            }
        }
        path[i] = 1;
    }
    // final = min(Pn, min(dpi + Pn-Pi)
    long long secondCost  = P[n]; 
    int last = 0;
    for (int i = 1; i <= n; ++i) {
        long long cost = dp[i] + P[n] - P[i];
        if ( cost < secondCost) {
            secondCost = cost;
            last = i; 
        } 
    }

    for (int i = last; i > 0;i = pre[i]) {
            return_path.push_back(i);
    }
    std::reverse(return_path.begin(), return_path.end());
    return return_path;
}
    

