require 'cpm/user_patch'
require 'cpm/project_patch'
require 'cpm/hooks'

Redmine::Plugin.register :redmine_cpm do
  name 'Capacity Planning Manager'
  author 'Emergya'
  description 'This plugin allows to manage and planning users capacity.'
  version '0.0.1'

  settings :default => {}, :partial => 'settings/cpm_settings'
  menu :top_menu, :cpm, { :controller => 'cpm_management', :action => 'show'}, :caption => 'CPM'
end
