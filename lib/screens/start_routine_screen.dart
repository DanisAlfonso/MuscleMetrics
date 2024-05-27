// start_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_model.dart';
import 'add_set_screen.dart';
import 'edit_set_screen.dart';
import 'exercise_library_screen.dart'; // Updated import

class StartRoutineScreen extends StatelessWidget {
  final Routine routine;

  const StartRoutineScreen({super.key, required this.routine});

  void _startExercise(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSetScreen(exercise: exercise),
      ),
    );
  }

  void _editSet(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSetScreen(workout: workout),
      ),
    );
  }

  void _addExercises(BuildContext context) async {
    final newExercises = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseLibraryScreen(selectedExercises: []), // Use ExerciseLibraryScreen
      ),
    );

    if (newExercises != null && newExercises.isNotEmpty) {
      for (var exercise in newExercises) {
        Provider.of<WorkoutModel>(context, listen: false).addExerciseToRoutine(routine, exercise);
      }
    }
  }

  void _removeExercise(BuildContext context, Exercise exercise) {
    Provider.of<WorkoutModel>(context, listen: false).removeExerciseFromRoutine(routine, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addExercises(context),
            tooltip: 'Add Exercise',
          ),
        ],
      ),
      body: Consumer<WorkoutModel>(
        builder: (context, workoutModel, child) {
          final workouts = workoutModel.getWorkoutsForRoutine(routine);
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: routine.exercises.map((exercise) {
              final exerciseWorkouts = workouts.where((workout) => workout.exercise == exercise).toList();

              // Calculate total sets and weight for the summary
              final totalSets = exerciseWorkouts.length;
              final totalWeight = exerciseWorkouts.fold(0.0, (sum, workout) => sum + workout.weight);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.fitness_center,
                      color: Theme.of(context).primaryColor,
                      size: 32.0,
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Sets: $totalSets, Total Weight: ${totalWeight.toStringAsFixed(1)} kg',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'remove') {
                          _removeExercise(context, exercise);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'remove',
                            child: Text('Remove Exercise'),
                          ),
                        ];
                      },
                    ),
                    children: [
                      Column(
                        children: exerciseWorkouts.map((workout) {
                          return ListTile(
                            title: Text(
                              'Reps: ${workout.repetitions}, Weight: ${workout.weight} kg',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editSet(context, workout),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    Provider.of<WorkoutModel>(context, listen: false).deleteWorkout(workout);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _startExercise(context, exercise),
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Set'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.black.withOpacity(0.25),
                            elevation: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addExercises(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
        tooltip: 'Add Exercise',
      ),
    );
  }
}
