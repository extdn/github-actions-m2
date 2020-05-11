const core = require('@actions/core');
const exec = require('@actions/exec');
const github = require("@actions/github");

const fs = require('fs');

async function run() {
try {

    const threshold = core.getInput('threshold');
    const baselineFileName = core.getInput('baseline-file');
    const afterFileName = core.getInput('after-file');

    if(!fs.existsSync(process.env.GITHUB_WORKSPACE + baselineFileName) && !fs.existsSync(process.env.GITHUB_WORKSPACE + afterFileName)) {
        core.setFailed("Can't find blackfire profiles to compare");
    }
    let baseline = JSON.parse(fs.readFileSync(process.env.GITHUB_WORKSPACE + baselineFileName));
    console.log(baseline._links.graph_url.href);
    let after = JSON.parse(fs.readFileSync(process.env.GITHUB_WORKSPACE + afterFileName));
    console.log("Time Difference" + Number(((baseline.envelope.wt-after.envelope.wt)/baseline.envelope.wt)*100).toFixed(2));
    console.log("Memory Difference" + Number(((baseline.envelope.pmu-after.envelope.pmu)/baseline.envelope.wt)*100).toFixed(2).toFixed(2));
    console.log("Number of SQL Queries" + Number(((baseline["io.db.query"]["*"].ct-after["io.db.query"]["*"].ct)/baseline["io.db.query"]["*"].ct)*100).toFixed(2));
}
    catch (error) {
        core.setFailed(error.message);
    }
}