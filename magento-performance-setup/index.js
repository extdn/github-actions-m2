const core = require('@actions/core');
const exec = require('@actions/exec');
const fs = require('fs');

async function run() {
try {
    const ceversion = '2.3.5';
    const phpVersion = core.getInput('php-version');

    if (!fs.existsSync(process.env.GITHUB_WORKSPACE+'/extension')) {
        throw Error("Expected checked out code in 'extension' folder");
    }
    if(!process.env.BLACKFIRE_CLIENT_ID) {
        throw Error("Expected environment variable 'BLACKFIRE_CLIENT_ID'");
    }
    if(!process.env.BLACKFIRE_CLIENT_TOKEN) {
        throw Error("Expected environment variable 'BLACKFIRE_CLIENT_TOKEN'");
    }
    if(!process.env.BLACKFIRE_SERVER_ID) {
        throw Error("Expected environment variable 'BLACKFIRE_SERVER_ID'");
    }
    if(!process.env.BLACKFIRE_SERVER_TOKEN) {
        throw Error("Expected environment variable 'BLACKFIRE_SERVER_TOKEN'");
    }

    //Ensure Nginx Document Root exists
    fs.mkdirSync(process.env.GITHUB_WORKSPACE+'/m2', { recursive: true })

    fs.copyFileSync(__dirname+'/docker-compose.yml', process.env.GITHUB_WORKSPACE+'/docker-compose.yml');

    await exec.exec('docker-compose', ['up', '-d']);

    const m2Options = {};
    await exec.exec(`composer create-project --repository=https://repo-magento-mirror.fooman.co.nz/ magento/project-community-edition:${ceversion} ${process.env.GITHUB_WORKSPACE}/m2 --no-install --no-interaction`);
    m2Options.cwd = process.env.GITHUB_WORKSPACE+'/m2';
    await exec.exec('composer', ['config', 'platform.php', phpVersion], m2Options);
    await exec.exec('composer', ['config', '--unset', 'repo.0'], m2Options);
    await exec.exec('composer', ['config', 'repo.foomanmirror', 'composer', 'https://repo-magento-mirror.fooman.co.nz/'], m2Options);
    await exec.exec('composer', ['install', '--prefer-dist'], m2Options);
}
    catch (error) {
        core.setFailed(error.message);
    }
}

run()