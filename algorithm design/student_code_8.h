#include <string>
#include <vector>
#include <iostream>
#include <cstdint>
#include <utility>
#include <algorithm>


using namespace std;
using int64 = long long;

// split s into a set of strings
// len(s) = n
// in each string, len(string) = L>=3
// x index: i,...,i+k-1; i+k,..., i+2k-1, y index:i+2k,...,L-1;
// 1<=len(x) =k,  1<=len(y)=L-2k<=k
// L =2k + (L-2k)
// 3<=L<=3k
// L/3 <=k<= (L-1)/2


const int64 B  = 911382323LL;
const int64 P1 =1000000007LL;
const int64 P2 =1000000009LL;  

vector<int64> pow1,pow2;
vector<int64> h1,h2;

void buildHash(const string& s) {
    int n = (int)s.size();
    pow1.resize(n+1);pow2.resize(n+1);
    h1.resize(n+1);h2.resize(n+1);
    pow1[0] = pow2[0] = 1;
    h1[0] = h2[0] = 0;
    for (int i = 1; i <=n; ++i) {
        pow1[i] = (pow1[i-1]*B) % P1;
        pow2[i] = (pow2[i-1]*B) % P2;
        h1[i] = (h1[i-1]*B + s[i-1]) % P1;
        h2[i] = (h2[i-1]*B + s[i-1]) % P2;
    }
}

inline pair<int64,int64> getHash(int l, int r) {
    int len = r - l + 1;
    int64 x1 = (h1[r + 1] -(h1[l] * pow1[len]) % P1 + P1) % P1;
    int64 x2 = (h2[r + 1] -(h2[l] * pow2[len]) % P2 + P2) % P2;
    return {x1, x2};
}

inline bool equalBlock(int l1, int l2, int k) {
    return getHash(l1, l1 + k - 1) == getHash(l2, l2+k-1);
}
int64 Substrings336(const string& s) {
    const int n = (int)s.size();
    if (n < 3) return 0;
    buildHash(s);

    int64 ans = 0;
    vector<int> diff;                       
    for (int i = 0; i < n; ++i) {
        const int maxLen = n - i;
        diff.assign(maxLen + 2, 0);         

        for (int k = 1; i + 2 * k < n; ++k) {    
            if (!equalBlock(i, i + k, k)) continue;

            int tail = n - (i + 2 * k);          
            int lenY = std::min(k, tail);        
            int L1 = 2 * k + 1;                 
            int L2 = 2 * k + lenY;               
            diff[L1]++;                         
            diff[L2 + 1]--;
        }

        for (int L = 3, cur = 0; L <= maxLen; ++L) {
            if ((cur += diff[L]) > 0) 
            ++ans;    
        }
    }
    return ans;
}



//small 61, input: cabcbbbacbabcabbcbabcbabcbabc
//stout:21



