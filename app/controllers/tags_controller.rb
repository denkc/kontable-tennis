class TagsController < ApplicationController
  def index
    @match = Match.new
    @players_by_id = Player.all.index_by{|p| p.id}
    @ratings = EloRatings.players.reject{|player_id, _| @players_by_id[player_id].most_recent_match.occured_at < 30.days.ago}
    @tags = Tag.all
    
    @tags_data = {}
    @tags.each do |tag|
      params[:tag] = tag
      @tags_data[tag] = tag_data
    end
    
    @tags = @tags.sort_by{|tag|
      @tags_data[tag][:weighted_average_elo]
    }.reverse
  end


  def show
    @match = Match.new
    @tag = Tag.find(params[:id])
    @players_by_id = Player.all.index_by{|p| p.id}

    if params[:vs]
      @vs = Tag.find_by_name(params[:vs])
      vs_different_player_ids = (@vs.players - @tag.players).collect(&:id)  # not symmetric difference

      @matches = []
      @num_wins = 0
      @num_losses = 0
      @tag.players.each do |player|
        player_matches = player.matches.reject{|m|
          other_player_id = [m.winner_id, m.loser_id].reject{|player_id| player_id == player.id}.pop
          !vs_different_player_ids.include?(other_player_id)
        }
        @matches += player_matches

        @num_wins += player_matches.select{|m| m.winner_id == player.id}.size
        @num_losses += player_matches.select{|m| m.loser_id == player.id}.size
      end
      
      @matches = @matches.sort_by{|match|
        match.occured_at
      }.reverse
    else
      @ratings = EloRatings.players_by_rating.select{|player_id, elo_player| @players_by_id[player_id].tags.exists?(@tag)}
      params[:tag] = @tag
      @tag_data = tag_data

      @num_wins = @tag_data[:wins]
      @num_losses = @tag_data[:losses]
    end
    
  end
  
  
  def tag_data
    tag = params[:tag]
    tag_data = {}
    tag_elo_players = @ratings.select{|player_id, elo_player| tag.players.exists?(player_id)}

    wins = 0
    total_games = 0
    total_elo = 0
    total_weighted_elo = 0
    tag_elo_players.each do |player_id, tag_elo_player|
      player_games = 0
      tag_elo_player.games.each do |game|
        wins += 1 if (game.one==tag_elo_player && game.result > 0.5) || (game.two==tag_elo_player && game.result < 0.5)
        player_games += 1
      end
      total_elo += tag_elo_player.rating
      total_games += player_games
      total_weighted_elo += player_games*tag_elo_player.rating
    end

    tag_data[:wins] = wins
    tag_data[:losses] = total_games-wins
    tag_data[:average_elo] = total_elo/(tag_elo_players.size.nonzero? || 1)
    tag_data[:weighted_average_elo] = total_weighted_elo/(total_games.nonzero? || 1)
    
    tag_data
  end


  def create
    @player = Player.find(params[:player_id])
    @tag = Tag.find_or_create_by_name(params[:tag])
    @player.tags << @tag

    flash.notice = 'Tag was successfully created.'
    redirect_to :back
  end
  
  def destroy
    @player = Player.find(params[:player_id])
    player_tag = @player.tags.find(params[:id])
    
    if player_tag
      @player.tags.delete(player_tag)
      flash.notice = 'Tag was successfully deleted.'
    else
      flash.alert = 'Tag not found!'
    end
    redirect_to :back
  end
end
