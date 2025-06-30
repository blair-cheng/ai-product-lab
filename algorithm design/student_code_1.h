
#include <vector>
#include <algorithm>

using std::vector;

vector<int> count_dishes(const vector<int>& money, const vector<int>& prices){
	vector<int> sorted_prices = prices;
	std::sort(sorted_prices.begin(), sorted_prices.end());
	vector<int>result;
	for (int amount: money){
	int low = 0;
	int high = sorted_prices.size();
	
	while (low< high){
		int mid = (low + high)/2;
		if (sorted_prices[mid] <= amount){
			low = mid + 1;
		} else{
			high = mid;
		}
	}
	result.push_back(low);
	}
	return result;

}