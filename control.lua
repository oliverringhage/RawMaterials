-- control.lua


--[[
Todo:
  Check if we can get list of materials needed for specific item.

]]

function global_init()
  global.config = {}
  global["config-tmp"] = {}
  global.storage = {}
  global.storage_index = {}
end


function gui_init(player)
  local flow = mod_gui.get_button_flow(player)
  if not flow.upgrade_planner_config_button then
    local button = flow.add
    {
      type = "sprite-button",
      name = "upgrade_planner_config_button",
      style = mod_gui.button_style,
      sprite = "item/upgrade-builder",
      tooltip = {"upgrade-planner.button-tooltip"}
    }
    button.style.visible = true
  end
end



script.on_event(defines.events.on_gui_opened, function(event)
  game.print("The player " .. event.player_index .. " opened a gui which has the type " ..
      event.gui_type)
end)

script.on_event("my-window", function(event)
  game.print("Pressed I?")
  local player = game.players[event.player_index]
  gui_open_my_frame(player)
end)

script.on_init(function()
  global_init()
  for k, player in pairs (game.players) do
    gui_init(player)
  end
end)

function gui_open_my_frame(player)
  local flow = player.gui.center
  local frame = flow.my_frame
  if frame then
    frame.destroy()
    return
  end

  frame = flow.add{
    type = "frame",
    name = "my_frame",
    direction = "vertical"
  }

  local storage_flow = frame.add{type = "table", name = "my_flow", column_count = 4}

  local ruleset_grid = frame.add{
    type = "table",
    column_count = 6,
    name = "ruleset_grid",
    style = "slot_table"
  }

  local items = game.item_prototypes
  for i = 1, 16 do
    local sprite = nil
    local tooltip = nil
    local from = "from"
    tooltip = from
    local elem = ruleset_grid.add{
      type = "choose-elem-button",
      name = "from_" .. i,
      elem_type = "item",
      tooltip = tooltip
    }

    local elem = ruleset_grid.add{
      type = "textfield",
      name = "text_" .. i,
      elem_type = "item",
      tooltip = tooltip
    }
  end

  frame.add{
    type = "button",
    name = "save_button",
    tooltip = "Save",
    caption = "Save"
    }
  player.opened = frame
end


function findIronPlatesRecursiveRecipe(recipe, number)
  game.print("Checking recipe " .. recipe.name)
  if recipe.name == "iron-plate" then
    game.print("returning " .. number)
    return number
  end

  for i = 1, #recipe.ingredients do
    game.print("entering for loop")
    if(recipe.ingredients[i].name == "iron-plate") then -- If it is a iron-plate, we should be done?
      game.print("this ingredient is an  iron-plate and number wnet form  " .. number .. " and is: " .. number + recipe.ingredients[i].amount)
      number = number + recipe.ingredients[i].amount
      return number
    else -- if it is not a iron-plate, it has to be a recipe??
      local newRecipe = player.force.recipes[recipe.ingredients[i].name]
      game.print("NOT iron-plate, redo everything")
      findIronPlatesRecursiveRecipe(newRecipe, number)
    end
  end
end

function findStuff(recipe, player)
  local ingredients = {}
  ingredients["iron-plate"] = 0
  ingredients["copper-plate"] = 0
  ingredients["stone"] = 0
  ingredients["coal"] = 0
  ingredients["other"] = 0
  for k, ingredient in pairs(recipe.ingredients) do
    if ingredient.name == "iron-plate" then ingredients["iron-plate"] = ingredients["iron-plate"] + ingredient.amount
    elseif ingredient.name == "copper-plate" then ingredients["copper-plate"] = ingredients["copper-plate"] + ingredient.amount
    elseif ingredient.name == "stone" then ingredients["stone"] = ingredients["stone"] + ingredient.amount
    elseif ingredient.name == "coal" then ingredients["coal"] = ingredients["coal"] + ingredient.amount
    else
      ingredients["other"] = ingredients["other"] + 1
      findStuff(player.force.recipes[ingredient.name], player)
    end
  end
  game.print("checking: " .. recipe.name)
  game.print("iron: " .. ingredients["iron-plate"])
  game.print("copper: " .. ingredients["copper-plate"])
  game.print("stone: " .. ingredients["stone"])
  game.print("coal: " .. ingredients["coal"])
  game.print("other: " .. ingredients["other"])
  return ingredients
end


script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  local name = element.name
  local player = game.players[event.player_index]
  local recipeToCheck = "inserter"
  if(name == "save_button") then
    local ingredients = findStuff(player.force.recipes[recipeToCheck], player)
    --game.print("totalnumber of plates: " .. findIronPlatesRecursiveRecipe(player.force.recipes["inserter"], 0))
    --findIronPlatesRecursiveRecipe(player.force.recipes["iron-gear-wheel"], 0)
  end

  if(name == "saveeee_button")then
    local totalIron = 0
    local totalCopper = 0

    local ingredients = player.force.recipes["inserter"].ingredients
    game.print("For Inserter we need: ")
    for i = 1, #ingredients do
        local thisIngredient = ingredients[i]
        game.print(thisIngredient.amount .. " " .. thisIngredient.name)
        if thisIngredient.name == "iron-plate" then
          totalIron = totalIron + thisIngredient.amount
        elseif thisIngredient.name == "copper-plate" then
          totalCopper = totalCopper + thisIngredient.amount
        else
          -- keep going
          game.print("This item " .. thisIngredient.name .. " is not a Iron plate NOR copper plate, so we should do this again." )
        end
        -- If this is not a iron-plate OR a copper-plate, continue?
    end
  --  game.print(player.force.recipes[child.children[i].elem_value].ingredients[j].amount .. " " .. player.force.recipes[child.children[i].elem_value].ingredients[j].name)

  end


  if(name == "saveeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee_button") then
    player.insert("iron-plate")
    game.print("saving")
    -- next step, loop over all elements
    -- It goes from left to right.
    local children = element.parent.children
    game.print(children[2].type .. " " .. children[2].name .. " " .. " grandchild " .. children[2].children[1].name .. " type: " .. children[2].children[1].type)
    if(children[2].children[1].elem_value ~= nil) then
      game.print("elem type: " .. children[2].children[1].elem_type .. " elem value: " .. children[2].children[1].elem_value)
    else
      game.print("elem type: " .. children[2].children[1].elem_type .. " elem value: nil")
    end
    for k, child in pairs(children) do
      game.print(#child.children_names)
      if #child.children_names > 0 then
        for i = 1, #child.children_names do
          --         child.children[3].elem_value.get_recipe().ingredients[1]
          if(child.children[i].type == "choose-elem-button") then
            --game.print("for the item " .. child.children[i].elem_value .. " we need " .. player.force.recipes[child.children[i].elem_value].ingredients[1].name)
            game.print("for the item " .. child.children[i].elem_value .. " we need... ")
            game.print("number of ingredients: ".. #player.force.recipes[child.children[i].elem_value].ingredients)
            for j = 1, #player.force.recipes[child.children[i].elem_value].ingredients do
              game.print(player.force.recipes[child.children[i].elem_value].ingredients[j].amount .. " " .. player.force.recipes[child.children[i].elem_value].ingredients[j].name)
            end
            --game.print(player.force.recipes[child.children[i].elem_value].name)
            --game.print("this children is a choose-elem-button and has the elem value of: " .. child.children[i].elem_value)

            --player.insert(child.children[i].elem_value)
          elseif child.children[i].type == "textfield" then
            game.print("this children is a text field and has the value of: " .. child.children[i].text)
          end
          game.print("forigrandcihld.type: " .. child.children[i].type)
        end
        for key, grandchild in pairs(child.children) do
          game.print("grandchild.type: " .. grandchild.type)
        end
      end
      game.print(child.type .. " " .. " " .. child.name)
    end
    return
  end
end)
