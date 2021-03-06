# Plugin's routes
RedmineApp::Application.routes.draw do
	match '/cpm_management/:action' => 'cpm_management'
	match '/cpm_user_capacity/:action' => 'cpm_user_capacity'
	match '/cpm_management/edit_form/:user_id' => 'cpm_management#edit_form'
	match '/cpm_user_capacity/edit/:id' => 'cpm_user_capacity#edit'
	match '/cpm_user_capacity/delete/:id' => 'cpm_user_capacity#delete'
	match '/cpm_management/get_filter_custom_field/:custom_field_id' => 'cpm_management#get_filter_custom_field'
	get 'oauth2callback', :to => 'cpm_management#oauth_callback', :as => 'oauth_callback'

	match '/cpm_reports/:action' => 'cpm_reports'
	match '/cpm_reports/reports.:format' => 'cpm_reports#reports'
end
