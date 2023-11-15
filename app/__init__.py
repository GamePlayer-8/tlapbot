import os
import sys
import logging
import shutil
from flask import Flask
from apscheduler.schedulers.background import BackgroundScheduler
from .db import get_db
from .owncast_requests import is_stream_live, give_points_to_chat
from .redeems import remove_inactive_redeems
from tlapbot import timezone

os.chdir(getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__))))
sys.path.append(os.getcwd())
PYBIN = sys.executable

def create_app():
    timezone.setup()

    if getattr(sys, 'frozen', False):
        template_folder = os.path.join(sys._MEIPASS, 'templates')
        static_folder = os.path.join(sys._MEIPASS, 'static')
        if 'instance' in sys.argv:
            _ins_pos = sys.argv.index('instance')
            if len(sys.argv) <= _ins_pos + 1:
                print('Tlapbot:Err > missing path value.')
                sys.exit()
            instance_path = os.path.abspath(sys.argv[_ins_pos + 1])
            app = Flask(__name__, template_folder=template_folder, static_folder=static_folder, instance_path=instance_path)
        else:
            app = Flask(__name__, template_folder=template_folder, static_folder=static_folder, instance_path=os.path.dirname(sys.executable) + '/instance')
    else:
        app = Flask(__name__, instance_relative_config=True)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    # ensure config files exists
    if not os.path.exists(app.instance_path + '/config.py'):
        shutil.copyfile(os.path.join(sys._MEIPASS, 'default_config.py'), app.instance_path + '/config.py')

    if not os.path.exists(app.instance_path + '/redeems.py'):
        shutil.copyfile(os.path.join(sys._MEIPASS, 'default_redeems.py'), app.instance_path + '/redeems.py')

    if os.path.isdir(app.instance_path + '/config.py'):
        print('ERR: \'' + app.instance_path + '/config.py\' is a directory.')
        sys.exit(1)

    if os.path.isdir(app.instance_path + '/redeems.py'):
        print('ERR: \'' + app.instance_path + '/redeems.py\' is a directory.')
        sys.exit(1)

    # Prepare config: set db to instance folder, then load default, then
    # overwrite it with config.py and redeems.py
    app.config.from_mapping(
        DATABASE=os.path.join(app.instance_path, "tlapbot.sqlite")
    )
    app.config.from_object('default_config')
    app.config.from_object('default_redeems')
    app.config.from_pyfile(app.instance_path + '/config.py', silent=False)
    app.config.from_pyfile(app.instance_path + '/redeems.py', silent=False)

    # Make logging work for gunicorn-ran instances of tlapbot.
    if app.config['GUNICORN']:
        gunicorn_logger = logging.getLogger('gunicorn.error')
        app.logger.handlers = gunicorn_logger.handlers
        app.logger.setLevel(gunicorn_logger.level)

    # Check for wrong config that would break Tlapbot
    if len(app.config['PREFIX']) != 1:
        raise RuntimeError("Prefix is >1 character. "
                           "Change your config to set 1-character prefix.")

    # prepare webhooks and redeem dashboard blueprints
    from tlapbot import owncast_webhooks
    from tlapbot import tlapbot_dashboard
    app.register_blueprint(owncast_webhooks.bp)
    app.register_blueprint(tlapbot_dashboard.bp)

    # add db CLI commands
    from tlapbot import db

    db.init_app(app)
    app.cli.add_command(db.clear_queue_command)
    app.cli.add_command(db.refresh_counters_command)
    app.cli.add_command(db.refresh_and_clear_command)
    app.cli.add_command(db.refresh_milestones_command)

    # scheduler job for giving points to users
    def proxy_job():
        with app.app_context():
            if is_stream_live():
                app.logger.info("Stream is LIVE. Giving points to chat.")
                give_points_to_chat(get_db())
            else:
                app.logger.info("Stream is NOT LIVE. (Not giving points to chat.)")

    if not os.path.exists(app.instance_path + '/tlapbot.sqlite'):
        with app.app_context():
            db.init_db()

    # start scheduler that will give points to users
    points_giver = BackgroundScheduler()
    points_giver.add_job(proxy_job, 'interval', seconds=app.config['POINTS_CYCLE_TIME'])
    points_giver.start()

    return app


if __name__ == '__main__':
    create_app()