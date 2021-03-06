class BranchesController < ApplicationController
  before_filter :current_user_can_read_repo, :except => :destroy
  before_filter :current_user_can_commit_to_repo, :only => :destroy

  # GET /costan/rails/branches
  # GET /costan/rails/branches.xml
  def index
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @branches = @repository.branches

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @branches }
    end
  end

  # GET /costan/rails/branch/master
  # GET /costan/rails/branch/master.xml
  def show
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @branch = @repository.branches.where(:name => params[:branch_name]).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @branch }
    end
  end

  # DELETE /costan/rails/branch/master
  # DELETE /costan/rails/branch/master.xml
  def destroy
    @profile = Profile.where(:name => params[:profile_name]).first
    @repository = @profile.repositories.where(:name => params[:repo_name]).first
    @branch = @repository.branches.where(:name => params[:branch_name]).first
    @branch.destroy

    respond_to do |format|
      format.html { redirect_to(branches_url) }
      format.xml  { head :ok }
    end
  end
end
