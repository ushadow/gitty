require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup :mock_profile_paths
  
  setup do
    @profile = profiles(:costan)
    @session_user = profiles(:costan).user
    set_session_current_user @session_user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile" do
    assert_difference('Profile.count') do
      post :create, :profile => @profile.attributes.merge(:name => 'newest')
    end

    assert_redirected_to session_path
  end

  test "should show profile" do
    get :show, :profile_name => @profile.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :profile_name => @profile.to_param
    assert_response :success
  end

  test "should update profile" do
    put :update, :profile_name => @profile.to_param,
                 :profile => @profile.attributes
    assert_redirected_to profile_path(assigns(:profile))
  end
  
  test "should rename profile" do
    old_local_path = @profile.local_path
    FileUtils.mkdir_p old_local_path

    put :update, :profile_name => @profile.to_param,
                 :profile => @profile.attributes.merge(:name => 'randomness')
    
    assert_equal 'randomness', @profile.reload.name
    
    assert_not_equal old_local_path, @profile.local_path,
                     'rename test case broken'
    assert !File.exist?(old_local_path), 'profile not renamed'
    assert File.exist?(@profile.local_path), 'profile not renamed'
    
    assert_redirected_to profile_path(assigns(:profile))
  end
  
  test "should use old profile url on rejected rename" do
    put :update, :profile_name => @profile.to_param,
                 :profile => @profile.attributes.merge(:name => '-broken')
    
    assert_not_equal '-broken', @profile.reload.name
    assert_template :edit
    assert_select "form[action=#{profile_path(@profile)}]"
    assert_select 'input[id=profile_name][value="-broken"]'
  end  

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete :destroy, :profile_name => @profile.to_param
    end

    assert_redirected_to profiles_path
  end
  
  test "should grant read access to non-owner" do
    non_owner = User.all.find { |u| u != @session_user }
    assert non_owner, 'non-owner finding failed'
    set_session_current_user non_owner
    
    get :show, :profile_name => @profile.to_param
    assert_response :success
    
    get :edit, :profile_name => @profile.to_param
    assert_response :forbidden
    
    put :update, :profile_name => @profile.to_param,
                 :profile => @profile.attributes
    assert_response :forbidden
    
    assert_no_difference 'Repository.count' do
      delete :destroy, :profile_name => @profile.to_param
    end
    assert_response :forbidden
  end
    
  test "profile routes" do
    assert_routing({:path => '/_/profiles', :method => :get},
                   {:controller => 'profiles', :action => 'index'})
    assert_routing({:path => '/_/profiles/new', :method => :get},
                   {:controller => 'profiles', :action => 'new'})
    assert_routing({:path => '/_/profiles', :method => :post},
                   {:controller => 'profiles', :action => 'create'})
    assert_routing({:path => '/_/profiles/costan/edit', :method => :get},
                   {:controller => 'profiles', :action => 'edit',
                    :profile_name => 'costan'})

    assert_routing({:path => '/costan', :method => :get},
                   {:controller => 'profiles', :action => 'show',
                    :profile_name => 'costan'})
    assert_recognizes({:controller => 'profiles', :action => 'show',
                       :profile_name => 'costan'},
                      {:path => '/_/profiles/costan', :method => :get})
    assert_routing({:path => '/costan', :method => :put},
                   {:controller => 'profiles', :action => 'update',
                    :profile_name => 'costan'})
    assert_recognizes({:controller => 'profiles', :action => 'update',
                       :profile_name => 'costan'},
                      {:path => '/_/profiles/costan', :method => :put})
    assert_routing({:path => '/costan', :method => :delete},
                   {:controller => 'profiles', :action => 'destroy',
                    :profile_name => 'costan'})
    assert_recognizes({:controller => 'profiles', :action => 'destroy',
                       :profile_name => 'costan'},
                      {:path => '/_/profiles/costan', :method => :delete})
  end
end
