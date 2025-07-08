import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/food_entry.dart';
import '../services/food_service.dart';
import '../services/user_service.dart';
import 'add_food_screen.dart';
import 'food_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  // The class name is now public
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<FoodEntry>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<FoodEntry>> _events = {};
  int _dailyGoal = 2500;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadUserGoal();
    _loadMonthData(_focusedDay);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _loadUserGoal() async {
    final goal = await UserService.getCurrentCalorieGoal();
    setState(() {
      _dailyGoal = goal;
    });
  }

  void _loadMonthData(DateTime month) async {
    final entries = await FoodService.getEntriesForMonth(month);
    final Map<DateTime, List<FoodEntry>> events = {};
    for (var entry in entries) {
      final day = DateTime.utc(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      if (events[day] == null) {
        events[day] = [];
      }
      events[day]!.add(entry);
    }
    setState(() {
      _events = events;
    });
    // Refresh selected day events
    _onDaySelected(_selectedDay!, _focusedDay);
  }

  List<FoodEntry> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  int _calculateTotalCalories(List<FoodEntry> entries) {
    return entries.fold(0, (sum, item) => sum + item.calories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Calendar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar<FoodEntry>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadMonthData(focusedDay);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  final totalCalories = _calculateTotalCalories(events);
                  IconData icon;
                  Color color;
                  if (totalCalories > _dailyGoal) {
                    icon = Icons.cancel;
                    color = Colors.red;
                  } else {
                    icon = Icons.check_circle;
                    color = Colors.green;
                  }
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Icon(icon, color: color, size: 16),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<FoodEntry>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                final totalCalories = _calculateTotalCalories(value);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Daily Goal: $_dailyGoal kcal | Consumed: $totalCalories kcal", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            child: ListTile(
                              onTap: () async {
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailsScreen(entry: value[index])));
                                if (result == true) {
                                  _loadMonthData(_focusedDay);
                                }
                              },
                              title: Text(value[index].name),
                              subtitle: Text(value[index].quantity),
                              trailing: Text('${value[index].calories} kcal'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            // The constructor now correctly includes the selectedDate parameter
            MaterialPageRoute(builder: (context) => AddFoodScreen(selectedDate: _selectedDay)),
          );
          if (result == true) {
            _loadMonthData(_focusedDay);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}