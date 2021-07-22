import mysql.connector
from mysql.connector import Error
from prettytable import PrettyTable
import shlex


def connectToDB():
    try:
        connection = mysql.connector.connect(host='localhost', database='twitter-clone', user='root',)
        if connection.is_connected():
            db_Info = connection.get_server_info()
            print("Connected to MySQL Server version ", db_Info)
            cursor = connection.cursor()
            cursor.execute("select database();")
            record = cursor.fetchone()
            print("Connected to database: ", record)
            print("*" * 25)
            return connection, cursor
    except Error as e:
        print("Error while connecting to MySQL", e)


def disconnectFromDB(connection, cursor):
    connection.close()
    cursor.close()
    print("All connections to DB closed")


def printHelp():
    print("-" * 101)
    print("""Usage: command arg1 arg2 ...
List of commands:
command                 args                            function
-----------------------------------------------------------------------------------------------------
block                   username                        block another user
direct_text             username, text                  send direct text to another user
direct_tweet            username, tweet_id              send direct tweet to another user
follow                  username                        follow another user
get_direct_list                                         get the list of people who sent direct to you
get_directs             username                        get the direct messages another user sent you
get_followed_tweets     username                        get the tweets of users that you followed
get_hashtag_tweets      hashtag                         get the tweets of specific hashtag
get_logins                                              get the history of your logins
get_own_tweets                                          get your own tweets
get_popular_tweets                                      get the list of all tweets ordered by number
                                                        of likes
get_replys              tweet_id                        get the replys of specific tweet
get_tweet_likes         tweet_id                        get the number of likes of specific tweet
get_user_tweets         username                        get the tweets of specific user
like_tweet              tweet_id                        like a tweet
login                   username, password              login to your account
reply                   tweet_id, text                  reply to a tweet
sign_in                 username, password,             create a new account
                        first_name, last_name
                        birthday, biography
tweet                   text                            tweet a new text with hashtag             
unblock                 username                        unblock user
unfollow                username                        unfollow user
-----------------------------------------------------------------------------------------------------""")


def printTable(stored_results):
    results = stored_results
    for res in results:
        field_names = [i[0] for i in res.description]
        table = PrettyTable(field_names)
        for tup in res.fetchall():
            table.add_row(tup)
        print(table)


def executeCommand(connection, cursor, command):
    instruction = command[0]
    args = []

    for i in range(1, len(command)):
        args.append(command[i])

    try:
        # Try calling procedure
        cursor.callproc(instruction, args=args)

        # Print procedure results
        connection.commit()
        # Print Warnings
        if cursor._fetch_warnings() is not None:
            for warning in cursor._fetch_warnings():
                print(warning)
        printTable(cursor.stored_results())

    except Error as e:
        print("Error: " + str(e))


if __name__ == "__main__":
    # Connect to DB
    connection, cursor = connectToDB()

    # Main loop
    while True:
        line = input("> ")

        command = shlex.split(line)
        if len(command) == 0:
            continue

        instruction = command[0]
        if instruction == "end":
            print("*" * 25)
            break
        elif instruction == "help":
            printHelp()
        else:
            executeCommand(connection, cursor, command)

    # Disconnect from DB
    disconnectFromDB(connection, cursor)
