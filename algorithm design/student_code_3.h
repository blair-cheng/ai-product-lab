
#include <vector>
#include <algorithm>
using std::vector;
using std::sort;
using std::max;
struct Plant {
int start, finish, power;
Plant(int start, int finish, int power): start(start), finish(finish), power(power) { }
};

struct Event{
    int time;
    int power_change;
};

long long int MinPower(const vector<Plant>& plants) {

    vector<Event>events;

    for (const Plant& p : plants) {
        events.push_back({p.start, p.power});
        events.push_back({p.finish, -p.power});
    }

    sort(events.begin(), events.end(), [](const Event& a, const Event& b ){
        return (a.time == b.time) ? (a.power_change<b.power_change)
                                  : (a.time < b.time );
    });

    long long current_power = 0;
    long long max_power = 0;

    for (const Event&e : events) {
        current_power +=e.power_change;
        max_power = max(max_power, current_power);
    }
    return max_power;
}
