org-status
===============
This is a work in progress.

Simple [dashing](http://shopify.github.io/dashing/) dashboard for monitoring
issues and pull requests within a GitHub org. Output is ordered based on number
of open Pull Requests, then based on number of open Issues.

#### Notes
* Issue count does not include Pull Requests. Set `include_prs_in_issue_count`
  to `true` in `jobs/github.rb` if you'd like to include PR's in the issue
  count.
* Forks are not counted. Most of the time you fork something, it's not so you
  can maintain it. If you'd like to include forks, set `include_forks` to
  `true` in `jobs/github.rb`.

#### Known issues
* Only works with github.com. GitHub Enterprise will not work.
* Only works with orgs, does not work with users.
* Doesn't play well with large numbers of PR's. (paging issue)
* GitHub feed only supports `PushEvent`.

#### Getting started
First, I need to give props to the [github_feed
widget](https://gist.github.com/kimh/8894101). This dashboard is using that
widget. It's been slightly tweaked.

Clone everything down, install gems, setup config:
```
git clone https://github.com/brint/org-status
cd org-status
bundle install
cp config/github.yml.sample config/github.yml
```
Edit `config/github.yml`, set the server, user, org, token, and repos to ignore
list.

Then run the dashboard:
```
dashing start
```
Navigate to the dashboard in your browser: `http://localhost:3030`

#### Example Dashboard
![Screenshot](https://raw.githubusercontent.com/brint/org-status/master/docs/screenshot.png)
