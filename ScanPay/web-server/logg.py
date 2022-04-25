import logging.config
from logging import LoggerAdapter, getLogger
from datetime import datetime, date
from typing import Dict, Any



UNSPECIFIED = 'unspecified'
__project_name__ = UNSPECIFIED
__version__ = '1.0.1'


def setup_logging(project_name: str):
    global __project_name__
    if __project_name__ != UNSPECIFIED:
        raise RuntimeError(f'Setup should be called only once!')
    __project_name__ = project_name

    utc_time = datetime.utcnow().isoformat(timespec='seconds')
    log_filename = f'log/{utc_time}.log'.replace(':', '_')

    logging.config.fileConfig('./logging.ini', defaults={'args': (log_filename, 'a', 'utf-8')})


def get_log(class_name: str) -> LoggerAdapter:
    if __project_name__ == UNSPECIFIED:
        raise RuntimeError(
            f'The project name ({__project_name__}) should be specified '
            f'using `setup_logging()` method of this module before log usage!'
        )
    _log = getLogger(class_name)

    extra = {
        'class_name': class_name,
        'project_name': __project_name__,
        'version': __version__,
    }
    return ExtraKeepLoggerAdapter(_log, extra)

def get_class_log(obj: Any) -> LoggerAdapter:
    return get_log(obj.__class__.__name__)  

class ExtraKeepLoggerAdapter(LoggerAdapter):

    def process(self, msg: str, kwargs: Dict[str, Any]) -> Any:
        merged_context = self.extra.copy()

        if 'extra' in kwargs:
            merged_context.update(kwargs['extra'])

        kwargs['extra'] = merged_context
        return msg.format_map(merged_context), kwargs

  
