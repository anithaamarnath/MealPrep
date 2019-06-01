class Api::MealPlansController < ApplicationController

 BASE_URL = "https://api.edamam.com/search?"
 API_PARTIAL_URL = "app_id=#{ENV['KEY_API_ID']}" + "&" +"app_key=#{ENV['KEY_API_PASS']}"
 RECIPE_PARTIAL_URL = "r=http%3A%2F%2Fwww.edamam.com%2Fontologies%2Fedamam.owl%23recipe_"

 def index
  #if current_user
  mealplans = MealPlan.all.order(created_at: :desc) #.where(user_id: session[:user_id])
  recipes = {}
  mealplans.each { |m|
       id = m.id
       recipes[id] = m.recipes
  }
  render json: {
    mealplans: mealplans, # an array of mealplans
    recipes: recipes  #object of recipes, indexed by its mealplan id
   }
   #end
 end

 def show
  #if current_user
   mealplan = MealPlan.find(params[:id])
   recipes = mealplan.recipes
   #ingredients = list_of_ingredients(recipes)
   shopping_list = shopping_list(recipes)
     render json: {
       mealplan: mealplan,
       recipes: recipes,
       ingredients: shopping_list
      }
  #   else
  #     puts "user not allowed to see this mealplan"
  #end
  end

  def last
    #if current_user
      mealplan = MealPlan.last #.where(user_id: session[:user_id])
      recipes = mealplan.recipes
      #ingredients = list_of_ingredients(recipes)
      shopping_list = shopping_list(recipes)
      render json: {
       mealplan: mealplan,
       recipes: recipes,
       ingredients: shopping_list
      }
    #end
  end

  def alexa
    mealplan = MealPlan.last #.where(user_id: session[:user_id])
    recipes = mealplan.recipes
    recipes_names = ""
    recipes.each { |r|
        recipes_names += r['name'] + ", "
      }
    render json: {
       recipes: recipes_names
      }
  end



 def create
   puts params
   #raise "Yay, I'm here!"
   recipes = Recipe.take(params[:days])
   user = User.first
   diet_type = DietType.find_by(name: params[:diet])
   mealplan = MealPlan.new
   mealplan.user = user
   mealplan.recipes = recipes
   mealplan.diet_type = diet_type
   mealplan.servings = params[:servings]
   mealplan.days = params[:days]
   mealplan.save!
   puts "The new mealplan id #{mealplan.id}"
   render json: {
     mealplan: mealplan,
     recipes: recipes
   }
 end


 private

 # def list_of_ingredients (recipes)
 #   q_string = "#{BASE_URL}&#{API_PARTIAL_URL}"
 #   recipes.each { |r|
 #     q_string = q_string + "&" + RECIPE_PARTIAL_URL + r.edaman_id
 #   }
 #   puts q_string
 #   result = HTTParty.get(q_string)
 #   list = []

 #   if result
 #     result.each { |r|
 #       list = list + r["ingredientLines"]
 #     }
 #   else
 #    puts result
 #  end
 #    puts "List of ingredients: #{list}"
 #    return list

 # end

  def shopping_list(recipes)
    q_string = "#{BASE_URL}&#{API_PARTIAL_URL}"
     recipes.each { |r|
       q_string = q_string + "&" + RECIPE_PARTIAL_URL + r.edaman_id
     }
     puts q_string
     result = HTTParty.get(q_string)
     ing =[]
     shopping_list_hash = {}
     shopping_list_array =[]

    if result
      result.each { |r|
        ing = ing + r["ingredients"]
      }
    end
    puts ing
    ing.each { |i|
        if !shopping_list_hash[i['food']]
          shopping_list_hash[i['food']] = i['weight']
        else
          shopping_list_hash[i['food']] = shopping_list_hash[i['food']] + i['weight']
        end
      }
    # converting the hash into an array
    shopping_list_hash.each do |key, value|
      v = "#{key} - #{value.round(2).to_s} g"
      shopping_list_array.push(v)
    end
    return shopping_list_array
  end

end

