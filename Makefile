droplet:
	docker-machine create --driver digitalocean --digitalocean-access-token $(DO_TOKEN) --digitalocean-private-networking $(NAME)