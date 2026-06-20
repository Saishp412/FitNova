import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'active_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutTitle;
  final bool isGymMode;
  final int durationMinutes;

  WorkoutDetailScreen({
    super.key,
    required this.workoutTitle,
    required this.isGymMode,
    required this.durationMinutes,
  });

  List<Map<String, String>> _getWarmup() {
    return [
      {'name': 'Arm Circles', 'sets': '1 min', 'desc': 'Warm up the shoulders with forward and backward circles.', 'mediaUrl': 'https://youtu.be/sUHHw35YTKU?si=5vXtiw2awOtar_d2'},
      {'name': 'Jumping Jacks', 'sets': '2 mins', 'desc': 'A classic full-body cardio warmup.', 'mediaUrl': 'https://www.youtube.com/watch?v=CWpmIW6l-YA'},
      {'name': 'High Knees', 'sets': '1 min', 'desc': 'Drive your knees up to your chest quickly.', 'mediaUrl': 'https://youtu.be/N4VwL0WGhzw?si=8i8xZ9-bfCUwVx_L'},
      {'name': 'Torso Twists', 'sets': '1 min', 'desc': 'Twist your torso to warm up the core.', 'mediaUrl': 'https://youtu.be/h6XyzlM8m24?si=kQdKizyRrph3b0uz'},
    ];
  }

  List<Map<String, String>> _getCoolDown() {
    return [
      {'name': 'Child\'s Pose', 'sets': '1 min', 'desc': 'Rest your hips back on your heels and stretch arms forward.'},
      {'name': 'Hamstring Stretch', 'sets': '1 min', 'desc': 'Reach for your toes while seated or standing.'},
      {'name': 'Shoulder Stretch', 'sets': '1 min', 'desc': 'Pull one arm across your chest and hold.'},
      {'name': 'Deep Breathing', 'sets': '2 mins', 'desc': 'Inhale deeply through your nose, exhale through your mouth.'},
    ];
  }

  Map<String, List<Map<String, String>>> _getWorkoutSections() {
    final title = workoutTitle.toLowerCase();
    
    if (isGymMode) {
// temp gym splits
      if (title.contains('push')) {
        return {
          'Chest': [
            {
              'name': '1. Barbell Bench Press',
              'sets': '4x6-8',
              'desc': 'Form:\n• Keep feet planted firmly on the floor and maintain a slight arch in your lower back.\n• Retract and depress your shoulder blades ("chest up, shoulders back").\n• Lower the bar to mid-chest with control and press explosively without bouncing.\n\nKey cue: Drive through your feet and keep wrists stacked over elbows.',
              'mediaUrl': 'https://youtu.be/GN7oCznV_IU?si=riUX4Utr-hEHjByh'
            },
            {
              'name': '2. Incline Dumbbell Press',
              'sets': '4x8-12',
              'desc': 'Form:\n• Set bench to about 30–45° incline.\n• Lower dumbbells until you feel a deep chest stretch.\n• Press upward while bringing the dumbbells slightly inward.\n\nKey cue: Let the chest do the work, not the front delts.',
              'mediaUrl': 'https://youtu.be/jMQA3XtJSgo?si=tq9LT_mYUYi-v8SW'
            },
            {
              'name': '3. Machine Chest Press',
              'sets': '3x10-12',
              'desc': 'Form:\n• Keep shoulder blades pinned against the pad.\n• Press smoothly and avoid locking elbows aggressively.\n• Control the eccentric (lowering phase) for 2–3 seconds.\n\nKey cue: Focus on chest contraction rather than moving maximum weight.',
              'mediaUrl': 'https://youtu.be/dYF2d_I24uE?si=vZC17Jpe1EIX0c_F'
            },
            {
              'name': '4. Cable Fly',
              'sets': '3x12-15',
              'desc': 'Form:\n• Maintain a slight bend in the elbows throughout.\n• Bring hands together in a hugging motion.\n• Slowly return to stretch the chest.\n\nKey cue: Imagine squeezing your biceps together at the center.',
              'mediaUrl': 'https://youtu.be/PRw7ieDBLl4?si=uGAwgUcHsojLerPS'
            },
          ],
          'Shoulder': [
            {
              'name': '5. Seated Dumbbell Shoulder Press',
              'sets': '4x8-10',
              'desc': 'Form:\n• Keep your back supported against the bench.\n• Press dumbbells upward in a natural arc.\n• Lower until elbows reach about shoulder level.\n\nKey cue: Don\'t flare elbows completely sideways.',
              'mediaUrl': 'https://youtu.be/hOTABpGvhBc?si=Gv2RGdMUK01j3CUw'
            },
            {
              'name': '6. Dumbbell Lateral Raises',
              'sets': '4x12-15',
              'desc': 'Form:\n• Raise arms out to the sides until shoulder height.\n• Lead with elbows, not hands.\n• Use slow, controlled movement with minimal swinging.\n\nKey cue: Think "pouring water from a jug" at the top.',
              'mediaUrl': 'https://youtu.be/XPPfnSEATJA?si=aYsSbBuGX-LHOZWU'
            },
            {
              'name': '7. Cable Lateral Raises',
              'sets': '3x12-15',
              'desc': 'Form:\n• Stand slightly away from the cable stack.\n• Lift through the elbow and stop around shoulder height.\n• Maintain constant tension throughout the movement.\n\nKey cue: Avoid shrugging your traps.',
              'mediaUrl': 'https://youtu.be/Z5FA9aq3L6A?si=lCFmSiEn4hRBDU9-'
            },
          ],
          'Tricep': [
            {
              'name': '8. Rope Tricep Pushdowns',
              'sets': '3x10-12',
              'desc': 'Form:\n• Keep elbows pinned to your sides.\n• Push the rope down and slightly apart at the bottom.\n• Return slowly while maintaining tension.\n\nKey cue: Only your forearms should move.',
              'mediaUrl': 'https://youtu.be/JDEDaZTEzGE?si=T_S4Sb3XlfHml3WG'
            },
            {
              'name': '9. Overhead Rope Extensions',
              'sets': '3x12-15',
              'desc': 'Form:\n• Position elbows close to your head.\n• Fully stretch the triceps at the bottom.\n• Extend until arms are straight without locking hard.\n\nKey cue: Feel the stretch in the long head of the triceps.',
              'mediaUrl': 'https://youtu.be/ns-RGsbzqok?si=PvZw3bMlzk490OKi'
            },
            {
              'name': '10. Assisted Dips / Weighted Dips',
              'sets': '3x8-12',
              'desc': 'Form:\n• Lean slightly forward to emphasize chest.\n• Descend until upper arms are roughly parallel to the floor.\n• Push back up without swinging.\n\nKey cue: Keep shoulders stable and avoid excessive depth if it causes discomfort.',
              'mediaUrl': 'https://youtu.be/t_LopJ0nW6M?si=9GsYhkahflfA0ta3'
            },
          ],
        };
      } else if (title.contains('pull')) {
        return {
          'Vertical Pulling (Back Width)': [
            {
              'name': '1. Pull-Ups / Assisted Pull-Ups',
              'sets': '4x6-10',
              'desc': 'Form:\n• Start from a dead hang with shoulders engaged.\n• Pull your chest toward the bar rather than just getting your chin over it.\n• Lower yourself under control.\n\nKey cue: Think "drive elbows into your pockets."',
              'mediaUrl': 'https://youtube.com/shorts/FVqgCT9H1pg?si=swwcEuJRzK0twv68'
            },
            {
              'name': '2. Lat Pulldown',
              'sets': '4x8-12',
              'desc': 'Form:\n• Slight lean back (10–15°).\n• Pull bar to upper chest.\n• Let lats stretch fully at the top.\n\nKey cue: Pull with elbows, not your hands.',
              'mediaUrl': 'https://youtu.be/JGeRYIZdojU?si=6WKXH-t6Lm52nDs2'
            },
          ],
          'Horizontal Pulling (Back Thickness)': [
            {
              'name': '3. Chest Supported Row',
              'sets': '4x8-12',
              'desc': 'Form:\n• Keep chest firmly against the pad.\n• Pull elbows backward while squeezing shoulder blades.\n• Lower weight slowly.\n\nKey cue: Focus on squeezing the middle back.',
              'mediaUrl': 'https://youtu.be/H75im9fAUMc?si=w06LLs9hL5TaTaRD'
            },
            {
              'name': '4. Single-Arm Dumbbell Row',
              'sets': '3x10-12 /side',
              'desc': 'Form:\n• Keep back flat and core tight.\n• Pull dumbbell toward your hip.\n• Fully stretch at the bottom.\n\nKey cue: Elbow travels toward the hip, not the shoulder.',
              'mediaUrl': 'https://youtu.be/dFzUjzfih7k?si=QzoeaRG_Q1Ed2pae'
            },
            {
              'name': '5. Seated Cable Row',
              'sets': '3x10-12',
              'desc': 'Form:\n• Sit tall with neutral spine.\n• Pull handle toward lower ribs.\n• Pause briefly and squeeze shoulder blades.\n\nKey cue: Chest up, shoulders down.',
              'mediaUrl': 'https://youtu.be/vwHG9Jfu4sw?si=FPpDsO0AHN0LtCY2'
            },
          ],
          'Rear Delts': [
            {
              'name': '6. Face Pulls',
              'sets': '3x12-15',
              'desc': 'Form:\n• Pull rope toward your forehead.\n• Elbows should flare outward.\n• Pause at full contraction.\n\nKey cue: Separate the rope at the end of the movement.',
              'mediaUrl': 'https://youtu.be/0Po47vvj9g4?si=cpu3z77tdgE3P2Pq'
            },
          ],
          'Biceps': [
            {
              'name': '7. Barbell Curl',
              'sets': '4x8-10',
              'desc': 'Form:\n• Stand tall with elbows fixed.\n• Curl weight without swinging.\n• Lower slowly.\n\nKey cue: Elbows stay beside your torso.',
              'mediaUrl': 'https://youtu.be/jnfveKq1i3E?si=ikVYBevFk9LeWjhI'
            },
            {
              'name': '8. Incline Dumbbell Curl',
              'sets': '3x10-12',
              'desc': 'Form:\n• Use a 45–60° incline bench.\n• Let arms hang completely.\n• Curl while keeping elbows behind your body.\n\nKey cue: Feel the stretch at the bottom.',
              'mediaUrl': 'https://youtu.be/HhHHBj3qTJ4?si=AGqlQOshuwHrgDu6'
            },
            {
              'name': '9. Hammer Curl',
              'sets': '3x10-12',
              'desc': 'Form:\n• Keep palms facing each other.\n• Curl straight upward.\n• Control the lowering phase.\n\nKey cue: Focus on forearms and brachialis.',
              'mediaUrl': 'https://youtu.be/BRVDS6HVR9Q?si=YDC-1fkWVU0LTeT2'
            },
          ],
        };
      } else if (title.contains('leg')) {
        final Map<String, List<Map<String, String>>> legsSplit = {
          'Heavy Compound Work': [
            {
              'name': '1. Barbell Back Squat',
              'sets': '4x6-8',
              'desc': 'Form:\n• Place the bar securely across your upper traps/rear delts.\n• Keep chest up, core braced, and feet shoulder-width apart.\n• Descend until thighs are at least parallel to the floor, then drive upward.\n\nKey cue: Sit between your hips, not onto your knees.',
              'mediaUrl': 'https://youtu.be/rrJIyZGlK8c?si=jUHqWM7OF-5uQpA-'
            },
            {
              'name': '2. Romanian Deadlift (RDL)',
              'sets': '4x8-10',
              'desc': 'Form:\n• Keep a slight bend in the knees.\n• Push hips backward while keeping the bar close to your legs.\n• Lower until you feel a strong hamstring stretch, then drive hips forward.\n\nKey cue: Hips back, not bar down.',
              'mediaUrl': 'https://youtu.be/7j-2w4-P14I?si=mc0p8JbFpzCBsO5L'
            },
            {
              'name': '3. Leg Press',
              'sets': '4x10-12',
              'desc': 'Form:\n• Place feet shoulder-width apart on the platform.\n• Lower under control until knees reach roughly 90° or deeper if comfortable.\n• Push through the middle of your foot.\n\nKey cue: Don\'t let your lower back lift off the pad.',
              'mediaUrl': 'https://youtu.be/4PYXEYqgCqk?si=lFdqm-wddLRA6naT'
            },
          ],
          'Single-Leg Work': [
            {
              'name': '4. Bulgarian Split Squat',
              'sets': '3x10 /leg',
              'desc': 'Form:\n• Place rear foot on a bench.\n• Keep torso slightly forward.\n• Lower until front thigh reaches parallel.\n\nKey cue: Front leg does the work; rear leg is for balance.',
              'mediaUrl': 'https://youtu.be/vgn7bSXkgkA?si=8MPv7OX6UtsnCbMa'
            },
            {
              'name': '5. Walking Lunges',
              'sets': '2x20 steps',
              'desc': 'Form:\n• Take long controlled steps.\n• Lower until both knees are about 90°.\n• Push through the front heel to move forward.\n\nKey cue: Stay balanced and upright.',
              'mediaUrl': 'https://youtube.com/shorts/P5W2mvm1aGE?si=oG-40fHBKFD6dLR_'
            },
          ],
          'Isolation Work': [
            {
              'name': '6. Leg Extension',
              'sets': '3x12-15',
              'desc': 'Form:\n• Adjust the machine so knees align with the pivot point.\n• Extend legs fully and squeeze quads at the top.\n• Lower slowly.\n\nKey cue: Pause for 1 second at the top.',
              'mediaUrl': 'https://youtube.com/shorts/uM86QE59Tgc?si=UjbuOXFIFHaELsas'
            },
            {
              'name': '7. Lying Leg Curl',
              'sets': '3x12-15',
              'desc': 'Form:\n• Keep hips pressed into the pad.\n• Curl heels toward glutes.\n• Lower slowly and fully stretch hamstrings.\n\nKey cue: Control the negative.',
              'mediaUrl': 'https://youtu.be/5xR8tvg4-yM?si=XV3aqyxuoM-1gn9k'
            },
          ],
          'Calves': [
            {
              'name': '8. Standing Calf Raises',
              'sets': '4x12-15',
              'desc': 'Form:\n• Lower heels as far as possible.\n• Rise onto your toes as high as possible.\n• Pause briefly at the top.\n\nKey cue: Full stretch and full contraction every rep.',
              'mediaUrl': 'https://youtu.be/k8ipHzKeAkQ?si=iDOSs1OeLVXRDW_w'
            },
            {
              'name': '9. Seated Calf Raises',
              'sets': '3x15-20',
              'desc': 'Form:\n• Allow calves to stretch fully at the bottom.\n• Raise weight under control.\n• Hold peak contraction for 1 second.\n\nKey cue: Don\'t bounce the weight.',
              'mediaUrl': 'https://youtu.be/3ZRe_QpvRPg?si=PNzjdoFBUoeSTHbW'
            },
          ],
        };
        if (title.contains('shoulder')) {
          legsSplit.addAll({
            'Shoulder Pressing': [
              {
                'name': '1. Seated Dumbbell Shoulder Press',
                'sets': '4x8-10',
                'desc': 'Form:\n• Sit upright with back supported.\n• Start with dumbbells at shoulder level.\n• Press upward in a natural arc until arms are nearly straight.\n\nKey cue: Keep core tight and avoid arching your lower back.',
                'mediaUrl': 'https://youtu.be/hOTABpGvhBc?si=Gv2RGdMUK01j3CUw'
              },
              {
                'name': '2. Machine Shoulder Press',
                'sets': '3x10-12',
                'desc': 'Form:\n• Adjust seat so handles begin around shoulder height.\n• Press smoothly and under control.\n• Lower slowly for maximum tension.\n\nKey cue: Let the shoulders work, not momentum.',
                'mediaUrl': 'https://youtu.be/s9WgXdWJkfQ?si=BdFD_-MDgI6Zqsly'
              },
            ],
            'Side Delts': [
              {
                'name': '3. Dumbbell Lateral Raise',
                'sets': '4x12-15',
                'desc': 'Form:\n• Raise arms out to your sides until shoulder height.\n• Keep a slight bend in the elbows.\n• Lower under control.\n\nKey cue: Lead with elbows, not hands.',
                'mediaUrl': 'https://youtu.be/XPPfnSEATJA?si=aYsSbBuGX-LHOZWU'
              },
              {
                'name': '4. Cable Lateral Raise',
                'sets': '3x12-15',
                'desc': 'Form:\n• Stand beside the cable stack.\n• Raise arm outward while maintaining constant tension.\n• Stop at shoulder height.\n\nKey cue: Avoid shrugging your traps.',
                'mediaUrl': 'https://youtu.be/Z5FA9aq3L6A?si=lCFmSiEn4hRBDU9-'
              },
            ],
            'Rear Delts': [
              {
                'name': '5. Reverse Pec Deck',
                'sets': '4x12-15',
                'desc': 'Form:\n• Sit facing the machine.\n• Pull handles backward in a wide arc.\n• Squeeze rear delts at the end.\n\nKey cue: Think about moving elbows apart rather than pulling with hands.',
                'mediaUrl': 'https://youtu.be/Y59M5fXn8bs?si=DgL4N5agveCJCWBd'
              },
            ],
            'Biceps': [
              {
                'name': '6. EZ Bar Curl',
                'sets': '4x8-10',
                'desc': 'Form:\n• Keep elbows fixed beside your torso.\n• Curl the bar without swinging.\n• Lower slowly.\n\nKey cue: Don\'t let elbows drift forward.',
              },
              {
                'name': '7. Preacher Curl',
                'sets': '3x10-12',
                'desc': 'Form:\n• Keep upper arms firmly against the pad.\n• Curl through full range of motion.\n• Lower under complete control.\n\nKey cue: Eliminate momentum completely.',
                'mediaUrl': 'https://youtu.be/DoCWeUBA0Gs?si=C6N66jwMegGWxJHP'
              },
              {
                'name': '8. Hammer Curl',
                'sets': '3x10-12',
                'desc': 'Form:\n• Use a neutral grip (palms facing each other).\n• Keep elbows stationary.\n• Lift and lower with control.\n\nKey cue: Focus on squeezing forearms and brachialis.',
                'mediaUrl': 'https://youtu.be/BRVDS6HVR9Q?si=YDC-1fkWVU0LTeT2'
              },
            ],
            'Triceps': [
              {
                'name': '9. Rope Pushdown',
                'sets': '4x10-12',
                'desc': 'Form:\n• Keep elbows tucked near your ribs.\n• Push rope downward and slightly outward.\n• Fully extend at the bottom.\n\nKey cue: Only forearms should move.',
                'mediaUrl': 'https://youtu.be/JDEDaZTEzGE?si=T_S4Sb3XlfHml3WG'
              },
              {
                'name': '10. Overhead Cable Extension',
                'sets': '3x12-15',
                'desc': 'Form:\n• Face away from the cable machine.\n• Keep elbows close to your head.\n• Extend arms fully and return slowly.\n\nKey cue: Feel the stretch at the bottom.',
                'mediaUrl': 'https://youtu.be/ns-RGsbzqok?si=PvZw3bMlzk490OKi'
              },
              {
                'name': '11. Skull Crushers',
                'sets': '3x8-10',
                'desc': 'Form:\n• Lie on a flat bench.\n• Lower EZ bar toward forehead or slightly behind head.\n• Extend elbows to return to start.\n\nKey cue: Keep upper arms fixed throughout.',
                'mediaUrl': 'https://youtu.be/S0fmDR60X-o?si=qldlQcTGB-MDhArl'
              },
            ],
          });
        }
        return legsSplit;
      } else if (title.contains('shoulder')) {
        return {
          'Shoulder Pressing': [
            {
              'name': '1. Seated Dumbbell Shoulder Press',
              'sets': '4x8-10',
              'desc': 'Form:\n• Sit upright with back supported.\n• Start with dumbbells at shoulder level.\n• Press upward in a natural arc until arms are nearly straight.\n\nKey cue: Keep core tight and avoid arching your lower back.',
              'mediaUrl': 'https://youtu.be/hOTABpGvhBc?si=Gv2RGdMUK01j3CUw'
            },
            {
              'name': '2. Machine Shoulder Press',
              'sets': '3x10-12',
              'desc': 'Form:\n• Adjust seat so handles begin around shoulder height.\n• Press smoothly and under control.\n• Lower slowly for maximum tension.\n\nKey cue: Let the shoulders work, not momentum.',
              'mediaUrl': 'https://youtu.be/s9WgXdWJkfQ?si=BdFD_-MDgI6Zqsly'
            },
          ],
          'Side Delts': [
            {
              'name': '3. Dumbbell Lateral Raise',
              'sets': '4x12-15',
              'desc': 'Form:\n• Raise arms out to your sides until shoulder height.\n• Keep a slight bend in the elbows.\n• Lower under control.\n\nKey cue: Lead with elbows, not hands.',
              'mediaUrl': 'https://youtu.be/XPPfnSEATJA?si=aYsSbBuGX-LHOZWU'
            },
            {
              'name': '4. Cable Lateral Raise',
              'sets': '3x12-15',
              'desc': 'Form:\n• Stand beside the cable stack.\n• Raise arm outward while maintaining constant tension.\n• Stop at shoulder height.\n\nKey cue: Avoid shrugging your traps.',
              'mediaUrl': 'https://youtu.be/Z5FA9aq3L6A?si=lCFmSiEn4hRBDU9-'
            },
          ],
          'Rear Delts': [
            {
              'name': '5. Reverse Pec Deck',
              'sets': '4x12-15',
              'desc': 'Form:\n• Sit facing the machine.\n• Pull handles backward in a wide arc.\n• Squeeze rear delts at the end.\n\nKey cue: Think about moving elbows apart rather than pulling with hands.',
              'mediaUrl': 'https://youtu.be/Y59M5fXn8bs?si=DgL4N5agveCJCWBd'
            },
          ],
          'Biceps': [
            {
              'name': '6. EZ Bar Curl',
              'sets': '4x8-10',
              'desc': 'Form:\n• Keep elbows fixed beside your torso.\n• Curl the bar without swinging.\n• Lower slowly.\n\nKey cue: Don\'t let elbows drift forward.',
            },
            {
              'name': '7. Preacher Curl',
              'sets': '3x10-12',
              'desc': 'Form:\n• Keep upper arms firmly against the pad.\n• Curl through full range of motion.\n• Lower under complete control.\n\nKey cue: Eliminate momentum completely.',
              'mediaUrl': 'https://youtu.be/DoCWeUBA0Gs?si=C6N66jwMegGWxJHP'
            },
            {
              'name': '8. Hammer Curl',
              'sets': '3x10-12',
              'desc': 'Form:\n• Use a neutral grip (palms facing each other).\n• Keep elbows stationary.\n• Lift and lower with control.\n\nKey cue: Focus on squeezing forearms and brachialis.',
              'mediaUrl': 'https://youtu.be/BRVDS6HVR9Q?si=YDC-1fkWVU0LTeT2'
            },
          ],
          'Triceps': [
            {
              'name': '9. Rope Pushdown',
              'sets': '4x10-12',
              'desc': 'Form:\n• Keep elbows tucked near your ribs.\n• Push rope downward and slightly outward.\n• Fully extend at the bottom.\n\nKey cue: Only forearms should move.',
              'mediaUrl': 'https://youtu.be/JDEDaZTEzGE?si=T_S4Sb3XlfHml3WG'
            },
            {
              'name': '10. Overhead Cable Extension',
              'sets': '3x12-15',
              'desc': 'Form:\n• Face away from the cable machine.\n• Keep elbows close to your head.\n• Extend arms fully and return slowly.\n\nKey cue: Feel the stretch at the bottom.',
              'mediaUrl': 'https://youtu.be/ns-RGsbzqok?si=PvZw3bMlzk490OKi'
            },
            {
              'name': '11. Skull Crushers',
              'sets': '3x8-10',
              'desc': 'Form:\n• Lie on a flat bench.\n• Lower EZ bar toward forehead or slightly behind head.\n• Extend elbows to return to start.\n\nKey cue: Keep upper arms fixed throughout.',
              'mediaUrl': 'https://youtu.be/S0fmDR60X-o?si=qldlQcTGB-MDhArl'
            },
          ],
        };
      } else if (title.contains('upper')) {
        return {
          'Primary Compound Pair': [
            {
              'name': '1. Incline Barbell Press',
              'sets': '4x6-8',
              'desc': 'Form:\n• Set bench at roughly 30°.\n• Keep shoulder blades pulled back and chest high.\n• Lower the bar to the upper chest and press explosively.\n\nKey cue: Drive elbows slightly toward your feet, not straight outward.',
              'mediaUrl': 'https://youtu.be/lJ2o89kcnxY?si=OxqPhWq1UTl-TjfA'
            },
            {
              'name': '2. Weighted Pull-Ups',
              'sets': '4x6-8',
              'desc': 'Form:\n• Start from a dead hang.\n• Pull chest toward the bar.\n• Lower slowly and fully extend arms.\n\nKey cue: Pull with elbows, not hands.',
              'mediaUrl': 'https://youtu.be/wk2HkH2_3m0?si=FYHSP8yOZV8s_uUi'
            },
          ],
          'Secondary Compound Pair': [
            {
              'name': '3. Flat Dumbbell Press',
              'sets': '3x8-10',
              'desc': 'Form:\n• Keep feet firmly planted.\n• Lower dumbbells until elbows reach slightly below bench level.\n• Press upward while squeezing the chest.\n\nKey cue: Full stretch at the bottom.',
              'mediaUrl': 'https://youtu.be/O7ECGhZj_Hc?si=O-lLe6zddCVwlV8v'
            },
            {
              'name': '4. Chest Supported Row',
              'sets': '3x8-10',
              'desc': 'Form:\n• Keep chest against the pad.\n• Pull elbows backward.\n• Pause briefly at the contraction.\n\nKey cue: Squeeze shoulder blades together.',
              'mediaUrl': 'https://youtu.be/H75im9fAUMc?si=w06LLs9hL5TaTaRD'
            },
          ],
          'Shoulder Work': [
            {
              'name': '5. Machine Shoulder Press',
              'sets': '3x10-12',
              'desc': 'Form:\n• Adjust seat height correctly.\n• Press upward smoothly.\n• Lower under control.\n\nKey cue: Avoid bouncing at the bottom.',
              'mediaUrl': 'https://youtu.be/s9WgXdWJkfQ?si=BdFD_-MDgI6Zqsly'
            },
            {
              'name': '6. Cable Lateral Raise',
              'sets': '3x12-15',
              'desc': 'Form:\n• Lift through the elbow.\n• Stop around shoulder height.\n• Lower slowly while maintaining tension.\n\nKey cue: Keep traps relaxed.',
              'mediaUrl': 'https://youtu.be/Z5FA9aq3L6A?si=lCFmSiEn4hRBDU9-'
            },
          ],
          'Back Width & Arms Finisher': [
            {
              'name': '7. Lat Pulldown',
              'sets': '3x10-12',
              'desc': 'Form:\n• Use a shoulder-width grip.\n• Pull the bar toward the upper chest.\n• Allow a full stretch at the top.\n\nKey cue: Drive elbows downward.',
              'mediaUrl': 'https://youtu.be/JGeRYIZdojU?si=6WKXH-t6Lm52nDs2'
            },
            {
              'name': '8. Barbell Curl',
              'sets': '3x10-12',
              'desc': 'Form:\n• Keep elbows pinned to your sides.\n• Curl smoothly without body swing.\n• Control the lowering phase.\n\nKey cue: Don\'t let shoulders help the movement.',
              'mediaUrl': 'https://youtu.be/jnfveKq1i3E?si=ikVYBevFk9LeWjhI'
            },
            {
              'name': '9. Rope Pushdown',
              'sets': '3x10-12',
              'desc': 'Form:\n• Keep elbows fixed beside your body.\n• Push rope down and separate the ends.\n• Return slowly.\n\nKey cue: Full lockout and squeeze.',
              'mediaUrl': 'https://youtu.be/JDEDaZTEzGE?si=T_S4Sb3XlfHml3WG'
            },
          ],
        };
      } else if (title.contains('lower')) {
        return {
          'Primary Compounds': [
            {
              'name': '1. Front Squat',
              'sets': '4x6-8',
              'desc': 'Form:\n• Rest the bar across the front of your shoulders (front rack position).\n• Keep elbows high throughout the movement.\n• Descend until thighs are at least parallel.\n\nKey cue: Keep chest tall and elbows pointed forward.',
              'mediaUrl': 'https://youtu.be/uYumuL_G_V0?si=PbJJX6ojK6V9ybxS'
            },
            {
              'name': '2. Romanian Deadlift (RDL)',
              'sets': '4x8-10',
              'desc': 'Form:\n• Slight bend in knees.\n• Push hips backward while keeping spine neutral.\n• Lower until hamstrings are fully stretched.\n\nKey cue: Stretch the hamstrings, don\'t squat the weight down.',
              'mediaUrl': 'https://youtu.be/7j-2w4-P14I?si=mc0p8JbFpzCBsO5L'
            },
          ],
          'Quad Builder & Unilateral Work': [
            {
              'name': '3. Hack Squat',
              'sets': '4x10-12',
              'desc': 'Form:\n• Keep back fully against the pad.\n• Lower as deep as mobility allows.\n• Push through the middle of your foot.\n\nKey cue: Let knees travel forward naturally.',
              'mediaUrl': 'https://youtu.be/rYgNArpwE7E?si=wJjMRJHomDLrHfLC'
            },
            {
              'name': '4. Walking Lunges',
              'sets': '3x20 steps',
              'desc': 'Form:\n• Take long controlled strides.\n• Lower until both knees approach 90°.\n• Push through the front heel.\n\nKey cue: Stay upright and controlled.',
              'mediaUrl': 'https://youtube.com/shorts/P5W2mvm1aGE?si=oG-40fHBKFD6dLR_'
            },
          ],
          'Isolation Work & Glute Finisher': [
            {
              'name': '5. Leg Curl',
              'sets': '3x12-15',
              'desc': 'Form:\n• Keep hips firmly on the pad.\n• Curl heels toward glutes.\n• Lower slowly.\n\nKey cue: Full stretch at the bottom.',
              'mediaUrl': 'https://youtu.be/t9sTSr-JYSs?si=qE5wE1SW2eew4bJk'
            },
            {
              'name': '6. Leg Extension',
              'sets': '3x12-15',
              'desc': 'Form:\n• Extend knees fully.\n• Pause at the top.\n• Lower under control.\n\nKey cue: Squeeze quads hard at lockout.',
              'mediaUrl': 'https://youtube.com/shorts/uM86QE59Tgc?si=UjbuOXFIFHaELsas'
            },
            {
              'name': '7. Hip Thrust',
              'sets': '4x8-12',
              'desc': 'Form:\n• Upper back on bench.\n• Chin tucked.\n• Drive hips upward until body forms a straight line.\n\nKey cue: Squeeze glutes hard at the top.',
              'mediaUrl': 'https://youtu.be/pUdIL5x0fWg?si=XNyF-8MflkIDjUVL'
            },
          ],
          'Calves': [
            {
              'name': '8. Standing Calf Raise',
              'sets': '4x12-15',
              'desc': 'Form:\n• Lower heels fully.\n• Rise onto toes as high as possible.\n• Pause briefly at the top.\n\nKey cue: Full range every rep.',
              'mediaUrl': 'https://youtu.be/k8ipHzKeAkQ?si=iDOSs1OeLVXRDW_w'
            },
            {
              'name': '9. Seated Calf Raise',
              'sets': '3x15-20',
              'desc': 'Form:\n• Stretch deeply at the bottom.\n• Raise weight slowly.\n• Pause at peak contraction.\n\nKey cue: No bouncing.',
              'mediaUrl': 'https://youtu.be/3ZRe_QpvRPg?si=PNzjdoFBUoeSTHbW'
            },
          ],
        };
      }
    } else {
      // Home Mode
      if (title.contains('push')) {
        return {
          'Chest': [
            {
              'name': '1. Standard Push-Ups',
              'sets': '3x12',
              'desc': 'Targets: Middle chest, shoulders, triceps.\nHow to: Place hands slightly wider than shoulder width. Keep body straight. Lower until chest nearly touches floor.',
              'mediaUrl': 'https://youtu.be/WDIpL0pjun0?si=KpzSLB-zNCoy_AD5'
            },
            {'name': '2. Wide Push-Ups', 'sets': '3x15', 'desc': 'Targets: Outer chest.\nHow to: Place hands much wider than shoulders. Lower slowly. Push up explosively.', 'mediaUrl': 'https://youtu.be/EsIdzx1J0iA?si=Ckj1es0BJQUrH6J1'},
            {'name': '3. Diamond Push-Ups', 'sets': '3x12', 'desc': 'Targets: Inner chest and triceps.\nHow to: Form a diamond shape with thumbs and index fingers. Keep elbows close.', 'mediaUrl': 'https://youtu.be/XtU2VQVuLYs?si=MGjTmQs6gZOTubjB'},
            {'name': '4. Incline Push-Ups', 'sets': '3x20', 'desc': 'Targets: Lower chest.\nHow to: Place hands on a bed, sofa, or table. Perform regular push-ups.', 'mediaUrl': 'https://youtu.be/yAbg3_pJKvw?si=l874VfXfXhEsHefd'},
            {'name': '5. Decline Push-Ups', 'sets': '3x15', 'desc': 'Targets: Upper chest.\nHow to: Put feet on a chair or bed. Hands on floor. Lower and push up.', 'mediaUrl': 'https://youtu.be/QBlYp-EwHlo?si=i0kux0FnuslZ1YGn'},
            {'name': '6. Archer Push-Ups', 'sets': '3x10', 'desc': 'Targets: One side of chest at a time.\nHow to: Take a very wide push-up position. Shift body weight to one side. Alternate sides.', 'mediaUrl': 'https://youtu.be/25t7UBYCMbE?si=6uVB7Gz3LL8Bz8Zy'},
            {'name': '7. Explosive Push-Ups', 'sets': '3x10', 'desc': 'Targets: Power and muscle activation.\nHow to: Push up forcefully. Hands leave the ground slightly.', 'mediaUrl': 'https://youtu.be/otkRQCfK-Qc?si=wzDRq4XJCYVoInTG'},
            {'name': '8. Clap Push-Ups', 'sets': '3x8', 'desc': 'Targets: Explosive chest strength.\nHow to: Push explosively. Clap before landing.', 'mediaUrl': 'https://youtu.be/Z9psWZT0WuQ?si=d7yPp6KwwYuX8hyd'},
            {'name': '9. Pseudo Planche Push-Ups', 'sets': '3x12', 'desc': 'Targets: Upper chest and shoulders.\nHow to: Place hands near your waist. Lean body forward. Perform push-ups.', 'mediaUrl': 'https://youtu.be/Cdmg0CfMZeo?si=B5JZqrsydkuGysAf'},
            {'name': '10. Hindu Push-Ups', 'sets': '3x15', 'desc': 'Targets: Entire chest and shoulders.\nHow to: Start in downward dog position. Sweep chest forward. Return to starting position.', 'mediaUrl': 'https://youtu.be/HE0ijmUc6Og?si=FU30VwSVOal41QoY'},
            {'name': '11. Spiderman Push-Ups', 'sets': '3x12', 'desc': 'Targets: Chest, core, shoulders.\nHow to: During descent bring one knee toward elbow. Alternate sides.', 'mediaUrl': 'https://youtu.be/qG2oWGqXSdw?si=M_tThXW11Clfd1yW'},
            {'name': '12. T Push-Ups', 'sets': '3x12', 'desc': 'Targets: Chest and core.\nHow to: Perform a push-up. Rotate body into a side plank. Alternate sides.', 'mediaUrl': 'https://youtu.be/eFu-R8TIF_w?si=3ERKq55TXxg4U_nU'},
            {'name': '13. Slow Tempo Push-Ups', 'sets': '3x12', 'desc': 'Targets: Muscle growth.\nHow to: 3 seconds down, 1 second pause, Push up normally.', 'mediaUrl': 'https://youtu.be/1rAKHS13yTs?si=8R6_OhVqme2ghpbe'},
            {'name': '14. Pause Push-Ups', 'sets': '3x12', 'desc': 'Targets: Strength.\nHow to: Lower down. Hold 2-3 seconds at bottom. Push up.', 'mediaUrl': 'https://youtu.be/Eg2zalDsApQ?si=_sqIR01KR-1FO-F3'},
            {'name': '15. Chest Squeeze Push-Ups', 'sets': '3x15', 'desc': 'Targets: Inner chest.\nHow to: Keep hands slightly closer than normal. Imagine squeezing your hands toward each other.', 'mediaUrl': 'https://youtu.be/TYW1VHgJexo?si=F3ayjD7dnCfVQaea'},
          ],
          'Tricep': [
            {
              'name': '1. Chair/Bench Dips ⭐',
              'sets': '3-4x12-20',
              'desc': 'Targets: All tricep heads.\nHow to: Sit on the edge of a chair or bed. Place hands beside hips. Move forward off edge. Lower until elbows reach about 90°.',
              'mediaUrl': 'https://youtu.be/larQGD02ndE?si=f9aS7kpBfTCugHC'
            },
            {
              'name': '2. Bodyweight Tricep Extensions ⭐',
              'sets': '3-4x10-15',
              'desc': 'Targets: Long head.\nHow to: Stand facing a wall. Place hands shoulder-width apart. Bend only at the elbows. Bring forehead toward hands. Extend elbows.',
              'mediaUrl': 'https://youtu.be/4UXZtR-rIoY?si=Scv0rzaXkjgrlvBI'
            },
            {
              'name': '3. Pike Tricep Extensions',
              'sets': '3x8-12',
              'desc': 'Targets: Long and medial head.\nHow to: Get into a pike position. Bend elbows and lower your head between your hands. Push back up.',
              'mediaUrl': 'https://youtu.be/pX9uYLXwyZc?si=kB_d7fUh7AksIhjH'
            },
            {
              'name': '4. Tiger Bend Push-Ups',
              'sets': '3x5-10',
              'desc': 'Targets: Strength and size.\nHow to: Start on forearms. Push up onto your palms. Lower back to forearms.',
              'mediaUrl': 'https://youtu.be/71XcAgEGQzY?si=AuIgxay4R9cqB4Wy'
            },
            {
              'name': '5. Bench Dip Hold',
              'sets': '3x20-40s',
              'desc': 'Targets: Tricep endurance.\nHow to: Hold the bottom position of a dip. Keep elbows bent around 90°.',
              'mediaUrl': 'https://youtu.be/zvrEUXmdwWw?si=V4YVH6HC8D9kZLzu'
            },
            {
              'name': '6. Slow Tempo Bench Dips',
              'sets': '3x10-15',
              'desc': 'Targets: Hypertrophy.\nHow to: 4 seconds down, 1 second pause, Explode up.',
              'mediaUrl': 'https://youtu.be/jsJPaUC1ZVw?si=mUuVY7x5LRtJv3dy'
            },
            {
              'name': '7. Single-Leg Bench Dips',
              'sets': '3x8-12',
              'desc': 'Targets: Increased load.\nHow to: Perform regular dips. Raise one leg off the floor.',
              'mediaUrl': 'https://youtu.be/aY1eSr21qY8?si=5EgKE81FQlVwNi6b'
            },
          ],
          'Shoulder': [
            {
              'name': '1. Pike Push-Ups ⭐',
              'sets': '4x8-15',
              'desc': 'Targets: Front and side delts.\nHow to: Form an inverted V shape. Keep hips high. Lower head toward the floor. Push back up.',
              'mediaUrl': 'https://youtu.be/x7_I5SUAd00?si=TwAn8ISzXYTNbqJT'
            },
            {
              'name': '2. Elevated Pike Push-Ups',
              'sets': '3-4x6-12',
              'desc': 'Targets: Front delts.\nHow to: Put feet on a chair or bed. Maintain pike position. Lower head toward floor. Push up.',
              'mediaUrl': 'https://youtu.be/8URA3YSur2M?si=XDb7cO5wpic55efb'
            },
            {
              'name': '3. Wall Walks',
              'sets': '3x5-8',
              'desc': 'Targets: Entire shoulder complex.\nHow to: Start in a push-up position. Walk feet up a wall. Walk hands toward wall. Hold and return.',
              'mediaUrl': 'https://youtu.be/2v-yninc1ww?si=lN-iAWbLjQq6S7TL'
            },
            {
              'name': '4. Handstand Hold Against Wall ⭐',
              'sets': '3x20-60s',
              'desc': 'Targets: Shoulder stability.\nHow to: Kick up against a wall. Keep arms locked. Hold position.',
              'mediaUrl': 'https://youtu.be/W3ESRgMORXw?si=AFQek_tjsSHeVcf3'
            },
            {
              'name': '5. Handstand Push-Up Negatives',
              'sets': '3x3-8',
              'desc': 'Targets: Advanced shoulder development.\nHow to: Get into wall handstand. Slowly lower yourself. Come down safely.',
              'mediaUrl': 'https://youtu.be/RKlbLQVEYyA?si=I9Y-QbUELC4V5oWx'
            },
            {
              'name': '6. Arm Circles',
              'sets': '3x30-60s',
              'desc': 'Targets: Side and rear delts.\nHow to: Extend arms straight out. Make small forward circles. Reverse direction.',
              'mediaUrl': 'https://youtu.be/3STTSi_jdHk?si=of7YvWRtCdazTA1q'
            },
            {
              'name': '7. Reverse Snow Angels',
              'sets': '3x12-20',
              'desc': 'Targets: Rear delts.\nHow to: Lie face down. Lift arms slightly. Move arms in a snow angel motion.',
              'mediaUrl': 'https://youtu.be/0qLP2RNKX4A?si=CgR2if-YyDi6yqMt'
            },
            {
              'name': '8. Y-T-W Raises',
              'sets': '3x10-15',
              'desc': 'Targets: Rear delts and upper back.\nHow to: Lie face down. Form Y, T, and W shapes with your arms. Squeeze shoulder blades.',
              'mediaUrl': 'https://youtu.be/QdGTI4Lshg4?si=mN4H8QdeiVNMAZ2J'
            },
            {
              'name': '9. Wall Shoulder Taps',
              'sets': '3x10-20',
              'desc': 'Targets: Shoulder stability.\nHow to: Face wall in a handstand lean. Alternate tapping shoulders.',
              'mediaUrl': 'https://youtu.be/UZACF8kEq-c?si=ujVJ448oe9JWk-1W'
            },
            {
              'name': '10. Isometric Lateral Raise Hold',
              'sets': '3x30-60s',
              'desc': 'Targets: Side delts.\nHow to: Extend arms sideways. Hold parallel to the floor.',
              'mediaUrl': 'https://youtube.com/shorts/waolkh7XiHA?si=9Xkj2ZM6meJp7Uz9'
            },
          ],
        };
      } else if (title.contains('pull')) {
        return {
          'Back': [
            {'name': '1. Superman Hold ⭐', 'sets': '3-4x20-45s', 'desc': 'Targets: Lower/upper back, rear delts.\nHow to: Lie face down. Lift arms, chest, and legs. Squeeze back.', 'mediaUrl': 'https://youtu.be/g0Kr9Wd3CeQ?si=u3QkgplzETqedhGm'},
            {'name': '2. Superman Raises', 'sets': '3x15-20', 'desc': 'Targets: Entire posterior chain.\nHow to: Lie face down. Lift chest and legs. Lower slowly.', 'mediaUrl': 'https://youtu.be/z6PJMT2y8GQ?si=kMB0A2lYOPsqeQn2'},
            {'name': '3. Reverse Snow Angels ⭐', 'sets': '3x15-20', 'desc': 'Targets: Upper back, rear delts, traps.\nHow to: Lie face down. Sweep arms from overhead to sides.', 'mediaUrl': 'https://youtu.be/lpuBsbcQMzQ?si=NrJBfTz8tFqeIPln'},
            {'name': '4. Y-T-W Raises ⭐', 'sets': '3x10-15', 'desc': 'Targets: Upper back and rear delts.\nHow to: Lie face down. Form Y, T, and W positions. Squeeze.', 'mediaUrl': 'https://youtu.be/QdGTI4Lshg4?si=b5UJwPTMM-M68oPo'},
            {'name': '5. Prone Cobra Hold', 'sets': '3x20-40s', 'desc': 'Targets: Rhomboids, traps, rear delts.\nHow to: Lie face down. Lift chest. Pull elbows back.', 'mediaUrl': 'https://youtu.be/YhtUM6KYIGY?si=r7zLwYiDC8IyHc62'},
            {'name': '6. Swimmers', 'sets': '3x30-45s', 'desc': 'Targets: Entire back.\nHow to: Lie face down. Alternate lifting opposite arm and leg.', 'mediaUrl': 'https://youtu.be/YzqmjH2O68o?si=5VyR8Auk4lzxJwEf'},
            {'name': '7. Wall Lat Pushdowns', 'sets': '3x15-20', 'desc': 'Targets: Lats.\nHow to: Stand facing a wall. Push elbows downward while squeezing lats.', 'mediaUrl': 'https://youtu.be/taOVTXUjFHs?si=JHCd_wO41bf1Vk0q'},
            {'name': '8. Floor Lat Slides', 'sets': '3x12-15', 'desc': 'Targets: Lats and upper back.\nHow to: Lie face down. Pull elbows toward ribs.', 'mediaUrl': 'https://youtu.be/q3mPrNeYwg8?si=5ZJTYkUnAd5pt7-u'},
            {'name': '9. Back Widows', 'sets': '3x12-20', 'desc': 'Targets: Upper back and traps.\nHow to: Lie on back. Drive bent elbows into the floor to lift upper body.', 'mediaUrl': 'https://youtu.be/u2YnCHLRkUQ?si=fh2Sqm-hmCq464yH'},
            {'name': '10. Isometric Lat Squeeze', 'sets': '3x30s', 'desc': 'Targets: Lats.\nHow to: Stand upright. Pull elbows toward sides and squeeze.', 'mediaUrl': 'https://youtube.com/shorts/Pb4UGyoaugY?si=UvhcNcW0Z9gRDfe2'},
          ],
          'Biceps': [
            {'name': '1. Self-Resistance Bicep Curl ⭐', 'sets': '4x12-15/arm', 'desc': 'Targets: Entire bicep.\nHow to: Use opposite hand to provide resistance while curling.', 'mediaUrl': 'https://youtu.be/PwBOPb13BfE?si=6bCqLP1pFmEPjLSS'},
            {'name': '2. Isometric Bicep Hold ⭐', 'sets': '3x20-40s', 'desc': 'Targets: Bicep endurance/strength.\nHow to: Bend elbow to 90°. Resist with opposite hand.', 'mediaUrl': 'https://youtu.be/ybHdLNYE3_A?si=dZ36uNLUJz2hLWa8'},
            {'name': '3. Towel Curl', 'sets': '4x12-15', 'desc': 'Targets: Biceps and forearms.\nHow to: Place towel under foot. Curl upward against leg resistance.', 'mediaUrl': 'https://youtu.be/crj5Zqwbz1A?si=f_RZW7zAY7rGW0hB'},
            {'name': '4. Towel Isometric Curl', 'sets': '3x30s', 'desc': 'Targets: Peak contraction.\nHow to: Stand on towel. Pull upward as hard as possible.', 'mediaUrl': 'https://youtu.be/e_cYNEaDZeg?si=BzILLBX82YeupWBj'},
            {'name': '5. Doorframe Curls', 'sets': '3x8-15', 'desc': 'Targets: Biceps.\nHow to: Grip doorframe. Lean back. Pull yourself toward frame.', 'mediaUrl': 'https://youtu.be/O0yRsKx8lG8?si=o9LHGxoG_BYKpgCE'},
            {'name': '6. Doorway Rows', 'sets': '4x10-15', 'desc': 'Targets: Biceps and upper back.\nHow to: Hold doorway. Lean backward. Pull body forward.', 'mediaUrl': 'https://youtu.be/laxlC3wq6sU?si=DOZnWI8jaq3ChjYW'},
            {'name': '7. Backpack Curls', 'sets': '4x10-15', 'desc': 'Targets: Entire bicep.\nHow to: Fill backpack with books. Perform curls.', 'mediaUrl': 'https://youtu.be/dKqtGGScQhQ?si=gJWhejo6W2FuMDT4'},
            {'name': '8. Backpack Hammer Curls', 'sets': '4x10-15', 'desc': 'Targets: Brachialis and forearms.\nHow to: Hold backpack neutrally and curl.', 'mediaUrl': 'https://youtu.be/gkcHcTqQYy4?si=Rv7NucGfjFNE7rmt'},
            {'name': '9. Chin-Up Negatives', 'sets': '3x5-8', 'desc': 'Targets: Biceps and back.\nHow to: Jump to top of chin-up bar. Lower slowly.', 'mediaUrl': 'https://youtu.be/Dx740NIKX94?si=JnFvLohitPyRbwex'},
            {'name': '10. Isometric Chin-Up Hold', 'sets': '3x10-30s', 'desc': 'Targets: Bicep strength.\nHow to: Hold top position of chin-up.', 'mediaUrl': 'https://youtu.be/0i5GO5IhxQA?si=sz_SnTOtgCMpIXAC'},
          ],
        };
      } else if (title.contains('leg')) {
        return {
          'Quads': [
            {'name': '1. Bodyweight Squats ⭐', 'sets': '4x15-25', 'desc': 'Targets: Quads, glutes.\nHow to: Push hips back. Lower until thighs are parallel.', 'mediaUrl': 'https://youtu.be/m0GcZ24pK6k?si=EG_85WS8buYBEksV'},
            {'name': '2. Bulgarian Split Squats ⭐', 'sets': '3-4x10-15/leg', 'desc': 'Targets: Quads, glutes.\nHow to: Place one foot on a chair behind you. Lower body.', 'mediaUrl': 'https://youtu.be/vgn7bSXkgkA?si=0VuGScwUyfLqWbS'},
            {'name': '3. Walking Lunges', 'sets': '3x12-15/leg', 'desc': 'Targets: Quads, glutes.\nHow to: Take a long step forward. Lower both knees. Alternate.', 'mediaUrl': 'https://youtu.be/tQNktxPkSeE?si=NzEVrFjKDxHzzDCS'},
            {'name': '5. Jump Squats', 'sets': '3x10-15', 'desc': 'Targets: Power, quads.\nHow to: Perform a squat and explode upward.', 'mediaUrl': 'https://youtu.be/5xv0DKqe5XQ?si=V1Sl_XQnIVlvnDN4'},
            {'name': '6. Wall Sit ⭐', 'sets': '3x30-60s', 'desc': 'Targets: Quad endurance.\nHow to: Lean against a wall with knees at 90°.', 'mediaUrl': 'https://youtu.be/cWTZ8Am1Ee0?si=dmcMM8e9RxqVWpit'},
            {'name': '9. Step-Ups', 'sets': '3x12-15/leg', 'desc': 'Targets: Quads, glutes.\nHow to: Step up onto a sturdy chair or stairs.', 'mediaUrl': 'https://youtu.be/9ZknEYboBOQ?si=pIQyj1m4agIzdqML'},
            {'name': '12. Sumo Squats', 'sets': '3x15-20', 'desc': 'Targets: Inner thighs, glutes.\nHow to: Take a wide stance, toes out, and squat.', 'mediaUrl': 'https://youtu.be/6L7KFAN5MCE?si=31NxeR6uWgePjMdo'},
            {'name': '13. Cossack Squats', 'sets': '3x8-12/side', 'desc': 'Targets: Mobility, adductors.\nHow to: Very wide stance. Shift weight to one side.', 'mediaUrl': 'https://youtu.be/dhDjKmTX8tU?si=Efp1AxLJPibrv9nv'},
            {'name': '14. Single-Leg Squats (Pistol)', 'sets': '3x5-10/leg', 'desc': 'Targets: Entire leg.\nHow to: Balance on one leg. Squat as low as possible.', 'mediaUrl': 'https://youtu.be/ams6zp1kBcE?si=UwLOkNsgGw5BRlmd'},
          ],
          'Hamstrings & Glutes': [
            {'name': '4. Reverse Lunges', 'sets': '3x12/leg', 'desc': 'Targets: Glutes, hamstrings.\nHow to: Step backward into a lunge.', 'mediaUrl': 'https://youtu.be/5frs7_F2SrU?si=MslksLXz-yox8Eb-'},
            {'name': '7. Glute Bridges', 'sets': '4x15-20', 'desc': 'Targets: Glutes, hamstrings.\nHow to: Lie on back. Push hips upward and squeeze glutes.', 'mediaUrl': 'https://youtu.be/Xp33YgPZgns?si=CPmCILGEr5XXpGSJ'},
            {'name': '8. Single-Leg Glute Bridges', 'sets': '3x10-12/leg', 'desc': 'Targets: Glutes, hamstrings.\nHow to: Extend one leg and perform glute bridge.', 'mediaUrl': 'https://youtu.be/vdmlNaXSjd4?si=8TLURS0LTwOnCdGY'},
            {'name': '15. Hamstring Walkouts ⭐', 'sets': '3x8-12', 'desc': 'Targets: Hamstrings.\nHow to: Start in glute bridge. Slowly walk feet outward and back in.', 'mediaUrl': 'https://youtu.be/Lv89iHuzPW4?si=AACNPsPPx4j7g6vW'},
          ],
          'Calves': [
            {'name': '10. Calf Raises ⭐', 'sets': '4x20-30', 'desc': 'Targets: Calves.\nHow to: Rise onto toes. Pause at top. Lower slowly.', 'mediaUrl': 'https://youtu.be/c5Kv6-fnTj8?si=lDLK882Kj1564hBk'},
            {'name': '11. Single-Leg Calf Raises', 'sets': '3x15-20/leg', 'desc': 'Targets: Calves.\nHow to: Balance on one leg and raise heel high.', 'mediaUrl': 'https://youtu.be/qPd73snQfUs?si=oFn2iNsovtGzdXPy'},
          ],
        };
      } else if (title.contains('shoulder')) {
        return {
          'Shoulder': [
            {'name': '1. Pike Push-Ups ⭐', 'sets': '4x8-15', 'desc': 'Targets: Front and side delts.\nHow to: Form an inverted V shape. Keep hips high. Lower head toward the floor. Push back up.', 'mediaUrl': 'https://youtu.be/x7_I5SUAd00?si=TwAn8ISzXYTNbqJT'},
            {'name': '2. Elevated Pike Push-Ups', 'sets': '3-4x6-12', 'desc': 'Targets: Front delts.\nHow to: Put feet on a chair or bed. Maintain pike position. Lower head toward floor. Push up.', 'mediaUrl': 'https://youtu.be/8URA3YSur2M?si=XDb7cO5wpic55efb'},
            {'name': '3. Wall Walks', 'sets': '3x5-8', 'desc': 'Targets: Entire shoulder complex.\nHow to: Start in a push-up position. Walk feet up a wall. Walk hands toward wall. Hold and return.', 'mediaUrl': 'https://youtu.be/2v-yninc1ww?si=lN-iAWbLjQq6S7TL'},
            {'name': '4. Handstand Hold Against Wall ⭐', 'sets': '3x20-60s', 'desc': 'Targets: Shoulder stability.\nHow to: Kick up against a wall. Keep arms locked. Hold position.', 'mediaUrl': 'https://youtu.be/W3ESRgMORXw?si=AFQek_tjsSHeVcf3'},
            {'name': '5. Handstand Push-Up Negatives', 'sets': '3x3-8', 'desc': 'Targets: Advanced shoulder development.\nHow to: Get into wall handstand. Slowly lower yourself. Come down safely.', 'mediaUrl': 'https://youtu.be/RKlbLQVEYyA?si=I9Y-QbUELC4V5oWx'},
            {'name': '6. Arm Circles', 'sets': '3x30-60s', 'desc': 'Targets: Side and rear delts.\nHow to: Extend arms straight out. Make small forward circles. Reverse direction.', 'mediaUrl': 'https://youtu.be/3STTSi_jdHk?si=of7YvWRtCdazTA1q'},
            {'name': '7. Reverse Snow Angels', 'sets': '3x12-20', 'desc': 'Targets: Rear delts.\nHow to: Lie face down. Lift arms slightly. Move arms in a snow angel motion.', 'mediaUrl': 'https://youtu.be/0qLP2RNKX4A?si=CgR2if-YyDi6yqMt'},
            {'name': '8. Y-T-W Raises', 'sets': '3x10-15', 'desc': 'Targets: Rear delts and upper back.\nHow to: Lie face down. Form Y, T, and W shapes with your arms. Squeeze shoulder blades.', 'mediaUrl': 'https://youtu.be/QdGTI4Lshg4?si=mN4H8QdeiVNMAZ2J'},
            {'name': '9. Wall Shoulder Taps', 'sets': '3x10-20', 'desc': 'Targets: Shoulder stability.\nHow to: Face wall in a handstand lean. Alternate tapping shoulders.', 'mediaUrl': 'https://youtu.be/UZACF8kEq-c?si=ujVJ448oe9JWk-1W'},
            {'name': '10. Isometric Lateral Raise Hold', 'sets': '3x30-60s', 'desc': 'Targets: Side delts.\nHow to: Extend arms sideways. Hold parallel to the floor.', 'mediaUrl': 'https://youtube.com/shorts/waolkh7XiHA?si=9Xkj2ZM6meJp7Uz9'},
          ],
          'Biceps': [
            {'name': '1. Self-Resistance Bicep Curls ⭐', 'sets': '4x12-15/arm', 'desc': 'Targets: Biceps.\nHow to: Use opposite hand to provide resistance while curling.', 'mediaUrl': 'https://youtu.be/PwBOPb13BfE?si=7_JEq5ZVLmEIqdN6'},
            {'name': '2. Towel Curls ⭐', 'sets': '4x12-15', 'desc': 'Targets: Biceps and forearms.\nHow to: Place towel under foot and curl upward.', 'mediaUrl': 'https://youtu.be/crj5Zqwbz1A?si=1Mr63V03WTNOdl62'},
            {'name': '3. Doorframe Curls', 'sets': '3x10-15', 'desc': 'Targets: Biceps.\nHow to: Grip doorframe and pull body towards it.', 'mediaUrl': 'https://youtu.be/O0yRsKx8lG8?si=L7Hztx0Nf4JKP0MH'},
            {'name': '4. Isometric Bicep Hold', 'sets': '3x30s', 'desc': 'Targets: Bicep strength and endurance.\nHow to: Bend elbow to 90° and resist with opposite hand.', 'mediaUrl': 'https://youtu.be/ybHdLNYE3_A?si=8weioUdB7wMDcZjA'},
          ],
          'Triceps': [
            {'name': '5. Chair Dips ⭐', 'sets': '4x12-20', 'desc': 'Targets: Entire triceps.\nHow to: Sit on edge of chair. Lower body until elbows are 90°.', 'mediaUrl': 'https://youtu.be/HCf97NPYeGY?si=pRTlnMdPDMMPsvfB'},
            {'name': '6. Bodyweight Tricep Extensions ⭐', 'sets': '4x10-15', 'desc': 'Targets: Long head of triceps.\nHow to: Stand facing wall. Bend elbows and bring forehead toward hands.', 'mediaUrl': 'https://youtu.be/MYw-v1WQgEk?si=JwX_fjGdKetYxwOG'},
            {'name': '7. Pike Tricep Extensions', 'sets': '3x8-12', 'desc': 'Targets: Long and medial head.\nHow to: Get into pike position. Lower head between hands.', 'mediaUrl': 'https://youtu.be/pX9uYLXwyZc?si=arINSS0NOgOOJO5m'},
            {'name': '8. Bench Dip Hold', 'sets': '3x30s', 'desc': 'Targets: Tricep endurance.\nHow to: Hold bottom position of a dip.', 'mediaUrl': 'https://youtu.be/zvrEUXmdwWw?si=5fz0PAOaJ5RMMlgt'},
          ],
          'Forearms': [
            {'name': '9. Towel Twist', 'sets': '3x30s', 'desc': 'Targets: Forearms and grip.\nHow to: Hold towel with both hands. Twist as hard as possible.', 'mediaUrl': 'https://youtu.be/8N-fMQk90ao?si=xrjXv2s8nL2VSTvH'},
            {'name': '10. Fingertip Hold', 'sets': '3x15-30s', 'desc': 'Targets: Finger and forearm strength.\nHow to: Hold a plank position on fingertips.', 'mediaUrl': 'https://youtu.be/_DHM9Zg_0iY?si=-83sWp_JWFWdhxQD'},
            {'name': '11. Wrist Flexion Isometric', 'sets': '3x20s', 'desc': 'Targets: Forearms.\nHow to: Use one hand to resist the other wrist curling.', 'mediaUrl': 'https://youtu.be/9vghUUnFQVc?si=6sCpJogIYI6FKGWb'},
          ],
        };
      } else if (title.contains('upper')) {
        return {
          'Chest & Back': [
            {'name': 'Pushups', 'sets': '3x15', 'desc': 'Standard chest pushups.'},
            {'name': 'Doorway Rows', 'sets': '3x12', 'desc': 'Lean back and pull yourself towards the door frame.'},
          ],
          'Shoulders & Arms': [
            {'name': 'Pike Pushups', 'sets': '3x10', 'desc': 'Shoulder targeting.'},
            {'name': 'Chair Dips', 'sets': '3x12', 'desc': 'Tricep targeting.'},
          ],
        };
      } else if (title.contains('lower')) {
        return {
          'Quads': [
            {'name': 'Jump Squats', 'sets': '3x15', 'desc': 'Explosive bodyweight squats.'},
          ],
          'Posterior Chain': [
            {'name': 'Reverse Lunges', 'sets': '3x12/leg', 'desc': 'Step backward into a lunge instead of forward.'},
            {'name': 'Glute Bridges', 'sets': '3x15', 'desc': 'Squeeze glutes at the top.'},
            {'name': 'Calf Raises', 'sets': '3x20', 'desc': 'Raise onto your toes.'},
          ],
        };
      }
    }
    
    // Default fallback
    return {
      'Full Body': [
        {'name': 'Burpees', 'sets': '3x10', 'desc': 'Full body explosive movement.'},
        {'name': 'Mountain Climbers', 'sets': '3x30s', 'desc': 'Drive knees to chest while in a plank.'},
        {'name': 'Plank', 'sets': '3x60s', 'desc': 'Hold a strong core position.'},
      ],
    };
  }

  Widget _buildExerciseSection(BuildContext context, String title, List<Map<String, String>> exercises, IconData icon, Color iconColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...exercises.map((ex) => Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Icon(Icons.circle, size: 8, color: AppTheme.primaryAccent),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(ex['name']!, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!, fontSize: 16)),
                          ),
                          Text(ex['sets']!, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryAccent, fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(ex['desc']!, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final warmup = _getWarmup();
    final sections = _getWorkoutSections();
    final cooldown = _getCoolDown();
    
    final modeLabel = isGymMode ? 'Gym Mode' : 'Home Mode';
    
    final allExercises = [...warmup];
    for (var list in sections.values) {
      allExercises.addAll(list);
    }
    allExercises.addAll(cooldown);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge!.color!),
        title: Text('Workout Details', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(24.0).copyWith(bottom: 120), // Leave space for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    modeLabel,
                    style: TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold),
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),
                SizedBox(height: 12),
                Text(
                  workoutTitle,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: Theme.of(context).textTheme.bodyMedium!.color!),
                    SizedBox(width: 4),
                    Text('$durationMinutes min est.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!)),
                    SizedBox(width: 16),
                    Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('High Burn', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!)),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                SizedBox(height: 32),
                
                _buildExerciseSection(context, 'Warm-Up', warmup, Icons.whatshot, Colors.orange).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                
                ...sections.entries.map((entry) {
                  return _buildExerciseSection(context, entry.key, entry.value, Icons.fitness_center, AppTheme.primaryAccent).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
                }),
                
                _buildExerciseSection(context, 'Cool-Down', cooldown, Icons.ac_unit, Colors.blue).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              ],
            ),
          ),
          
          // Fixed Bottom Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
                    Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveWorkoutScreen(
                        workoutTitle: workoutTitle,
                        exercises: allExercises,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: AppTheme.primaryAccent.withValues(alpha: 0.5),
                ),
                child: Text(
                  'START WORKOUT',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface, letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
