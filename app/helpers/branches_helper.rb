module BranchesHelper
  # A control that lets the user jump to a branch in a repository.
  def branch_switcher(repository, current_branch, label_text = 'Switch branch')
    content_tag 'div', :class => 'dropdown' do
      content_tag('p', label_text) + content_tag('ul') {
        repository.branches.map { |branch|
          content_tag 'li' do
            link_to branch.name,
                profile_repository_branch_path(repository.profile, repository,
                                               branch)
          end
        }.join
      }
    end
  end
end
