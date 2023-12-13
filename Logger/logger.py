# https://gist.github.com/kingspp/9451566a5555fb022215ca2b7b802f19

import os
import yaml
import logging.config
import logging
import coloredlogs

mm_logger_config_fn = "F://SNAITECH dev//Workspaces//Massive mail//data//mm_logger.yaml"

def init_logger(default_path=mm_logger_config_fn, default_level=logging.INFO, env_key='LOG_CFG'):

    path = default_path
    value = os.getenv(env_key, None)

    if value:
        path = value

    if os.path.exists(path):
        with open(path, 'rt') as f:
            try:
                config = yaml.safe_load(f.read())
                logging.config.dictConfig(config)
                coloredlogs.install()
            except Exception as e:
                print(e)
                print('Error in Logging Configuration. Using default configs')
                logging.basicConfig(level=default_level)
                coloredlogs.install(level=default_level)
    else:
        logging.basicConfig(level=default_level)
        coloredlogs.install(level=default_level)
        print('Failed to load configuration file. Using default configs')

    logger = logging.getLogger(__name__)

    # logger.info("init_logger info")
    # logger.error("init_logger error")
    # logger.debug("init_logger debug")
    # logger.critical("init_logger critical")
    # logger.warning("init_logger warning")
