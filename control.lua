-- control.lua

--[[
  TODO: Apparently recipe for all oil stuff (Crude oil, heavy oil) is the recipies used in Oil Refineries, i.e.
        Basic Oil Processing etc etc. So when we have a oil item, we have to check that recipe for that item and do
        calculations based upon that.
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


-- This function takes a recipe as a string, player and a number and returns total raw materials needed for this recipe.
function rec(recipe, player, numberOf, type)
  local platesInThis = 0
  for k, ing in pairs(recipe.ingredients) do
    repeat
      if ing.name == type then
        platesInThis = platesInThis + (ing.amount * numberOf)
      elseif(allTypesContains(ing.name)) then do break end
      else
        local numberOfProducts = 0
        for k, product in pairs(player.force.recipes[ing.name].products) do
          if product.name == ing.name then
            numberOfProducts = numberOfProducts + product.amount
          end
        end
        platesInThis = platesInThis + (numberOf * rec(player.force.recipes[ing.name], player, ing.amount/numberOfProducts, type))
      end
    until true
  end
  return platesInThis
end

function allTypesContains(name)
  for k, item in pairs(getAllTypes()) do
    if(item == name) then return true end
  end
  return false
end

function getAllTypes()
  local allTypes = {"raw-wood", "coal", "stone", "iron-plate", "copper-plate",
                    "uranium-ore", "crude-oil", "heavy-oil", "light-oil",
                    "lubricant", "petroleum-gas", "sulfuric-acid", "water",
                    "steam", "iron-ore"}
  return allTypes
end

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  local name = element.name

  local player = game.players[event.player_index]
--  local recipeToCheck = "iron-gear-wheel" -- 2
--  local recipeToCheck = "transport-belt" -- 3
--  local recipeToCheck = "fast-transport-belt" -- 11.5
--  local recipeToCheck = "underground-belt" -- 17.5
--  local recipeToCheck = "fast-underground-belt" -- 97.5
--  local recipeToCheck = "cargo-wagon" -- 140
--  local recipeToCheck = "fluid-wagon" -- 153
--    local recipeToCheck = "copper-cable"
--    local recipeToCheck = "roboport"
--    local recipeToCheck = "nuclear-reactor"
--    local recipeToCheck = "express-splitter"
--    local recipeToCheck = "logistic-chest-storage"
--    local recipeToCheck = "assembling-machine-2"
--    local recipeToCheck = "roboport"
    local recipeToCheck = "nuclear-reactor"
  if(name == "save_button") then
    local allItems = {}
    local allTypes = getAllTypes()
    for i = 1, #allTypes do
      allItems[allTypes[i]] = rec(player.force.recipes[recipeToCheck], player, 1, allTypes[i])
    end
    for key, item in pairs(allItems) do
      if(item ~= 0) then game.print(key .. " " .. item) end
    end

game.print("HERE COMES 100")
    local allItems = {}
    local allTypes = getAllTypes()
    for i = 1, #allTypes do
      allItems[allTypes[i]] = rec(player.force.recipes[recipeToCheck], player, 100, allTypes[i])
    end
    for key, item in pairs(allItems) do
      if(item ~= 0) then game.print(key .. " " .. item) end
    end
  end


-- This has some ui-functionality, will check every box and print whatever is in them.
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
