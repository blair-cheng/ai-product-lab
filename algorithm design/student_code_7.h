#include <vector>
#include <algorithm>

using std::vector;
using std::min;
using std::max;
// choose prefix
// subproblem: dp[i,j], the maximum reward we get at dayi with j stocks
// dp[i,j] = max(sell on dayi, buy on dayi, don't)
// j = {0, ... , min(k, n)}
// dayi = 0: dp[i, j] = dp[i-1,j]
// dayi = 1: dp[i, j] = dp[i-1, j-1] - buy[i](j>0)
// dayi = -1: dp[i,j] = dp[i-1,j+1] + sell[i](j<k)
vector<int> Stocks(const vector<int>& buy, const vector<int>& sell, long long int k) {
    int n = static_cast<int>(buy.size());
    // 0 ≤ n ≤ 7000, 0 ≤ k ≤ 10^18, and all other numbers are between 0 and 10^9.
    const long long INF =  -1e15;
    int stock_limit = min(n,static_cast<int>(k));
    vector<vector<long long>> dp(n + 1, vector<long long>(stock_limit + 1, INF));
    vector<vector<char>> act(n,vector<char>(stock_limit + 1, 0));
    vector<int>decision(n,0);
    dp[0][0] = 0;
    
    for (int i = 1; i <= n; ++i) {
        for (int j = 0; j<=stock_limit; ++j) {
            // dayi = 0: dp[i, j] = dp[i-1,j]; means 
            if (dp[i - 1][j] != INF && dp[i - 1][j] > dp[i][j]) {
                dp[i][j] = dp[i - 1][j];
                act[i-1][j] = 0;
            }
            // dayi = 1: dp[i, j] = dp[i-1, j-1] - buy[i](j>0)
            if (j > 0&& dp[i-1][j-1] !=INF && dp[i-1][j-1] -buy[i-1] > dp[i][j]) {
                dp[i][j] = dp[i-1][j-1] -buy[i-1];
                act[i-1][j] = 1;
            }
            // dayi = -1: dp[i,j] = dp[i-1,j+1] + sell[i](j<k)
            if ( j<stock_limit && dp[i-1][j+1] != INF && dp[i-1][j+1] + sell[i-1] > dp[i][j]) {
                dp[i][j] = dp[i-1][j+1] + sell[i-1];
                act[i-1][j] = -1;
            }
        }
    }
    int j = 0;
    for (int i = n-1; i >= 0;--i) {
        int a = act[i][j];
        decision[i] = a;
        if (a == 1) --j;
        else if (a == -1) ++j;
    }
    return decision;
}



//output 52: 
//1 -1  1  -1 1  1  0  -1 -1 0
//input small 22
//10 2
//29 50 18 89 1  19 51 27 39 55
//16 74 4  95 11 90 17 98 85 8
//                  1  1  0  -1

