module CPM
  class Hooks < Redmine::Hook::ViewListener
    def view_welcome_index_right(context={ })
      content = User.current.get_capacity_summary

      if content.blank?
      	content = l(:"cpm.label_no_assignments_today")
      else
      	content = ("<h3>"+l(:"cpm.label_todays_assignments")+"</h3>"+content).html_safe
      end

 
      return content_tag(:div, content, :class  => 'box')
    end
  end
end

