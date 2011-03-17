
class Intro < Room
  def look
    unless @seen_intro
      @seen_intro = true
      "Type 'look' to look around."
    else
      "This is Room," |
      "a virtual world for you to explore." |
      "At any time, you can type 'help', but it won't do anything." |
      "" |
      "Start by entering the room."
    end
  end
  
  def enter_room
    "You black out, then awaken in the room." |
    go("bedroom")
  end
  dup :enter
  
  def look_XXX feh
    "You *want* to look at #{feh}?"
  end
end

class Bedroom < Room
  def look
    "Your comfortable abode." |
    "There is a closet to your left.#{" Try looking at it." unless @looked_left}" |
    ("There is a pencil sharpener on your right." if have? :pencil) |
    ("Right behind you, there's a chute you could jump into." if @sharpened_pencil) |
    "Everything else is a blur."
  end
  
  def look_closet
    @looked_left = true
    "It looks like a normal closet." |
    (@chipped_paint ? "Except you chipped some of the paint off." : "The white paint is a little chipped, though.")
  end
  dup :look_left
  
  def look_blur
    "You try to focus your eyes, but the blur... it's too fuzzy." |
    "You strain your eyes. But all you can make out is" |
    look
  end
  
  def enter_closet
    "You creep inside the closet." |
    go("closet")
  end
  dup :left, :enter, :go_into_the_closet, :go_into_closet
  
  def open_closet
    if @closet_open == 2
      "It ain't getting any more opener."
    elsif @closet_open == 1
      @closet_open += 1
      "The closet was already open, but you found a way to" |
      "make it even MORE open. Its gaping maw beckons for you to enter." |
      "It's hungry."
    else
      @closet_open ||= 0
      @closet_open += 1
      "The closet door is now open, which explains why you" |
      "were celebrating just a moment ago."
    end
  end
  dup :open_the_closet
  
  def close_closet
    @closet_open = 0
    "The closet is now closed, for what it's worth."
  end
  dup :closet_the_closet
  
  def chip_paint
    @chipped_paint = true
    take :paint_chips
    "Flakes of paint come off into your hand."
  end
  dup :chip_the_paint, :chip_at_the_paint
  
  def chip_some_of_the_paint_off_of_the_closet
    "You were way to explicit. Try 'chip the paint' or even 'chip paint'."
  end
  
  def look_paint
    "Your job is short. This paint is already dry."
  end
  dup :look_paint_chips
  
  def sharpen_pencil
    if have? :pencil
      @sharpened_pencil = true
      lose :pencil
      "You whittle the pencil to nothing."
    else
      unknown_command
    end
  end
  dup :sharpen_the_pencil
  
  def look_pencil_sharpener
    if have? :pencil
      "That's a mighty fine pencil sharpener. Red."
    else
      unknown_command
    end
  end
  
  def jump_into_chute
    if @sharpened_pencil
      "Throwing caution to the wind, you jump into the chute and die." |
      "Just kidding! You find yourself on skis," |
      "hurtling down a snow-covered slope at break-neck speed!" |
      go("skiing1")
    else
      unknown_command
    end
  end
  dup :jump_into_the_chute
  
  def eat_XXX item
    "You eat the #{item}, wondering whether that's a good idea."
  end
  dup :consume_XXX
end

class Closet < Room
  def look
    "In the closet." |
    "It's too dark to see. You might be stuck!" |
    (if @got_pencil
       "No wait, you can still exit the closet."
     else
       "You stub your toe on something sharp. It feels like a pencil."
     end)
  end
  
  def open_door
    "The door won't budge."
  end
  dup :open_the_door
  
  def look_pencil
    if @got_pencil
      unknown_command
    else
      "It's too dark to see, so you settle for stubbing your" |
      "foot on it again. Definitely a No. 3 pencil." |
      "Maybe you should 'get' it."
    end
  end
  
  def get_pencil
    if @got_pencil
      "What pencil?"
    else
      take :pencil
      @got_pencil = true
      "Awesome, a pencil! You place the pencil in your pocket."
    end
  end
  
  def exit
    "You somehow manage to leave the closet." |
    go("bedroom")
  end
  dup :exit_closet, :exit_the_closet, :leave
end

class Skiing1 < Room
  def look
    if @looked
      go("skiing2")
    else
      @looked = true
      "The lessons pay off. You've got some snow in your teeth."
    end
  end
  
  def eat_snow
    "That was delicious." |
    go("skiing2")
  end
  dup :eat_the_snow
end

class Skiing2 < Room
  def look
    @looked ||= 0
    @looked += 1
    
    if @looked == 5
      "Go away."
    elsif @looked >= 2
      "The end."
    else
      "You're at the bottom of the hill." |
      (if have? :paint_chips
         "Your final score is 1 because you still have the paint chips."
       else
         "Your final score is 0 because you don't have any paint chips."
       end)
    end
  end
end
