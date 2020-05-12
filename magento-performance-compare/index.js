const core = require('@actions/core');
const {context, GitHub} = require("@actions/github");
const fs = require('fs');

async function run() {
    try {
        const token = core.getInput('github-token', {required: true})
        const baselineFileName = core.getInput('baseline-file', {required: true});
        const afterFileName = core.getInput('after-file', {required: true});
        const threshold = core.getInput('threshold');

        if (!fs.existsSync(baselineFileName) || !fs.existsSync(afterFileName)) {
            throw new Error("Can't find blackfire profiles to compare");
        }

        let baseline = JSON.parse(fs.readFileSync(baselineFileName).toString());
        let after = JSON.parse(fs.readFileSync(afterFileName).toString());

        let timeDiff = Number(((baseline.envelope.wt - after.envelope.wt) / baseline.envelope.wt) * 100).toFixed(2);
        let memoryDiff = Number(((baseline.envelope.pmu - after.envelope.pmu) / baseline.envelope.wt) * 100).toFixed(2);
        let sqlDiff = Number(((baseline.arguments["io.db.query"]["*"].ct - after.arguments["io.db.query"]["*"].ct) / baseline.arguments["io.db.query"]["*"].ct) * 100).toFixed(2);

        const github = new GitHub(token);

        const message = "Time Difference " + timeDiff + "%\nMemory Difference " + memoryDiff + "%\nNumber of SQL Queries " + sqlDiff + "%\n\n(Profile)[" + baseline._links.graph_url.href + "]";
        core.debug(message);
        if (context.payload.pull_request == null) {
            const new_comment = github.createCommitComment({
                ...context.repo,
                commit_sha: process.env.GITHUB_SHA,
                body: message
            });
        } else {
            const pull_request_number = context.payload.pull_request.number;
            const new_comment = github.issues.createComment({
                ...context.repo,
                issue_number: pull_request_number,
                body: message
            });
        }

        if (timeDiff > threshold || memoryDiff > threshold || sqlDiff > threshold) {
            core.setFailed("Performance decreased more than configured threshold.");
        }

    } catch (error) {
        core.setFailed(error.message);
    }
}
run();