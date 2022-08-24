from flask import Flask,request,json,Blueprint
from sqlite3 import Error
from tlapbot.db import get_db
from tlapbot.owncast_helpers import *

bp = Blueprint('owncast_webhooks', __name__)

@bp.route('/owncastWebhook',methods=['POST'])
def owncast_webhook():
    data = request.json
    db = get_db()
    if data["type"] == "USER_JOINED":
        user_id = data["eventData"]["user"]["id"]
        # CONSIDER: join points for joining stream
        add_user_to_database(db, user_id)
    elif data["type"] == "CHAT":
        display_name = data["eventData"]["user"]["displayName"]
        print("New chat message:")
        print(f'from {display_name}:')
        print(f'{data["eventData"]["body"]}')
        user_id = data["eventData"]["user"]["id"]  
        if "!points" in data["eventData"]["body"]:
            if not user_exists(db, user_id):
                add_user_to_database(db, user_id)
            points = read_users_points(db, user_id)
            message = "{}'s points: {}".format(display_name, points)
            print(message)
            send_chat(message)
        elif "!drink" in data["eventData"]["body"]:
            points = read_users_points(db, user_id)
            if points is not None:
                if points > 60:
                    use_points(db, user_id, 60)
                    send_chat("Enjoy your DRINK........... sips")
        else: # DEBUG: give points for message
            give_points_to_chat(db)
    return data