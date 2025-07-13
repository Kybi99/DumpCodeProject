
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String meal = "Grilled Salmon with Quinoa";
  int calories = 470;
  int protein = 31;
  int fat = 23;
  int carbs = 35;

  String exercise = "Bench Press 4x8";
  String suggestion = "Seated Row 3x10 to balance pushing movements";

  void updateMeal() {
    setState(() {
      meal = "Chicken stir fry with rice";
      calories = 560;
      protein = 38;
      fat = 18;
      carbs = 45;
    });
  }

  void updateWorkout() {
    setState(() {
      exercise = "Pull-ups 4x6";
      suggestion = "Plank with shoulder taps for core stability";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NutriSync")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: Text("🍽️ Meal Suggestion"),
                subtitle: Text("\$meal\n\$calories kcal | \$protein g P | \$fat g F | \$carbs g C"),
              ),
            ),
            ElevatedButton(
              onPressed: updateMeal,
              child: Text("AI Predlog Obroka"),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text("🏋️ Workout"),
                subtitle: Text(exercise),
              ),
            ),
            ElevatedButton(
              onPressed: updateWorkout,
              child: Text("AI Novi Trening"),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text("🤖 AI Predlog Vežbe"),
                subtitle: Text(suggestion),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
