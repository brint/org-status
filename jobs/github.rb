include_prs_in_issue_count = false
include_forks = false

total_issues = 0
total_pull_requests = 0

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '10m', :first_in => 0 do |job|
  combined_count = Hash.new
  repos = Github.get_repos_with_pr_and_issues
  repos.values.each do |repo|
    unless Github.ignored_repos.include?(repo['name'])
      if repo['pull_requests'] > 0 or repo['open_issues_count'] > 0
        if include_prs_in_issue_count
          issues = repo['open_issues_count']
        else
          issues = repo['open_issues_count'] - repo['pull_requests']
        end
        if !repo['fork']
          combined_count[repo['name']] = { label: repo['name'], open_issues_count: issues, pull_requests: repo['pull_requests'] }
        elsif repo['fork'] && include_forks
          combined_count[repo['name']] = { label: repo['name'], open_issues_count: issues, pull_requests: repo['pull_requests'] }
        end
      end
    end
  end

  last_total_issues = total_issues
  last_total_pull_requests = total_pull_requests
  total_pull_requests = combined_count.values.inject(0) { |sum, n| sum + n[:pull_requests] }
  total_issues = combined_count.values.inject(0) { |sum, n| sum + n[:open_issues_count] }

  send_event('combined', { items: combined_count.values.sort {|a, b| [a[:pull_requests], a[:open_issues_count]] <=> [b[:pull_requests], b[:open_issues_count]]}.reverse[0..19] })
  send_event('total_pull_requests', { current: total_pull_requests, last: last_total_pull_requests })
  send_event('total_issues', { current: total_issues, last: last_total_issues })
end
