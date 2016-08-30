module ApplicationHelper
  def in_time_zone(time)
    if time.nil?
      'N/A'
    else
      I18n::localize(time.in_time_zone('Perth'), :format => :long)
    end
  end

  def can_schedule?
    user_signed_in?
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction), :class => css_class
  end

  def format_date(date,format)
    date.strftime(format)
  end
end
