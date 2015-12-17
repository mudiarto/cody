class ReceivePullRequestEvent
  include Sidekiq::Worker

  def perform(payload)
    reviewers = payload["pull_request"]["body"].scan(/- \[.\] @(.+)/)
    
    number = payload["number"]

    PullRequest.create!(number: number, status: "pending_review")

    pr_sha = payload["pull_request"]["head"]["sha"]

    github = Octokit::Client.new(client_id: ENV["CODY_GITHUB_CLIENT_ID"], client_secret: ENV["CODY_GITHUB_CLIENT_SECRET"])
    github.create_status(ENV["CODY_GITHUB_REPO"], pr_sha, "pending", context: "code-review/cody", description: "Not all reviewers have approved")
  end
end
