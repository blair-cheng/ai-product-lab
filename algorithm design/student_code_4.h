#include <vector>
#include<algorithm>
#include<unordered_map>

using std::sort;
using std::vector;
using std::max;
using std::unordered_map;
int MaxHouses(const vector<int>& colors) {

    unordered_map<int,int> last; // creat a hash table， to save color and latest index


    int left = 0; // index of left pointer
    int best = 0;  // the largest span

    for (int right = 0; 
        right < static_cast<int>(colors.size()); // if index of right pointer < input amount
        ++right)
    {
        int c = colors[right]; // current color to check
            
        if (last.count(c) && left <= last[c]) // if c already showed before 
          // and  
            left = last[c] + 1;

        last[c] = right; // save key: value: color
        best = max(best, right - left + 1);
    }
    return best;
}