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

        const baseline = JSON.parse(fs.readFileSync(baselineFileName).toString());
        const after = JSON.parse(fs.readFileSync(afterFileName).toString());

        const timeDiff = ((after.envelope.wt - baseline.envelope.wt) / baseline.envelope.wt) * 100;
        const memoryDiff = ((after.envelope.pmu - baseline.envelope.pmu) / baseline.envelope.pmu) * 100;
        const sqlDiff = ((after.arguments["io.db.query"]["*"].ct - baseline.arguments["io.db.query"]["*"].ct) / baseline.arguments["io.db.query"]["*"].ct) * 100;

        const github = new GitHub(token);

        const message = "| Dimension | Difference |\n| --- | ---: |\n| Time | " + Number(timeDiff).toFixed(2) + "% |\n| Memory | " + Number(memoryDiff).toFixed(2) + "%| \n| SQL Queries | " + Number(sqlDiff).toFixed(2) + "% |\n\n[Blackfire.io Profile](" + baseline._links.graph_url.href + ")";
        core.debug(message);
        if (context.payload.pull_request == null) {
            const new_comment = github.repos.createCommitComment({
                ...context.repo,
                commit_sha: process.env.GITHUB_SHA,
                body: message
            });
        } else {
            const new_comment = github.issues.createComment({
                ...context.repo,
                issue_number: context.payload.pull_request.number,
                body: message
            });
        }

        if ((timeDiff > threshold) || (memoryDiff > threshold) || (sqlDiff > threshold)) {
            throw new Error("Performance decreased more than configured threshold " + threshold);
        }

    } catch (error) {
        core.setFailed(error.message);
    }
}
run();