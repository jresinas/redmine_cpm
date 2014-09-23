module CPM
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_welcome_index_right,
              :partial => 'hooks/cpm/view_welcome_index_right'
  end
end

