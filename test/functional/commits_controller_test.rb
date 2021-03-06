require 'test_helper'

class CommitsControllerTest < ActionController::TestCase
  setup do
    @commit = commits(:commit2)
    @branch = branches(:branch1)
    @tag = tags(:v1)
    @session_user = @branch.repository.profile.user
    set_session_current_user @session_user    
  end

  test "should show commits with no ref" do
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param
    assert_response :success
    assert_equal branches(:master), assigns(:branch)
    assert_not_nil assigns(:commits)
  end

  test "should show commits with branch ref" do
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @branch.to_param
    assert_response :success
    assert_equal @branch, assigns(:branch)
    assert_not_nil assigns(:commits)
  end

  test "should show commits with tag ref" do
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @tag.to_param
    assert_response :success
    assert_equal @tag, assigns(:tag)
    assert_not_nil assigns(:commits)
  end

  test "should show commit" do
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :success
  end
  
  test "should grant read access to non-owner" do
    non_owner = User.all.find { |u| u != @session_user }
    assert non_owner, 'non-owner finding failed'
    set_session_current_user non_owner

    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param
    assert_response :success
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @branch.to_param
    assert_response :success
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @tag.to_param
    assert_response :success
    
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :success    
  end

  test "should deny access to guests" do
    set_session_current_user nil
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param
    assert_response :forbidden
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @branch.to_param
    assert_response :forbidden
    
    get :index, :repo_name => @commit.repository.to_param,
                :profile_name => @commit.repository.profile.to_param,
                :ref_name => @tag.to_param
    assert_response :forbidden
    
    get :show, :commit_gid => @commit.to_param,
               :repo_name => @commit.repository.to_param,
               :profile_name => @commit.repository.profile.to_param
    assert_response :forbidden
  end
  
  test "commit routes" do
    assert_routing({:path => '/costan/rails/commits', :method => :get},
                   {:controller => 'commits', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails'})
    assert_routing({:path => '/costan/rails/commits/v1.0', :method => :get},
                   {:controller => 'commits', :action => 'index',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :ref_name => 'v1.0'})
    assert_routing({:path => '/costan/rails/commit/1234567890abcdef',
                    :method => :get},
                   {:controller => 'commits', :action => 'show',
                    :profile_name => 'costan', :repo_name => 'rails',
                    :commit_gid => '1234567890abcdef'})
  end
end
