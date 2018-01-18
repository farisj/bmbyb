require 'wordnik'
require 'open-uri'
require 'twitter'

Wordnik.configure do |config|
  config.api_key = ENV['wordnik_api_key']
end

class BotMeByYourBot

  VERB_LIST_URL = 'https://gist.githubusercontent.com/farisj/f2ebb73fabfa20dfc40e7fa9de72ddd8/raw'.freeze

  def tweet
    phrase = verb + " me by your " + noun + " and i'll " + verb " you by mine"
    client.update(phrase)
  end

  def verb
    @verb ||= verb_list.sample
  end

  def verb_list
    @verb_list ||= open(VERB_LIST_URL).read.split("\n")
  end

  def noun
    return @noun if @noun
    potential_nouns = response.map{ |items| items['word']}
    noun = potential_nouns.find do |noun|
      noun == noun.downcase
    end
    @noun = noun || 'name'
  end

  def response
    Wordnik.words.get_random_words(params)
  end

  def params
    {
      has_dictionary_def: true,
      min_corpus_count: 4000,
      include_part_of_speech: 'noun',
      exclude_part_of_speech: 'proper-noun,proper-noun-plural,proper-noun-posessive,noun-plural'
    }
  end

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = ENV["consumer_key"]
      config.consumer_secret = ENV["consumer_secret"]
      config.access_token = ENV["access_token"]
      config.access_token_secret = ENV["access_token_secret"]
    end
  end
end

BotMeByYourBot.new.tweet
