import 'package:flutter/material.dart';

Map<String, Map<String, dynamic>> get7DayDietPlans(String preference) {
  final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  // Base Macro Targets per Goal
  final macros = {
    'Cutting': {'calories': '1,800 - 2,000 kcal', 'protein': '160g', 'carbs': '150g', 'fats': '55g'},
    'Bulking': {'calories': '3,000 - 3,300 kcal', 'protein': '180g', 'carbs': '400g', 'fats': '80g'},
    'Maintenance': {'calories': '2,400 - 2,600 kcal', 'protein': '150g', 'carbs': '250g', 'fats': '70g'},
  };

  // Menu Generators
  List<Map<String, dynamic>> generateCuttingMeals(String type) {
    if (preference == 'Vegetarian') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': 'Poha with Peanuts + 50g Low-Fat Paneer + Black Coffee', 'alternate': 'Oats Upma + 1 Cup Soy Milk', 'baseCalories': 350, 'icon': Icons.egg_alt_outlined},
        {'title': 'Lunch', 'food': '2 Roti + 1 Bowl Moong Dal + 150g Paneer Tikka + Salad', 'alternate': '1 Cup Quinoa + 1 Bowl Toor Dal + Soya Chunks', 'baseCalories': 550, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': '1 Scoop Whey Protein + Handful of Roasted Makhana', 'alternate': 'Protein Bar + Green Tea', 'baseCalories': 200, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': '1 Bowl Soya Curry + 1 Roti + Sautéed Green Beans', 'alternate': 'Tofu Salad with Vinaigrette', 'baseCalories': 400, 'icon': Icons.set_meal_outlined},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': '2 Besan Chillas + Mint Chutney + Green Tea', 'alternate': 'Moong Dal Chilla + Black Coffee', 'baseCalories': 300, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': '1 Cup Brown Rice + 1 Bowl Rajma + 100g Curd + Salad', 'alternate': '1 Cup Millet Rice + Chole Masala', 'baseCalories': 500, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Roasted Chana + Apple', 'alternate': 'Peanut Butter Rice Cake', 'baseCalories': 250, 'icon': Icons.apple},
        {'title': 'Dinner', 'food': 'Grilled Tofu Salad with Lemon Dressing', 'alternate': 'Paneer Bhurji + 1 Roti', 'baseCalories': 350, 'icon': Icons.eco},
      ];
      return [
        {'title': 'Breakfast', 'food': '2 Paneer Parathas + 100g Curd', 'alternate': 'Aloo Paratha + Raita', 'baseCalories': 500, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Veg Dum Biryani (1.5 Cups) + Raita', 'alternate': 'Veg Pulao + Soy Chunks', 'baseCalories': 600, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Fruit Bowl + 1 Scoop Whey Protein', 'alternate': 'Protein Smoothie', 'baseCalories': 300, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Light Dal Soup + Sautéed Veggies', 'alternate': 'Tomato Soup + Salad', 'baseCalories': 250, 'icon': Icons.soup_kitchen},
      ];
    } else if (preference == 'Vegan') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': 'Poha with Peanuts + Tofu Scramble + Black Coffee', 'alternate': 'Oatmeal with Almond Milk', 'baseCalories': 350, 'icon': Icons.egg_alt_outlined},
        {'title': 'Lunch', 'food': '2 Roti + 1 Bowl Moong Dal + 150g Soya Chunks + Salad', 'alternate': 'Quinoa + Lentils', 'baseCalories': 550, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': '1 Scoop Vegan Protein + Handful of Roasted Makhana', 'alternate': 'Vegan Protein Bar', 'baseCalories': 200, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Grilled Tofu Salad + Sautéed Green Beans', 'alternate': 'Tempeh Stir-fry', 'baseCalories': 400, 'icon': Icons.set_meal_outlined},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Oatmeal with Soy Milk + Berries', 'alternate': 'Vegan Smoothie Bowl', 'baseCalories': 300, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '1 Cup Brown Rice + 1 Bowl Chana Masala + Spinach', 'alternate': 'Millet + Black Beans', 'baseCalories': 500, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Roasted Chana + Banana', 'alternate': 'Apple + Almond Butter', 'baseCalories': 250, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': 'Soya Keema + 1 Roti', 'alternate': 'Tofu Bhurji', 'baseCalories': 350, 'icon': Icons.dinner_dining},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Vegan Pancakes with Maple Syrup', 'alternate': 'Vegan Waffles', 'baseCalories': 500, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Soya Chunks Biryani + Cucumber Salad', 'alternate': 'Vegan Pulao', 'baseCalories': 600, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Fruit Bowl + Vegan Protein Shake', 'alternate': 'Vegan Protein Cookie', 'baseCalories': 300, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Tomato Soup + Sautéed Mushrooms', 'alternate': 'Lentil Soup', 'baseCalories': 250, 'icon': Icons.soup_kitchen},
      ];
    } else if (preference == 'Lactose Intolerant') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': 'Poha with Peanuts + 3 Boiled Egg Whites + Black Coffee', 'alternate': 'Oats + Eggs', 'baseCalories': 350, 'icon': Icons.egg_alt_outlined},
        {'title': 'Lunch', 'food': '2 Roti + 1 Bowl Moong Dal + 150g Grilled Chicken + Salad', 'alternate': 'Brown Rice + Chicken Breast', 'baseCalories': 550, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': '1 Scoop Clear Whey Protein + Roasted Makhana', 'alternate': 'Tuna + Rice Cakes', 'baseCalories': 200, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': '1 Bowl Fish Curry + 1 Roti + Sautéed Green Beans', 'alternate': 'Grilled Fish Salad', 'baseCalories': 400, 'icon': Icons.set_meal_outlined},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': '3 Scrambled Eggs + 2 Slices Brown Bread', 'alternate': 'Egg White Omelette + Toast', 'baseCalories': 300, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '1 Cup Brown Rice + 1 Bowl Rajma + Chicken Tikka', 'alternate': 'Millet + Soya Chunks', 'baseCalories': 500, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Roasted Chana + Apple', 'alternate': 'Peanut Butter Toast', 'baseCalories': 250, 'icon': Icons.apple},
        {'title': 'Dinner', 'food': 'Grilled Chicken Salad with Lemon Dressing', 'alternate': 'Chicken Soup', 'baseCalories': 350, 'icon': Icons.eco},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Chicken Sausage + 2 Fried Eggs + Toast', 'alternate': 'Turkey Bacon + Eggs', 'baseCalories': 500, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Chicken Biryani (1.5 Cups) + Cucumber Salad', 'alternate': 'Chicken Pulao', 'baseCalories': 600, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Fruit Bowl + Clear Whey Isolate', 'alternate': 'Protein Bar', 'baseCalories': 300, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Clear Chicken Soup + Sautéed Veggies', 'alternate': 'Bone Broth + Veggies', 'baseCalories': 250, 'icon': Icons.soup_kitchen},
      ];
    } else {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': 'Poha with Peanuts + 3 Boiled Egg Whites + Black Coffee', 'alternate': 'Oats + Eggs', 'baseCalories': 350, 'icon': Icons.egg_alt_outlined},
        {'title': 'Lunch', 'food': '2 Roti + 1 Bowl Moong Dal + 150g Grilled Chicken + Salad', 'alternate': 'Brown Rice + Chicken Breast', 'baseCalories': 550, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': '1 Scoop Whey Protein + Handful of Roasted Makhana', 'alternate': 'Protein Bar', 'baseCalories': 200, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': '1 Bowl Fish Curry + 1 Roti + Sautéed Green Beans', 'alternate': 'Grilled Fish Salad', 'baseCalories': 400, 'icon': Icons.set_meal_outlined},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': '3 Scrambled Eggs + 2 Slices Brown Bread', 'alternate': 'Egg White Omelette', 'baseCalories': 300, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '1 Cup Brown Rice + 1 Bowl Rajma + 100g Curd + Chicken Tikka', 'alternate': 'Millet + Soya Chunks', 'baseCalories': 500, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Roasted Chana + Apple', 'alternate': 'Peanut Butter Toast', 'baseCalories': 250, 'icon': Icons.apple},
        {'title': 'Dinner', 'food': 'Grilled Chicken Salad with Lemon Dressing', 'alternate': 'Chicken Soup', 'baseCalories': 350, 'icon': Icons.eco},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Chicken Sausage + 2 Fried Eggs + Toast', 'alternate': 'Bacon + Eggs', 'baseCalories': 500, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Chicken Biryani (1.5 Cups) + Raita', 'alternate': 'Mutton Pulao', 'baseCalories': 600, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Fruit Bowl + Whey Protein', 'alternate': 'Protein Smoothie', 'baseCalories': 300, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Clear Chicken Soup + Sautéed Veggies', 'alternate': 'Bone Broth + Veggies', 'baseCalories': 250, 'icon': Icons.soup_kitchen},
      ];
    }
  }

  List<Map<String, dynamic>> generateBulkingMeals(String type) {
    if (preference == 'Vegetarian') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': '2 Paneer Stuffed Parathas + Banana Peanut Butter Shake', 'alternate': 'Aloo Paratha + High Calorie Shake', 'baseCalories': 800, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': '2 Cups White Rice + 1 Bowl Rajma + 200g Tofu Curry + Curd', 'alternate': '3 Roti + Paneer Butter Masala', 'baseCalories': 900, 'icon': Icons.rice_bowl},
        {'title': 'Pre-Workout', 'food': '2 Bananas + Handful of Almonds/Walnuts + Black Coffee', 'alternate': 'Oats + Dates', 'baseCalories': 400, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': '3 Ghee Rotis + Paneer Bhurji + 1 Glass Warm Milk', 'alternate': 'Soya Keema + Roti', 'baseCalories': 700, 'icon': Icons.dinner_dining},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Oatmeal with Whole Milk, Peanut Butter, Banana', 'alternate': 'Overnight Oats', 'baseCalories': 750, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '3 Roti + Mix Veg Sabzi + 200g Paneer Tikka + Lassi', 'alternate': 'Brown Rice + Chole', 'baseCalories': 850, 'icon': Icons.local_drink},
        {'title': 'Pre-Workout', 'food': 'Apple + Peanut Butter + Rice Cakes', 'alternate': 'Banana + Almond Butter', 'baseCalories': 400, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': 'Soya Chunks Pulao + Raita', 'alternate': 'Veg Biryani', 'baseCalories': 700, 'icon': Icons.rice_bowl},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Aloo Paratha (x3) with Butter + Thick Curd', 'alternate': 'Chole Bhature (Cheat)', 'baseCalories': 1000, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Paneer Biryani + Mango Lassi', 'alternate': 'Veg Pulao + Raita', 'baseCalories': 1100, 'icon': Icons.rice_bowl},
        {'title': 'Pre-Workout', 'food': 'Mass Gainer Shake + Dates', 'alternate': 'High Calorie Smoothie', 'baseCalories': 500, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Dal Makhani + 2 Naan + Paneer Butter Masala', 'alternate': 'Shahi Paneer + Roti', 'baseCalories': 900, 'icon': Icons.set_meal},
      ];
    } else if (preference == 'Vegan') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': 'Oatmeal with Soy Milk, Peanut Butter, Banana', 'alternate': 'Vegan Weight Gainer Shake', 'baseCalories': 800, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '2 Cups White Rice + 1 Bowl Rajma + 200g Soya Chunks', 'alternate': 'Quinoa + Lentils', 'baseCalories': 900, 'icon': Icons.rice_bowl},
        {'title': 'Pre-Workout', 'food': '2 Bananas + Handful of Mixed Nuts + Black Coffee', 'alternate': 'Dates + Walnuts', 'baseCalories': 400, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': '3 Rotis + Tofu Bhurji', 'alternate': 'Soya Keema + Roti', 'baseCalories': 700, 'icon': Icons.dinner_dining},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Peanut Butter & Jelly Sandwiches (x3) + Soy Milk', 'alternate': 'Almond Butter Toast', 'baseCalories': 750, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': '3 Roti + Mix Veg Sabzi + 200g Tofu Tikka', 'alternate': 'Vegan Mac and Cheese', 'baseCalories': 850, 'icon': Icons.lunch_dining},
        {'title': 'Pre-Workout', 'food': 'Apple + Peanut Butter + Rice Cakes', 'alternate': 'Banana + Peanut Butter', 'baseCalories': 400, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': 'Soya Chunks Pulao + Cucumber Salad', 'alternate': 'Vegan Biryani', 'baseCalories': 700, 'icon': Icons.rice_bowl},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Vegan Pancakes (x4) with Maple Syrup & Walnuts', 'alternate': 'Vegan Waffles', 'baseCalories': 1000, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Soya Soya Biryani + Large Fries', 'alternate': 'Vegan Burgers', 'baseCalories': 1100, 'icon': Icons.rice_bowl},
        {'title': 'Pre-Workout', 'food': 'Vegan Mass Gainer Shake + Dates', 'alternate': 'High Calorie Vegan Shake', 'baseCalories': 500, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Chana Masala + 2 Tandoori Rotis', 'alternate': 'Lentil Curry + Rice', 'baseCalories': 900, 'icon': Icons.set_meal},
      ];
    } else if (preference == 'Lactose Intolerant') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': '3 Whole Eggs Masala Bhurji + 3 Slices Brown Bread + Banana', 'alternate': 'Oats + Eggs', 'baseCalories': 800, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '2 Cups White Rice + 1 Bowl Rajma + 200g Chicken Curry', 'alternate': 'Brown Rice + Chicken', 'baseCalories': 900, 'icon': Icons.rice_bowl},
        {'title': 'Pre-Workout', 'food': '2 Bananas + Handful of Almonds/Walnuts + Black Coffee', 'alternate': 'Dates + Almonds', 'baseCalories': 400, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': '3 Rotis + Chicken Keema + Sautéed Veggies', 'alternate': 'Fish Curry + Roti', 'baseCalories': 700, 'icon': Icons.dinner_dining},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Oatmeal with Almond Milk, Peanut Butter, Banana', 'alternate': 'Egg Whites + Toast', 'baseCalories': 750, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '3 Roti + Mix Veg Sabzi + 200g Fish Curry', 'alternate': 'Chicken Tikka + Rice', 'baseCalories': 850, 'icon': Icons.lunch_dining},
        {'title': 'Pre-Workout', 'food': 'Apple + Peanut Butter + Rice Cakes', 'alternate': 'Banana + Peanut Butter', 'baseCalories': 400, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': 'Chicken Pulao + Salad', 'alternate': 'Chicken Biryani', 'baseCalories': 700, 'icon': Icons.rice_bowl},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Chicken Sausages (x4) + 3 Fried Eggs + Toast', 'alternate': 'Bacon + Eggs', 'baseCalories': 1000, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Chicken Biryani + Extra Chicken Piece', 'alternate': 'Mutton Biryani', 'baseCalories': 1100, 'icon': Icons.rice_bowl},
        {'title': 'Pre-Workout', 'food': 'Clear Whey Isolate Shake + Dates', 'alternate': 'Protein Bar + Nuts', 'baseCalories': 500, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Mutton Curry + 2 Rotis', 'alternate': 'Chicken Curry + Rice', 'baseCalories': 900, 'icon': Icons.set_meal},
      ];
    } else {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': '3 Whole Eggs Masala Bhurji + 3 Slices Brown Bread + Banana Shake', 'alternate': 'Oats + Whey Protein', 'baseCalories': 800, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '2 Cups White Rice + 1 Bowl Rajma + 200g Chicken Curry + Curd', 'alternate': 'Brown Rice + Chicken', 'baseCalories': 900, 'icon': Icons.rice_bowl},
        {'title': 'Pre-Workout', 'food': '2 Bananas + Handful of Almonds/Walnuts + Black Coffee', 'alternate': 'Dates + Almonds', 'baseCalories': 400, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': '3 Ghee Rotis + Chicken Keema + 1 Glass Warm Milk', 'alternate': 'Fish Curry + Roti', 'baseCalories': 700, 'icon': Icons.dinner_dining},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Oatmeal with Whole Milk, Peanut Butter, Banana', 'alternate': 'Eggs + Toast', 'baseCalories': 750, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': '3 Roti + Mix Veg Sabzi + 200g Fish Curry + Lassi', 'alternate': 'Chicken Tikka + Rice', 'baseCalories': 850, 'icon': Icons.local_drink},
        {'title': 'Pre-Workout', 'food': 'Apple + Peanut Butter + Rice Cakes', 'alternate': 'Banana + Peanut Butter', 'baseCalories': 400, 'icon': Icons.fitness_center},
        {'title': 'Dinner', 'food': 'Chicken Pulao + Raita', 'alternate': 'Chicken Biryani', 'baseCalories': 700, 'icon': Icons.rice_bowl},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Aloo Paratha (x3) with Butter + 3 Eggs', 'alternate': 'Pancakes + Eggs', 'baseCalories': 1000, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Chicken Biryani + Mango Lassi', 'alternate': 'Mutton Biryani', 'baseCalories': 1100, 'icon': Icons.rice_bowl},
        {'title': 'Pre-Workout', 'food': 'Mass Gainer Shake + Dates', 'alternate': 'High Calorie Shake', 'baseCalories': 500, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Butter Chicken + 2 Naan', 'alternate': 'Chicken Curry + Rice', 'baseCalories': 900, 'icon': Icons.set_meal},
      ];
    }
  }

  List<Map<String, dynamic>> generateMaintenanceMeals(String type) {
    if (preference == 'Vegetarian') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': '2 Besan Chillas stuffed with Paneer + Mint Chutney', 'alternate': 'Moong Dal Chilla', 'baseCalories': 450, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': '2 Roti + 1 Bowl Dal + 150g Tandoori Paneer + Mix Veg', 'alternate': 'Brown Rice + Dal + Soya', 'baseCalories': 650, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': 'Sprouted Moong Dal Chaat + Filter Coffee', 'alternate': 'Roasted Chana', 'baseCalories': 300, 'icon': Icons.local_cafe_outlined},
        {'title': 'Dinner', 'food': '1.5 Cups Brown Rice + Chana Masala + Salad', 'alternate': 'Quinoa + Rajma', 'baseCalories': 500, 'icon': Icons.set_meal},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Upma with Veggies + Handful of Peanuts', 'alternate': 'Poha + Peanuts', 'baseCalories': 400, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': 'Veg Pulao + Boondi Raita', 'alternate': 'Veg Biryani', 'baseCalories': 600, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Roasted Makhana + Green Tea', 'alternate': 'Fruit Salad', 'baseCalories': 250, 'icon': Icons.eco},
        {'title': 'Dinner', 'food': '2 Roti + Bhindi Masala + 100g Curd', 'alternate': 'Roti + Mix Veg', 'baseCalories': 550, 'icon': Icons.dinner_dining},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Masala Dosa + Sambar', 'alternate': 'Idli + Sambar', 'baseCalories': 500, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Paneer Butter Masala + 2 Roti', 'alternate': 'Palak Paneer + Roti', 'baseCalories': 750, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': 'Fruit Salad + Buttermilk', 'alternate': 'Protein Bar', 'baseCalories': 300, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Veg Noodles (Whole Wheat) + Tofu Stir Fry', 'alternate': 'Pasta + Veggies', 'baseCalories': 600, 'icon': Icons.dinner_dining},
      ];
    } else if (preference == 'Vegan') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': '2 Besan Chillas + Mint Chutney + Black Tea', 'alternate': 'Vegan Pancakes', 'baseCalories': 450, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': '2 Roti + 1 Bowl Dal + 150g Tofu Tikka + Mix Veg', 'alternate': 'Brown Rice + Tofu', 'baseCalories': 650, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': 'Sprouted Moong Dal Chaat + Filter Coffee', 'alternate': 'Roasted Chana', 'baseCalories': 300, 'icon': Icons.local_cafe_outlined},
        {'title': 'Dinner', 'food': '1.5 Cups Brown Rice + Chana Masala + Salad', 'alternate': 'Quinoa + Beans', 'baseCalories': 500, 'icon': Icons.set_meal},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Upma with Veggies + Handful of Peanuts', 'alternate': 'Poha', 'baseCalories': 400, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': 'Veg Pulao + Tomato Onion Salad', 'alternate': 'Vegan Biryani', 'baseCalories': 600, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Roasted Makhana + Green Tea', 'alternate': 'Apple + Almond Butter', 'baseCalories': 250, 'icon': Icons.eco},
        {'title': 'Dinner', 'food': '2 Roti + Bhindi Masala + Soya Chunks', 'alternate': 'Roti + Dal', 'baseCalories': 550, 'icon': Icons.dinner_dining},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Masala Dosa + Sambar (No Ghee)', 'alternate': 'Idli', 'baseCalories': 500, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Tofu Masala + 2 Roti', 'alternate': 'Soya Curry + Roti', 'baseCalories': 750, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': 'Fruit Salad + Lemon Water', 'alternate': 'Vegan Protein Bar', 'baseCalories': 300, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Veg Noodles (Whole Wheat) + Tofu Stir Fry', 'alternate': 'Vegan Pasta', 'baseCalories': 600, 'icon': Icons.dinner_dining},
      ];
    } else if (preference == 'Lactose Intolerant') {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': '2 Besan Chillas + 2 Boiled Eggs + Black Tea', 'alternate': 'Egg White Omelette', 'baseCalories': 450, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': '2 Roti + 1 Bowl Dal + 150g Tandoori Chicken + Mix Veg', 'alternate': 'Brown Rice + Chicken', 'baseCalories': 650, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': 'Sprouted Moong Dal Chaat + Filter Coffee', 'alternate': 'Boiled Eggs', 'baseCalories': 300, 'icon': Icons.local_cafe_outlined},
        {'title': 'Dinner', 'food': '1.5 Cups Brown Rice + Chana Masala + Salad', 'alternate': 'Quinoa + Chicken', 'baseCalories': 500, 'icon': Icons.set_meal},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Upma with Veggies + 2 Egg Whites', 'alternate': 'Poha + Eggs', 'baseCalories': 400, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': 'Chicken Pulao + Tomato Onion Salad', 'alternate': 'Chicken Biryani', 'baseCalories': 600, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Roasted Makhana + Green Tea', 'alternate': 'Fruit Bowl', 'baseCalories': 250, 'icon': Icons.eco},
        {'title': 'Dinner', 'food': '2 Roti + Bhindi Masala + Fish Fry (1 Piece)', 'alternate': 'Roti + Chicken', 'baseCalories': 550, 'icon': Icons.dinner_dining},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Masala Dosa + Sambar (No Ghee)', 'alternate': 'Idli', 'baseCalories': 500, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Chicken Curry + 2 Roti', 'alternate': 'Fish Curry + Roti', 'baseCalories': 750, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': 'Fruit Salad + Lemon Water', 'alternate': 'Protein Bar', 'baseCalories': 300, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Chicken Noodles (Whole Wheat) + Stir Fry', 'alternate': 'Chicken Pasta', 'baseCalories': 600, 'icon': Icons.dinner_dining},
      ];
    } else {
      if (type == 'A') return [
        {'title': 'Breakfast', 'food': '2 Besan Chillas stuffed with Paneer + Mint Chutney', 'alternate': 'Eggs + Toast', 'baseCalories': 450, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': '2 Roti + 1 Bowl Dal + 150g Tandoori Chicken + Mix Veg', 'alternate': 'Brown Rice + Chicken', 'baseCalories': 650, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': 'Sprouted Moong Dal Chaat + Filter Coffee', 'alternate': 'Boiled Eggs', 'baseCalories': 300, 'icon': Icons.local_cafe_outlined},
        {'title': 'Dinner', 'food': '1.5 Cups Brown Rice + Chana Masala + Salad', 'alternate': 'Quinoa + Chicken', 'baseCalories': 500, 'icon': Icons.set_meal},
      ];
      if (type == 'B') return [
        {'title': 'Breakfast', 'food': 'Upma with Veggies + 2 Boiled Eggs', 'alternate': 'Oats + Eggs', 'baseCalories': 400, 'icon': Icons.breakfast_dining},
        {'title': 'Lunch', 'food': 'Chicken Pulao + Boondi Raita', 'alternate': 'Chicken Biryani', 'baseCalories': 600, 'icon': Icons.rice_bowl},
        {'title': 'Snack', 'food': 'Roasted Makhana + Green Tea', 'alternate': 'Fruit Bowl', 'baseCalories': 250, 'icon': Icons.eco},
        {'title': 'Dinner', 'food': '2 Roti + Bhindi Masala + 100g Curd', 'alternate': 'Roti + Chicken', 'baseCalories': 550, 'icon': Icons.dinner_dining},
      ];
      return [
        {'title': 'Breakfast', 'food': 'Masala Dosa + Sambar', 'alternate': 'Idli + Sambar', 'baseCalories': 500, 'icon': Icons.bakery_dining},
        {'title': 'Lunch', 'food': 'Chicken Curry + 2 Roti', 'alternate': 'Butter Chicken + Roti', 'baseCalories': 750, 'icon': Icons.lunch_dining},
        {'title': 'Snack', 'food': 'Fruit Salad + Buttermilk', 'alternate': 'Protein Shake', 'baseCalories': 300, 'icon': Icons.local_drink},
        {'title': 'Dinner', 'food': 'Chicken Noodles (Whole Wheat) + Veg Stir Fry', 'alternate': 'Chicken Pasta', 'baseCalories': 600, 'icon': Icons.dinner_dining},
      ];
    }
  }

  // Compile the massive map
  return {
    'Cutting': {
      'days': {
        'Monday': {'macros': macros['Cutting'], 'meals': generateCuttingMeals('A')},
        'Tuesday': {'macros': macros['Cutting'], 'meals': generateCuttingMeals('B')},
        'Wednesday': {'macros': macros['Cutting'], 'meals': generateCuttingMeals('A')},
        'Thursday': {'macros': macros['Cutting'], 'meals': generateCuttingMeals('B')},
        'Friday': {'macros': macros['Cutting'], 'meals': generateCuttingMeals('A')},
        'Saturday': {'macros': macros['Cutting'], 'meals': generateCuttingMeals('B')},
        'Sunday': {'macros': macros['Cutting'], 'meals': generateCuttingMeals('C')}, // Uses the default return from generate methods
      }
    },
    'Bulking': {
      'days': {
        'Monday': {'macros': macros['Bulking'], 'meals': generateBulkingMeals('A')},
        'Tuesday': {'macros': macros['Bulking'], 'meals': generateBulkingMeals('B')},
        'Wednesday': {'macros': macros['Bulking'], 'meals': generateBulkingMeals('A')},
        'Thursday': {'macros': macros['Bulking'], 'meals': generateBulkingMeals('B')},
        'Friday': {'macros': macros['Bulking'], 'meals': generateBulkingMeals('A')},
        'Saturday': {'macros': macros['Bulking'], 'meals': generateBulkingMeals('B')},
        'Sunday': {'macros': macros['Bulking'], 'meals': generateBulkingMeals('C')},
      }
    },
    'Maintenance': {
      'days': {
        'Monday': {'macros': macros['Maintenance'], 'meals': generateMaintenanceMeals('A')},
        'Tuesday': {'macros': macros['Maintenance'], 'meals': generateMaintenanceMeals('B')},
        'Wednesday': {'macros': macros['Maintenance'], 'meals': generateMaintenanceMeals('A')},
        'Thursday': {'macros': macros['Maintenance'], 'meals': generateMaintenanceMeals('B')},
        'Friday': {'macros': macros['Maintenance'], 'meals': generateMaintenanceMeals('A')},
        'Saturday': {'macros': macros['Maintenance'], 'meals': generateMaintenanceMeals('B')},
        'Sunday': {'macros': macros['Maintenance'], 'meals': generateMaintenanceMeals('C')},
      }
    },
  };
}
