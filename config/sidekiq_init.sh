#!/bin/bash
# sidekiq    Init script for Sidekiq
# chkconfig: 345 100 75
#
# Description: Starts and Stops Sidekiq message processor for Stratus application.
#
# User-specified exit parameters used in this script:
#
# Exit Code 5 - Incorrect User ID
# Exit Code 6 - Directory not found
 
 
# You will need to modify these
APP="redmine"
AS_USER="railsdev"
APP_DIR="/home/${AS_USER}/apps/${APP}/current"
 
SHARED_DIR="/home/${AS_USER}/apps/${APP}/shared"
LOG_FILE="$SHARED_DIR/log/sidekiq.log"
LOCK_FILE="/home/${AS_USER}/apps/${APP}/shared/pids/sidekiq-lock"
PID_FILE="/home/${AS_USER}/apps/${APP}/shared/pids/sidekiq.pid"
SIDEKIQ="sidekiq"
APP_ENV="production"
BUNDLE="bundle"
 
START_CMD="bundle exec sidekiq --index 0 --pidfile /home/${AS_USER}/apps/${APP}/shared/pids/sidekiq.pid --environment production --logfile /home/${AS_USER}/apps/${APP}/shared/log/sidekiq.log --daemon"
CMD="cd ${APP_DIR}; ${START_CMD} >> ${LOG_FILE} 2>&1 &"
 
RETVAL=0
 
 
start() {
 
  status
  if [ $? -eq 1 ]; then
 
    [ `id -u` == '0' ] || (echo "$SIDEKIQ runs as root only .."; exit 5)
    [ -d $APP_DIR ] || (echo "$APP_DIR not found!.. Exiting"; exit 6)
    cd $APP_DIR
    echo "Starting $SIDEKIQ message processor .. "
 
    su -c "$CMD" - $AS_USER
 
    RETVAL=$?
    #Sleeping for 8 seconds for process to be precisely visible in process table - See status ()
    sleep 8
    [ $RETVAL -eq 0 ] && touch $LOCK_FILE
    return $RETVAL
  else
    echo "$SIDEKIQ message processor is already running .. "
  fi
 
 
}
 
stop() {
 
    echo "Stopping $SIDEKIQ message processor .."
    SIG="INT"
    kill -$SIG `cat  $PID_FILE`
    RETVAL=$?
    [ $RETVAL -eq 0 ] && rm -f $LOCK_FILE
    return $RETVAL
}
 
status() {
 
  ps -ef | grep 'sidekiq [0-9].[0-9].[0-9]' | grep -v grep
  return $?
}
 
 
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
 
        if [ $? -eq 0 ]; then
             echo "$SIDEKIQ message processor is running .."
             RETVAL=0
         else
             echo "$SIDEKIQ message processor is stopped .."
             RETVAL=1
         fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 0
        ;;
esac
exit $RETVAL