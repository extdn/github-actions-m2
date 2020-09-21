const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
try { 
    const ceversion = core.getInput('ce-version');
    const options = {};
    await exec.exec(`composer create-project --repository=https://repo-magento-mirror.fooman.co.nz/ --no-install --no-progress --no-plugins magento/project-community-edition m2-folder ${ceversion}`);
    options.cwd = './m2-folder';
    await exec.exec('composer', ['config', '--unset', 'repo.0'], options);
    await exec.exec('composer', ['config', 'repositories.foomanmirror', 'composer', 'https://repo-magento-mirror.fooman.co.nz/'], options);
    await exec.exec('composer', ['install', '--prefer-dist'], options);

    await exec.exec('bin/magento', 
        [
          'setup:install',
          '--db-host=' + core.getInput('db-host') +':'+ core.getInput('db-port'),
          '--db-name=' + core.getInput('db-name'),
          '--db-user=' + core.getInput('db-user'),
          '--db-password=' + core.getInput('db-password'),
          '--base-url=' + core.getInput('base-url'),
          '--admin-firstname=Test',
          '--admin-lastname=Admin',
          '--admin-email=admin@example.com',
          '--admin-user=admin',
          '--admin-password=admin123',
          '--language=en_US',
          '--currency=USD',
          '--timezone=America/New_York',
          '--use-rewrites=1'
        ], options);
    } 
    catch (error) {
        core.setFailed(error.message);
    }
}

run()