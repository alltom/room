
$ALPHA = "sx8vQ9ZGi4F96dnuNThg"
$OMEGA = "ZkS8eDam8tTF6tBGxi4A3sxhTTYE0EyCGHb9dAHM"

$failed_requires = []
%w{ twitter oauth uri }.each do |n|
  begin
    require n
  rescue LoadError
    $failed_requires << n
  end
end

begin
  require "launchy"
rescue LoadError
end


def request_token
  $request_token ||= begin
    OAuth::Consumer.new($ALPHA, $OMEGA,
      :site => 'http://twitter.com/',
      :request_token_path => '/oauth/request_token',
      :access_token_path => '/oauth/access_token',
      :authorize_path => '/oauth/authorize'
    ).get_request_token
  rescue Exception => e
    nil
  end
end

def authorize_url
  request_token.authorize_url
end

def configure
  Twitter.configure do |config|
    config.consumer_key = $ALPHA
    config.consumer_secret = $OMEGA
    config.oauth_token = $state[:twitter_token]
    config.oauth_token_secret = $state[:twitter_secret]
  end
  $configured = true
end

def authorize pin
  begin
    access = request_token.get_access_token(:oauth_verifier => pin)
    
    $state[:twitter_token] = access.token
    $state[:twitter_secret] = access.secret
    
    configure
  rescue Exception
    nil
  end
end

def tweet_display_format message
  message.gsub("\n", " \\ ").gsub("\"", "'")
end

def latest_tweets
  configure unless $configured
  
  tweets = begin
    Twitter.home_timeline($state[:last_tweet_id] ? { :since_id => $state[:last_tweet_id] } : {}).reverse
  rescue Twitter::Unauthorized
    raise
  rescue Exception => e
    Printer.puts "[warning: couldn't fetch tweets: #{e.inspect} #{e.class}]"
    []
  end
  
  $state[:last_tweet_id] = tweets.last.id unless tweets.length == 0
  
  tweets
end

class Entrance < Room
  def look
    immediate(
    "You pull into the crowded parking lot, shove a" |
    "cinderblock under your car tire, and look up." |
    "The metallic blue neon sign above the door reads:" |
    "" |
    "              DICK'S BAR" |
    "      \"we all like the same things\"" |
    "" |
    "You sure hope so." |
    "" |
    "You attempt to open the door, but it won't budge." |
    "Instead, you see flickers of movement behind two" |
    "holes in the door about eyes' width apart. You squat" |
    "to look into them and see someone rummaging..." |
    ""
    )
    
    if $failed_requires.length > 0
      which = $failed_requires.first
      return "\"Hm, that's strange,\" you hear a voice say." |
      "\"Someone must have done something with my #{which.upcase} gem...\"" |
      "" |
      "For no reason, your eyes roll back into your head and" |
      "you slip out of existence. Should've installed the #{which.upcase} gem!" |
      go("purgatory")
    end
    
    unless request_token
      return Purgatory.intro("The Twitter API could not be reached!") |
      go("purgatory")
    end
    
    "\"Here. Use this.\" A long piece of paper slides beneath the door." |
    "" |
    "Type 'look' to look around, but eventually you're going to have to" |
    "pick up that piece of paper." |
    quietly_go("entrance2")
  end
end

class Entrance2 < Room
  def look
    "You're standing in front of Dick's Bar and" |
    (if have? :paper
       "you really want to read the piece of paper you're holding."
     else
       "you really want to pick up the piece of paper on the ground."
     end)
  end
  
  def pick_up_that_piece_of_paper
    if have? :paper
      huh?
    else
      take :paper
      "You pick up the piece of paper and stuff it in your pocket!" |
      "But aren't you curious what's on it?"
    end
  end
  dup :pick_up_the_piece_of_paper, :pick_up_piece_of_paper, :pick_up_the_paper, :pick_up_paper
  dup :get_the_piece_of_paper, :get_piece_of_paper, :get_the_paper, :get_paper
  
  def read_the_paper
    if have? :paper
      "The paper contains the following message:" |
      "" |
      "   #{authorize_url}" |
      "   SAY YOUR PIN" |
      "" |
      "And that's all."
    else
      huh?
    end
  end
  dup :read_the_piece_of_paper, :read_piece_of_paper, :read_the_paper, :read_paper
  
  def say_XXX pin
    return huh? unless have? :paper
    return huh? if pin !~ /^[0-9]+$/
    
    immediate "You speak your pin and the eyes disappear for a moment."
    immediate
    
    if authorize(pin)
      immediate "And then... the door swings open and the doorman ushers"
      immediate "you inside. \"Come on, come on.\" The door shuts tight behind you."
      immediate
      immediate
      go("bar")
    else
      "\"That is incorrect,\" the voice says and the eyes examine" |
      "you suspiciously. They seem to peer into your very soul and you" |
      "feel nervous." |
      "" |
      "\"Try again.\""
    end
  end
  dup :XXX
end

class Purgatory < Room
  def self.intro reason
    "BANG! Before you can settle into a virtual persona, a" |
    "crack appears in the sky and the universe splits into two!" |
    reason + " And now... well..."
  end
  
  def look
    @jokes ||= ["What's brown and sticky? A stick! Hahahaha!"]
    "You are stuck in purgatory. There is nothing to do here but #{@jokes.length > 0 ? "crack a joke or " : ""}'restart!'."
  end
  
  def laugh
    "You laugh and that makes you feel a little bit better, but still..." | look
  end
  
  def crack_a_joke
    if joke = @jokes.shift
      joke
    else
      "You are out of jokes."
    end
  end
  
  def quit
    exit
  end
  dup :q
end

class Bar < Room
  def look
    @tweet_buffer ||= []
    
    immediate "The bar."
    
    @last_check ||= Time.now - 15
    if Time.now - @last_check > 10
      @tweet_buffer += latest_tweets
      @last_check = Time.now
    end
    
    if @tweet_buffer.length > 0
      "\n" + @tweet_buffer.shift(3 + rand(2)).map do |tweet|
        "#{tweet.user.name} says, \"#{tweet_display_format tweet.text}\""
      end.join("\n\n") + "\n"
    else
      "The room is, for the moment, silent."
    end
    
  rescue Twitter::Unauthorized
    "" |
    "Out of nowhere, the a bouncer grabs you by the ear and" |
    "pulls you outside. Apparently the jig is up? Time to" |
    "re-authenticate. Like your grandma always said: 'OAuth is," |
    "like, the best thing ever.'" |
    go("entrance2")
  end
  
  def say_XXX message
    if message.length > 140
      "The words get caught in your mouth; you're gargling air." |
      "You remember the sign on the wall: '140 characters at a time'." |
      "You were #{message.length - 140} over. :("
    else
      immediate "You proclaim to everyone in the room, \"#{tweet_display_format message}\""
    
      begin
        Twitter.update(message)
        ""
      rescue Exception
        "But no one could hear you. Hello? Is this thing on?"
      end
    end
  end
  
  def XXX action
    if defined?(Launchy) && action.strip == URI.extract(action).first
      Launchy.open(URI.extract(action).first)
      "You feel elevated to another plane."
    else
      huh?
    end
  end
end
