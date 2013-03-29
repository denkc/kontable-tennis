module ApplicationHelper
  def link_to_with_current(name, url, opts={})
    if current_page? url
      if opts[:class].blank?
        opts[:class] = 'active'
      else
        opts[:class] += ' active'
      end
    end
    link_to name, url, opts
  end

  def format_game_scores(scores)
    spans = scores.map do |w, l, status|
      content_tag 'span', "#{w}-#{l}", class: status
    end.join

    raw(spans)
  end
  
  def format_tags(tags, player, admin)
    tags = tags.map do |tag|
      output = link_to(content_tag('span', tag.name, class: 'tag'), tag_path(tag), class: 'tag-link')
      if admin
        output += button_to "x", tag_path(tag, {:player_id => player.id}), :confirm => "Are you sure?", :method => :delete, class: 'tag-delete'
      end
      output
    end.join

    raw(tags)
  end
end
