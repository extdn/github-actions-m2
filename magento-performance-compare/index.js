const core = require('@actions/core');
const {context, GitHub} = require("@actions/github");
const fs = require('fs');

async function run() {
    try {

        const token = core.getInput('github-token', {required: true})
        const threshold = core.getInput('threshold');
        const baselineFileName = core.getInput('baseline-file');
        const afterFileName = core.getInput('after-file');

        if (!fs.existsSync(process.env.GITHUB_WORKSPACE + baselineFileName) && !fs.existsSync(process.env.GITHUB_WORKSPACE + afterFileName)) {
            core.setFailed("Can't find blackfire profiles to compare");
        }

        let baseline = JSON.parse(fs.readFileSync(process.env.GITHUB_WORKSPACE + baselineFileName));
        let after = JSON.parse(fs.readFileSync(process.env.GITHUB_WORKSPACE + afterFileName));

        let timeDiff = Number(((baseline.envelope.wt - after.envelope.wt) / baseline.envelope.wt) * 100).toFixed(2);
        let memoryDiff = Number(((baseline.envelope.pmu - after.envelope.pmu) / baseline.envelope.wt) * 100).toFixed(2).toFixed(2);
        let sqlDiff = Number(((baseline["io.db.query"]["*"].ct - after["io.db.query"]["*"].ct) / baseline["io.db.query"]["*"].ct) * 100).toFixed(2);

        core.debug("Time Difference " + timeDiff + "Memory Difference " + memoryDiff + "Number of SQL Queries " + sqlDiff + "Profile" + baseline._links.graph_url.href);
        const github = new GitHub(token);

        const new_comment = github.commits.createCommitComment({
            ...context.repo,
            commit_sha: process.env.GITHUB_SHA,
            body: "Time Difference " + timeDiff + "Memory Difference " + memoryDiff + "Number of SQL Queries " + sqlDiff + "Profile" + baseline._links.graph_url.href
        });
        if (timeDiff > threshold || memoryDiff > threshold || sqlDiff > threshold) {
            core.setFailed("Performance decreased more than configured threshold.");
        }

    } catch (error) {
        core.setFailed(error.message);
    }
}