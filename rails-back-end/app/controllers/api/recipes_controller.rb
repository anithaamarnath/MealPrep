class Api::RecipesController < ApplicationController
  # def update
  #   puts params
  #   puts session[:user_id]
  #   # if(current_user)
  #   #   u = User.find(session[:user_id])
  #   #   u.recipes.find(recipe_id)
  #   #r1 =UsersFavoriteRecipe.where(user_id: session[:user_id], recipe_id: recipe_id)
  #   #puts r1

  #   # end
  #   render json: {
  #     mealplan: "Hasta aqui"
  #   }
  # end

  def create
    puts params
    puts session[:user_id]
    # if(current_user) end
    ur = UsersFavoriteRecipe.new
    ur.user_id = session[:user_id]
    ur.recipe_id = params[:recipe_id]
    ur.save!
  end

  def destroy
    puts params
    puts session[:user_id]
    # if(current_user) end
    ur = UsersFavoriteRecipe.find_by(user_id: session[:user_id], recipe_id: params[:recipe_id])
    ur.destroy
  end
end
