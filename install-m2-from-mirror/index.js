const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
  try { 
    const ceversion = core.getInput('ceversion');
    const options = {};
 	await exec.exec('composer create-project --repository=https://repo-magento-mirror.fooman.co.nz/ magento/project-community-edition:${ceversion} m2-folder --no-install --no-interaction');
	options.cwd = './m2-folder';
	await exec.exec('composer', ['config', '--unset', 'repo.0'], options);
	await exec.exec('composer', ['config', 'repo', 'repo.foomanmirror', 'composer', 'https://repo-magento-mirror.fooman.co.nz/'], options);
	await exec.exec('composer', ['install', ' --prefer-dist'], options);
  } 
  catch (error) {
    core.setFailed(error.message);
  }
}

run()