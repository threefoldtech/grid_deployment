tmux new -d -s 0-db
tmux send-keys -t 0-db "docker logs 0-db -f --tail 500" ENTER
tmux new -d -s 0-hub
tmux send-keys -t 0-hub "docker logs 0-hub -f --tail 500" ENTER
tmux new -d -s caddy
tmux send-keys -t caddy "docker logs caddy -f --tail 500" ENTER
