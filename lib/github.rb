require 'json'
require 'net/http'
require 'net/https'
require 'uri'
require 'octokit'
require 'yaml'

class Github
    def self.config
        @config ||= YAML.load_file("config/github.yml")
        ["server", "user", "organization", "gh_token", "ignored_repos"].each do |key|
          raise "github.yml file does not include the #{key} key" unless @config[key]
        end
        return @config
    end

    def self.get_repos
        Octokit.auto_paginate = true
        client = Octokit::Client.new(:access_token => config["gh_token"])
        return client.organization_repositories(config["organization"])
    end

    def self.ignored_repos
        return config["ignored_repos"]
    end

    def self.get_repo_count
        repos = get_repos()
        filtered = Array.new
        repos.each do |repo|
            filtered.push(repo['name']) unless config["ignored_repos"].include?(repo['name'])
        end
        return filtered.count
    end

    def self.get_repo_pr_list(repo)
        Octokit.auto_paginate = true
        return Octokit::Client.new(:access_token => config["gh_token"]).pull_requests("#{config["organization"]}/#{repo['name']}")
    end

    def self.get_repos_with_pr_and_issues
        repos = get_repos()
        has_issues = Hash.new
        repos.each do |repo|
            unless config["ignored_repos"].include?(repo['name'])
                prs = get_repo_pr_list(repo).count
                if repo['open_issues_count'] > 0 or prs > 0
                    has_issues[repo['name']] = {'name' => repo['name'], 'open_issues_count' => repo['open_issues_count'], 'pull_requests' => prs, 'fork' => repo['fork']} unless config["ignored_repos"].include?(repo['name'])
                end
            end
        end
        return has_issues
    end

end
