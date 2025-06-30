#include <vector>
#include <algorithm>

using std::vector;
using std::sort;
using std::min;

struct Price {
    int friday, before, after;
    Price(int friday, int before, int after): friday(friday), before(before), after(after) { }
};

long long int MinCost(const vector<Price>& giftPrices, int k) {
	int n = giftPrices.size();
	vector<int> deltas;
	long long totalCost = 0;

	// total cost when except fridays; deltas
	for (int i = 0; i < n; ++i) {
		int nonFriday = min(giftPrices[i].before, giftPrices[i].after);
		totalCost += nonFriday;

		int delta = nonFriday - giftPrices[i].friday;
		deltas.push_back(delta);
	}

	sort(deltas.begin(), deltas.end(), std::greater<int>());
	for (int i = 0; i < k && i < n; ++i){
		if (deltas[i] > 0) {
			totalCost -= deltas[i];
			} else {
				break;
			}
    }
		return totalCost;
	
}
