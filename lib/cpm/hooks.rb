module CPM
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_projects_settings_members_table_header,
              :partial => 'hooks/cpm/view_projects_settings_members_table_header'
    render_on :view_projects_settings_members_table_row,
              :partial => 'hooks/cpm/view_projects_settings_members_table_row'

    # Show users dedication in welcome page
    def view_welcome_index_right(context={ })
      content = User.current.get_capacity_summary

      if content.blank?
      	content = "No tiene establecida ninguna dedicación para hoy."
      else
      	content = "<h3>Dedicación para hoy</h3>".html_safe+content
      end

      return content_tag(:div, content, :class  => 'box')
    end
  end
end

