require 'elo_ratings'

class MatchesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create

  def create
    match = Match.new(occured_at: params[:occured_at])
    match.winner_score = 0
    match.loser_score = 0

    player_one = Player.find_or_create_by_name(params[:one_name].downcase)
    player_two = Player.find_or_create_by_name(params[:two_name].downcase)

    if player_one.valid? and player_two.valid?
      params[:game_score_one].zip(params[:game_score_two]).each do |score_one, score_two|
        one = score_one.to_i
        two = score_two.to_i

        unless one == 0 and two == 0
          if one > two
            match.games.build(winner: player_one, winner_score: one,
                              loser:  player_two, loser_score:  two)
          else
            match.games.build(winner: player_two, winner_score: two,
                              loser:  player_one, loser_score:  one)
          end
        end
      end

      if match.games.size == 0
        flash.alert = "Must enter at least one game to post a match."
      elsif match.valid? && match.winner.valid? && match.loser.valid?
        match.save!
        EloRatings.add_match(match)
        flash.notice = "Successfully added match between #{params[:one_name]} and #{params[:two_name]}"
      else
        flash.alert = "Must specify a winner and a loser to post a match. #{match.errors.messages.inspect}"
      end
    else
      flash.alert = "Must specify players to post a match."
    end
    redirect_to :back
  end

  def destroy
    Match.find(params[:id]).destroy
    EloRatings.recompute
    redirect_to matches_path
  end
  
  def index
    @match = Match.new
    @matches = Match.order("occured_at desc").includes([:winner, :loser])
  end

end
