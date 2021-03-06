module ApplicationHelper
  def page_id
    [].tap do |parts|
      case
      when controller.status != 200
        parts << 'error' << controller.status
      when controller.controller_name == 'pages'
        parts << params[:id]
      else
        parts << controller.action_name

        if %w(index).any? { |prefix| controller.action_name =~ /\A#{prefix}/ }
          parts << controller.controller_name
        elsif %w(show edit update new create).any? { |prefix| controller.action_name =~ /\A#{prefix}/ }
          parts << controller.controller_name.singularize
        end
      end
    end.join('-').dasherize
  end

  def set_title(page_title)
    content_for(:title) { page_title }
  end

  def title
    [
      content_for(:title),
      "RubyDocs - #{t :tagline}"
    ].compact.join(' | ').html_safe
  end

  def description
    'Create your perfect set of searchable Ruby and Rails docs by picking exactly the versions you need. Hosted in the cloud and fronted by a CDN, your docs will always be there for you.'
  end

  def favicon_tag(url)
    favicon = case url
    when %r(//github.com)   then 'github.png'
    when %r(//rubygems.org) then 'rubygems.png'
    else                         'website.png'
    end
    image_tag "favicons/#{favicon}"
  end
end
