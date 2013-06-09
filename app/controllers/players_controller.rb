require 'elo_ratings'

class PlayersController < ApplicationController
  
  def index
    if params[:q]
      query = params[:q].downcase + '%'
      names = Player.where(["LOWER(name) LIKE ?", query]).collect(&:name)
    else
      names = Player.all.collect(&:name)
    end
    
    render text: names.collect(&:downcase).sort.uniq.collect(&:titleize).join("\n")
  end
  
  def vs_data
    player = params[:player]
    vs_player = params[:vs_player]
    matches = params[:matches]
    matches.reject!{|m| ![m.winner_id, m.loser_id].include?(vs_player.id)}
    
    {
      :num_wins => matches.select{|m| m.winner_id == player.id}.size,
      :num_loses => matches.select{|m| m.loser_id == player.id}.size
    }
  end
  
  def show
    @match = Match.new
    @player = Player.find(params[:id])
    @matches = @player.matches.order("occured_at desc")
    if params[:vs]
      params[:player] = @player
      params[:vs_player] = Player.find(params[:vs])
      params[:matches] = @matches
      vs_data_hash = vs_data
      @num_wins = vs_data_hash[:num_wins]
      @num_loses = vs_data_hash[:num_loses]
    else
      @num_wins = @player.winning_matches.size
      @num_loses = @player.losing_matches.size
    end
    @elo_player = EloRatings.get_elo_player(@player.id)
    
    @ratings_by_date = EloRatings.ratings_by_date(@player.id)
  end
  
  def rankings
    @match = Match.new
    @ratings = EloRatings.players_by_rating
    @players_by_id = Player.all.index_by{|p| p.id}
  end
  
  def distribution
    rankings
    @ratings.reject!{|player_id, _| @players_by_id[player_id].most_recent_match.occured_at < 30.days.ago}
    @top_n = params[:n] ? params[:n].to_i : @ratings.size
  end
  
  def vs_table
    distribution
    @vs_table = Array.new(@ratings.size) { Array.new(@ratings.size) { [0, 0] } }
    @rank_to_player = {}
    
    # it's probably better to iterate over all of the matches than to hit each match twice this way
    # but who has time for that
    # plus I'm new to ruby
    @ratings.collect{|id, _| id}.each_with_index do |player_id, player_index|
      player = @players_by_id[player_id]
      @rank_to_player[player_index] = player
      @ratings.collect{|id, _| id}.each_with_index do |vs_id, vs_index|
        if player_id != vs_id
          vs_player = @players_by_id[vs_id]
          params[:player] = player
          params[:vs_player] = vs_player
          params[:matches] = player.matches.order("occured_at desc")
          vs_data_hash = vs_data
          @vs_table[player_index][vs_index] = [vs_data_hash[:num_wins], vs_data_hash[:num_loses]]
        end
      end
    end
    
  end
end
