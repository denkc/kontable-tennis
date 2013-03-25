class TagsController < ApplicationController
  def index
    @match = Match.new
    @ratings = EloRatings.players
    @tags = Tag.all
    
    @tags = @tags.sort_by{|tag|
      ratings_for_tag = @ratings.select{|player_id, elo_player|
        tag.players.exists?(player_id)
      }.collect{|player_id, elo_player| elo_player.rating}

      ratings_for_tag.sum/ratings_for_tag.size
    }.reverse
    
    @tags_data = {}
    @tags.each do |tag|
      params[:tag] = tag
      @tags_data[tag] = tag_data
    end
  end


  def show
    @match = Match.new
    @tag = Tag.find(params[:id])
    @players_by_id = Player.all.index_by{|p| p.id}
    @ratings = EloRatings.players_by_rating.select{|player_id, elo_player| @players_by_id[player_id].tags.exists?(@tag)}
    
    params[:tag] = @tag
    @tag_data = tag_data
  end
  
  
  def tag_data
    tag = params[:tag]
    tag_data = {}
    tag_elo_players = @ratings.select{|player_id, elo_player| tag.players.exists?(player_id)}

    wins = 0
    total_games = 0
    total_elo = 0
    tag_elo_players.each do |player_id, tag_elo_player|
      tag_elo_player.games.each do |game|
        wins += 1 if (game.one==tag_elo_player && game.result > 0.5) || (game.two==tag_elo_player && game.result < 0.5)
        total_games += 1
      end
      total_elo += tag_elo_player.rating
    end

    tag_data[:win_loss] = "#{wins}-#{total_games-wins}"
    tag_data[:average_elo] = total_elo/tag_elo_players.size
    
    tag_data
  end


  def create
    @player = Player.find(params[:player_id])
    @tag = Tag.find_or_create_by_name(params[:tag])
    @player.tags << @tag

    flash.notice = 'Tag was successfully created.'
    redirect_to :back
  end
end
