# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
	resources :cpm_user_capacity

	match '/cpm_management/:action' => 'cpm_management'
	match '/cpm_management/edit_form/:user_id' => 'cpm_management#edit_form'
	match '/cpm_management/edit_capacity/:id' => 'cpm_management#edit_capacity'
	match '/cpm_management/delete_capacity/:id' => 'cpm_management#delete_capacity'
end
